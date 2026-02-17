# PRD-048: Notion-like Tree Node Drag Handle + Live Reorder (Tree UX v1)

## 1. Objective
본 문서는 Tree Explorer에서 노드를 직관적이고 현대적인 방식(Notion-like)으로 재정렬할 수 있는 드래그 앤 드롭(Drag & Drop) UX 사양을 정의한다. 
- **UI/UX 확장**: 기존 Tree Engine(PRD-012)의 API를 그대로 활용하면서 사용자에게 시각적으로 유려한 재정렬 경험을 제공한다.
- **코어 정책 유지**: 데이터 모델, 계층 구조 규칙, 스냅샷 전략 등 시스템 코어 로직은 수정하지 않는다.

## 2. In Scope (v1 LOCKED)
- **형제 노드 간 재정렬 (Sibling Reorder)**: 동일한 `parent_id`를 공유하는 노드들 사이의 순서 변경만 허용한다.
- **핸들(Handle) 기반 조작**: 드래그는 오직 전용 핸들(⋮⋮)을 통해서만 시작할 수 있다.
- **지연된 상태 반영 (Delayed Mutation)**: 드래그 중(Move)에는 데이터 상태가 변경되지 않으며, 오직 드롭(Drop) 시점에만 코어 API를 호출하여 상태를 갱신한다.
- **저장 정책 연동**: 드롭 성공 시 `isDirty`가 발생하며, PRD-042의 2초 Auto-save 정책에 따라 자동으로 서버에 반영된다.

## 3. Out of Scope (v1 명시적 차단)
- **부모 변경 (Reparenting)**: 노드를 다른 노드 내부로 이동하거나 레벨을 변경하는 기능.
- **계층간 이동 (Cross-boundary)**: 서로 다른 Part 또는 Workspace 간의 노드 이동.
- **멀티 선택 (Multi-select)**: 여러 노드를 동시에 드래그하는 기능.
- **접근성 고도화**: 키보드 기반 재정렬 및 실시간 ARIA Announce (v2 고려).
- **대규모 트리 최적화**: 수천 개 노드 대응을 위한 가상화(Virtualization).

## 4. Dirty / Save Alignment
- **판단 기준**: 드롭 완료 후 TreeState가 이전 스냅샷과 다를 경우 Dirty로 간주한다.
- **충돌 관리**: 트리 구조 변경 중 서버 헤드가 업데이트될 경우 PRD-041 정책에 따라 Conflict를 감지하고 처리한다.
- Sibling reorder는 `linkedSnippetId`의 참조 관계를 변경하지 않으며, PRD-020의 Tree → Snippet 단방향 참조 정책에 영향을 주지 않는다.
- 본 PRD는 Snippet 연결 상태, resolve 로직, Dangling 처리 정책을 수정하지 않는다.
- Tree reorder는 append-only Snapshot 정책(PRD-041)을 그대로 따른다.
- Override는 기존 head를 덮어쓰지 않으며, 신규 Snapshot을 생성하는 방식으로만 처리된다.
- 기존 Snapshot은 어떠한 경우에도 수정/삭제되지 않는다.

### 4.x Tree Reorder Conflict Handling
- Tree reorder에 의해 발생하는 Save 요청은 **PRD-041 Snapshot Conflict & New Snapshot Policy**를 동일하게 따른다.
- 드롭 시점에 사용자가 기반으로 삼은 `base_snapshot_id`와 현재 `head_snapshot_id`를 비교한다.
- `base != head`인 경우, reorder mutation은 저장 단계에서 차단되며 Snapshot은 생성되지 않는다.
- 이 경우 상태는 **Conflict**로 전이된다.
- Tree 구조 변경으로 인한 충돌은 PRD-043 Comparison UI의 범위에 포함되지 않는다.
- Tree 구조 비교 UI는 v1 범위에 포함되지 않으며, 별도 PRD에서 정의한다.

### 4.y Undo / Restore Definition
- Undo는 명령 기반 Revert가 아니다.
- 드롭 1회는 1개의 신규 Snapshot 생성(PRD-025 append-only 원칙)을 의미한다.
- 되돌리기는 PRD-028 Snapshot History / Time Travel 메커니즘을 통해 수행된다.
- Restore는 과거 Snapshot을 수정하는 것이 아니라, 해당 Snapshot을 기반으로 **새 Snapshot을 생성**하는 방식으로 처리된다.
- 기존 Snapshot은 어떠한 경우에도 수정/삭제되지 않는다.

## 5. Core 정합 선언
- 모든 구조 변경은 PRD-012의 `reorderSiblings` 및 `moveNode` API를 통해서만 수행된다.
- 노드 번호(Numbering)는 State에 저장하지 않으며, Tree Engine이 런타임에 Depth-first 방식으로 계산하는 원칙을 고수한다.

### 5.x PROJECTED_INDEX 계산 기준
- 드래그 중 계산되는 PROJECTED_INDEX는 DOM 순서를 기준으로 하지 않는다.
- PROJECTED_INDEX는 동일 `parent_id`를 공유하는 형제 노드 집합의 `order_int` 순서를 기준으로 계산한다.
- collapsed 상태, 필터링 상태, UI 가시성은 계산 기준이 될 수 없다.
- 실제 구조 변경은 PRD-012 Tree Engine Core의 `reorderSiblings` API를 통해서만 확정된다.
- numbering은 state에 저장되지 않으며, reorder는 numbering 계산에 직접 개입하지 않는다.
- PROJECTED_INDEX 계산은 반드시 **현재 활성 head_snapshot_id에 해당하는 TreeState**를 기준으로 수행한다.
- UI projection, optimistic local cache, DOM reflow 결과를 기준으로 계산해서는 안 된다.
- 드래그 중 계산은 read-only projection일 뿐이며, 구조적 확정은 Core API 호출 시점의 TreeState를 기준으로 재검증되어야 한다.
- 드롭 시점의 TreeState와 드래그 시작 시점의 TreeState가 다를 경우, Core API 호출 전 최신 head 기준으로 재계산되어야 한다.
- 이 재계산 단계는 PRD-041의 Optimistic Locking 정책과 모순되지 않아야 한다.
