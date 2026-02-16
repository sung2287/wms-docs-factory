# [C-033] Intent Map: Lightweight TOC Import

## 1. Intent Summary
사용자가 마크다운과 유사한 가벼운 텍스트 형식으로 정의한 목차를 기반으로 Workspace의 뼈대를 신속하게 구축하는 것을 목적으로 한다.

## 2. Fixed Policies (고정 정책)
- **Identity Anchoring**: 모든 노드는 생성 시 `lineage_id`(UUID)를 내부 정체성 앵커(Internal Identity Anchor)로 할당받는다. `external_key`는 계층 표현과 내비게이션을 위한 속성(Navigation Attribute)일 뿐 정체성 자체가 아니다.
- **Deterministic Ordering**: 트리 노드의 순서는 다음 우선순위로 결정된다:
  1. Depth ASC (얕은 계층 우선)
  2. `external_key` Natural Numeric Sort (숫자 세그먼트 비교)
  3. Stable Tie-breaker (입력 텍스트상의 출현 순서)
- **SSOT Transition**: 입력 텍스트는 생성 도구일 뿐이며, 생성 완료 후 모든 구조적 진실은 Workspace Snapshot으로 이전된다.

## 3. Forbidden Evolutions (금지된 진화)
- 입력 순서(Input Order)만을 유일한 정렬 기준으로 삼아 환경에 따라 순서가 뒤바뀌게 방치하는 행위.
- `external_key`를 노드의 불변 식별자로 오용하는 행위.

## 4. Core & Sandbox Boundary
- **Core**: 계층 파싱 엔진, `lineage_id` 할당 로직, 결정론적 정렬 엔진.
- **Sandbox**: 사용자가 정의하는 텍스트 인덴트 규칙(Tab vs Space 등).

## 5. Future Expansion
- 기존 구조에 노드를 부분적으로 병합(Merge)하는 기능은 v2 이후로 연기한다.

## 6. Test Constitution v1.7 준수 의도
동일한 TOC 텍스트에 대해 항상 동일한 `external_key` 트리 위상과 `order_int`가 생성되는지 검증하는 결정론 테스트를 수행한다.
