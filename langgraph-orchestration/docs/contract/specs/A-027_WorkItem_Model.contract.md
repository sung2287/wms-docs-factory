# A-027 — WorkItem Model Contract
> WorkItem v1 Entity + State Machine + Transition Audit

## 1. Objective
WorkItem을 DecisionVersion(=decisions.id)에 영구 바인딩하여 “작업 진행/완료(VERIFIED)” 흐름을 감사 가능하게 기록한다.

## 2. Entity Contract (WorkItemV1)

### 2.1 Binding (LOCK)
- WorkItem.decision_id는 반드시 `decisions.id`(DecisionVersion UUID)에 바인딩된다.
- root_id 바인딩은 금지한다(Active 포인터 drift 방지).
- decision_id는 생성 후 변경 불가.

### 2.2 Status Space (LOCK)
WorkItem.status는 아래 상태 집합을 가진다(Forward slot 포함):
- PROPOSED
- ANALYZING
- DESIGN_CONFIRMED
- IMPLEMENTING
- IMPLEMENTED
- VERIFIED
- CLOSED

### 2.3 Transition Rule (LOCK)
- status overwrite는 예외적으로 허용한다(현재 상태 표시용).
- 모든 전이 이벤트는 `work_item_transitions`에 append-only로 기록한다(감사 SSOT).
- 임의 점프 금지: 정의된 전이 그래프 외 전이 불가.

### 2.4 Transition Graph (V1)
- PROPOSED → ANALYZING → DESIGN_CONFIRMED → IMPLEMENTING → IMPLEMENTED → VERIFIED → CLOSED

### 🔒 Binding Strictness

- WorkItem은 반드시 `decisions.id` (DecisionVersion UUID)에 바인딩된다.
- `root_id` 또는 active root 기반 바인딩은 금지한다.
- DecisionVersion active 포인터 변경은 WorkItem에 영향을 주지 않는다.
- WorkItem.decision_id는 생성 후 변경 불가(Immutable FK).

Rationale:
Decision은 versioned 구조이며, WorkItem은 특정 버전의 구현 상태를 추적한다.
root 단위 바인딩은 version drift를 유발할 수 있다.

### 🔒 Transition Log Integrity

- work_item_transitions는 append-only이다.
- 기존 transition row 수정/삭제는 금지된다.
- 상태 overwrite는 work_items.status 필드에 한해 허용되며,
  이 경우 반드시 transition log가 선행 기록되어야 한다.

## 3. Persistence Contract (SQLite)

### 3.1 Tables (V1)

work_items:
- id (UUID)
- decision_id (UUID, FK -> decisions.id, ON DELETE RESTRICT)
- domain (TEXT)
- status (TEXT, CHECK status space)
- created_at (TEXT or INTEGER)
- updated_at (TEXT or INTEGER)

work_item_transitions:
- id (UUID)
- work_item_id (UUID, FK -> work_items.id, ON DELETE RESTRICT)
- from_status (TEXT)
- to_status (TEXT)
- reason (TEXT) // human-readable
- actor (TEXT) // "system" | "user" | "enforcer" (optional)
- created_at

### 3.2 Indexes (REQUIRED)
- idx_work_items_decision_id
- idx_work_item_transitions_work_item_id

## 4. Invariants (LOCK)
- INV-1: WorkItem.decision_id 불변.
- INV-2: Transition log는 append-only.
- INV-3: WorkItem은 Decision/Atlas를 직접 수정 트리거할 수 없다(Dependency Direction 준수).
