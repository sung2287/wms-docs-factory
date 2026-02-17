# C-048: Tree Drag UX Intent Map

## Intent Summary
본 PRD는 Tree Explorer의 UI 레이어에서 노드 재정렬 경험을 현대화하는 것을 목적으로 한다. 구조 변경은 기존 코어 API를 통해서만 발생하며, 부모 변경(Reparent)은 v1에서 금지된다. 모든 변경은 드롭 시점 1회의 원자적 Mutation으로 고정된다.

## 1. Intent-Reaction Mapping

| User Intent | UI Action / Trigger | System Reaction |
| :--- | :--- | :--- |
| **순서 변경 시작** | 핸들(⋮⋮) PointerDown | `ACTIVE_NODE` 설정. `DragOverlay` 생성. |
| **위치 탐색** | 다른 노드 위로 Hover | 동일 부모 여부 확인. `Drop Indicator` 및 형제 밀림 효과 적용. |
| **재정렬 확정** | PointerUp (Drop) | **Core API (reorderSiblings) 호출**. TreeState 갱신. Auto-save 트리거. |
| **작업 취소** | Escape / 경계 이탈 | 드래그 모드 종료. 트리를 원래 상태로 시각적 복구. |

## 2. Guard Rails (Intent Drift)
- **Core 우회 금지**: UI 레이어에서 직접 `children` 배열을 조작하여 상태를 갱신하는 행위.
- **부모 변경 허용 금지**: v1 스코프를 위반하여 `parent_id`를 변경하는 드롭을 허용하는 행위.
- **Numbering 저장 금지**: 재정렬 결과를 반영하기 위해 numbering을 노드 메타데이터에 물리적으로 쓰는 행위.
- **지연 없는 저장 금지**: 드롭 이전에 중간 상태를 스냅샷으로 생성하는 행위.
- Tree reorder가 Snippet 링크 의미를 변경하도록 구현하는 행위
- append-only Snapshot 원칙을 위반하는 저장 방식
- Override 시 기존 Snapshot을 수정하는 행위
