# [PRD-033] Lightweight TOC Input Spec (v1)

## 1. Objective
사용자 친화적이고 가벼운 방식(Markdown-like)으로 목차(TOC) 구조를 정의하고, 이를 기반으로 Workspace의 기본 구조를 생성한다.

## 2. Design Principles
1. **SSOT Transition**: 입력 데이터는 생성 시점에만 유효하며, 이후 모든 구조적 진실은 Workspace(UUID + Lineage)로 이전된다.
2. **Deterministic Identity**: `external_key`는 외부 주소 체계 및 안정성을 제공하며, 내부적으로 생성되는 `lineage_id`는 Re-import 및 Diff 연산 시 정체성 앵커(Identity Anchor)로 사용된다.
3. **Internal-only Lineage**: `lineage_id`는 시스템 내부 정체성 유지를 위한 장치이며, 외부 입력 파일에 노출하거나 사용자에게 요구하지 않는다.
4. **Forward Compatibility**: v1은 명시적인 Update를 제공하지 않으나, 모든 노드에 `lineage_id`를 할당함으로써 PRD-039 계열의 고차원 설계 변경 모델과 100% 호환된다.

## 3. Node Data Model (Internal)
```
Node {
  node_id: UUID,        // 시스템 내부 식별자
  lineage_id: UUID,     // 정체성 앵커 (자동 생성)
  external_key: string, // 도트 표기법 주소 (예: 1.1.1)
  title: string,
  order_int: number
}
```

## 4. Input Specification (TOC Text)
- 계층 구조는 들여쓰기(Space/Tab) 또는 불렛 포인트(`-`, `*`)로 정의한다.
- 리프 노드는 자동으로 `Section` 타입으로 간주된다.
- 예시:
  ```
  1권 서문
    1.1 목적
    1.2 대상
  ```

## 5. Non-Goals
- 기존 Workspace 구조 업데이트 (Create-only).
- 엑셀 기반 복잡한 디자인 사양 입력 (PRD-032 담당).

## 6. Success Criteria
1. 입력된 텍스트 구조가 누락 없이 Workspace 트리로 변환된다.
2. **모든 노드는 생성 시 고유한 `lineage_id`를 내부적으로 할당받는다.**
3. `external_key`가 계층 깊이에 따라 결정론적으로 생성된다.
