# B-048: Tree Drag UX Contract

## 1. Objective
Tree Explorer의 드래그 조작 과정에서 발생하는 일시적 UI 상태와 최종적인 트리 구조 변경(Mutation) 사이의 논리적 계약을 정의한다.

## 2. Reordering Logic
- **허용 범위**: `Input.nodeId`의 `parent_id`와 `Target.parentId`가 일치하는 경우에만 이동을 확정한다.
- **금지 조건**: `parent_id`가 변경되는 모든 이동 시도는 드롭 시점에 무효화(Revert)되어야 한다.
- **원자성**: 드롭 시점 전까지는 전역 `TreeState`에 어떠한 사이드 이펙트도 발생시키지 않는다.

## 3. Transient States (UI-only)
- **ACTIVE_NODE**: 현재 드래그 중인 노드의 ID.
- **PROJECTED_INDEX**: 드래그 위치에 따른 형제 배열 내 가상 인덱스.
- **DROP_INDICATOR_POSITION**: 시각적 가이드 라인이 표시될 위치 정보.

## 4. Integrity Constraints
- **Stable Identity**: 드래그 앤 드롭 계산은 오직 `node.id`를 기준으로 수행한다.
- **Cycle Prevention**: v1은 형제간 이동만 허용하므로 순환 참조 발생 가능성이 원천 차단되지만, 내부적으로는 Core의 순환 검증 로직을 우회하지 않는다.
- reorder 수행 시 `parent_id`는 변경되어서는 안 된다.
- TreeState 변경은 반드시 Core API의 반환값을 통해서만 반영되며, UI 레이어는 상태를 직접 수정하지 않는다.
- Core의 순환(cycle) 검증 로직을 우회해서는 안 된다.
