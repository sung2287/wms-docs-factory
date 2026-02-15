# C-031: Snapshot Retention Policy Intent Map

## 1. Scope
- Defining the user-visible meaning of history finiteness.
- Clarifying safety and stability guarantees.

## 2. User-Visible Meaning
- **Finite History**: While the system is append-only, history is finite by policy. This is an operational necessity, not a bug.
- **Data Preservation**: Retention is not a "history rewrite" or "overwrite." It is the pruning of old, non-current records.

## 3. Semantic Guarantees
- **Time Travel Bound**: Time Travel (PRD-029) only guarantees access to snapshots that exist. Its scope is naturally bounded by the retention policy.
- **Operational Stability**: Retention prevents unbounded storage growth without corrupting the meaning of the workspace.
- **Safety**: Retention MUST NOT invalidate the Restore logic (PRD-028) because Restore creates a new snapshot (the new head), which is automatically protected.

## 4. Anti-Confusion Guardrails
- **Retention is not Save**: Executing retention doesn't represent a new document version; it is a maintenance task.
- **No Current State Change**: Retention does not alter the editor content, tree, or dirty state.

---
### 정합성 체크리스트
- [x] 리텐션이 저작(Save) 행위가 아니며 현재 상태를 변경하지 않음을 명확히 함.
- [x] 타임 트래블 가용 범위가 리텐션 정책에 귀속됨을 명시함.
- [x] 리텐션 수행이 리스토어(Restore) 로직을 파괴하지 않음을 확인.
