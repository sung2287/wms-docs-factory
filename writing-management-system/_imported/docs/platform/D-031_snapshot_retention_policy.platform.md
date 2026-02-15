# D-031: Snapshot Retention Policy Platform

## 1. Core Service
- **Action**: `RetentionService.execute(workspace_id, N)`
- **Constraint**: Must be triggered explicitly (CLI/Admin). No auto-GC or UI exposure in v1.

## 2. Input Validation
- `workspace_id` exists in the database.
- `N ≥ 1`.

## 3. Query Pattern (Transactional)
The service must perform the following steps within a single transaction:

1. **Get Current Head**: `SELECT head_snapshot_id FROM workspaces WHERE id = ?`
2. **Get Latest N IDs**: 
   ```sql
   SELECT id FROM snapshots 
   WHERE workspace_id = ? 
   ORDER BY created_at DESC 
   LIMIT ?
   ```
3. **Compute Protected IDs**: `{head_snapshot_id} ∪ {ids from step 2}`
4. **Head Guard (Pre-commit Check)**: 
   - If `head_snapshot_id` has changed since the initial read, the transaction MUST abort and rollback.
   - The retention process MUST NOT recompute and continue within the same transaction.
   - Retry must be triggered externally.
5. **Delete**:
   ```sql
   DELETE FROM snapshots 
   WHERE workspace_id = ? 
   AND id NOT IN ([Protected IDs])
   ```

## 4. Optimization & Consistency
- **Index Recommendation**: A composite index on `(workspace_id, created_at DESC)` is essential for performant Top-N selection.
- **Count Synchronization**: Recalculate or decrement the total `snapshot_count` for the workspace upon successful commit.

---
### 정합성 체크리스트
- [x] 쿼리 패턴 (Head 조회 -> Top N 조회 -> 삭제) 및 단일 트랜잭션 명시.
- [x] 커밋 전 Head 존재 여부 및 변경 여부 재확인(Head Guard) 포함.
- [x] (workspace_id, created_at DESC) 복합 인덱스 권장 사항 포함.
- [x] v1에서는 자동 트리거/UI 노출 없이 명시적 실행만 허용함을 명시.
