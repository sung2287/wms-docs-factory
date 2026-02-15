# B-031: Snapshot Retention Policy (Core Only) Contract

## 1. Scope
- Formal definition of the snapshot retention (cleanup) policy for workspaces.
- Logic for determining protected snapshots versus deletable candidates.
- Constraints for transactional and concurrency safety during deletion.

## 2. State Model
- **snapshots**: `(workspace_id, id, created_at, payload_json, schema_version)`
- **workspace**: `(id, head_snapshot_id)`

## 3. Definitions

### 3.1 ProtectedSet
The set of snapshots that MUST NOT be deleted.
`ProtectedSet(workspace_id, N) = { head_snapshot_id } ∪ TopNSnapshots(workspace_id, N)`
- `TopNSnapshots`: The latest `N` snapshots belonging to the `workspace_id`, ordered by `created_at` DESC.

### 3.2 DeletionCandidates
The set of snapshots eligible for removal.
`DeletionCandidates(workspace_id, N) = { snapshots matching workspace_id } \ ProtectedSet(workspace_id, N)`
- **Invariant**: `head_snapshot_id` MUST NOT appear in `DeletionCandidates`.

## 4. Contract Rules
- **Snapshot Immutability**: Retention MUST NOT modify the content (`payload_json`) or any metadata of existing snapshots.
- **No Side Effects**: Retention MUST NOT change the `head_snapshot_id` or create new snapshots.
- **Transactional Integrity**: The entire deletion process for a workspace MUST occur within a single transaction.
- **Rollback Guarantee**: If the operation fails, no partial deletions must occur.
- **Concurrency Safety**: The process must re-validate the current `head_snapshot_id` immediately before the final commit to ensure it hasn't changed during the calculation.
- **Idempotency**: Running retention multiple times with the same parameters on the same state results in no further changes.

## 5. Acceptance Criteria
- All snapshots outside ProtectedSet MUST be deleted.
- After successful execution, only snapshots in ProtectedSet remain.
- The `head_snapshot_id` remains valid and accessible.
- The most recent `N` snapshots remain accessible in the History list.
- If the transaction fails, the snapshot count and history remain unchanged.

---
### 정합성 체크리스트
- [x] head_snapshot_id가 DeletionCandidates에 포함되지 않음을 명시함.
- [x] Snapshot Immutability 및 Append-only 원칙 준수 확인.
- [x] 단일 트랜잭션 및 원자성 요구사항 포함.
- [x] 커밋 전 Head 재검증(Concurrency Rule) 반영.
