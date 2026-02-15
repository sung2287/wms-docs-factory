# D-028: Snapshot History Platform

## 1. Scope
- API endpoints for listing and fetching snapshots.
- Transactional implementation of the Restore operation.
- State synchronization logic.

## 2. API Endpoints
- **List History**: `GET /workspaces/:id/history`
    - Returns metadata (id, created_at, schema_version) for all snapshots, ordered DESC.
- **Get Snapshot**: `GET /snapshots/:id`
    - Returns full content (payload_json) for a single snapshot.
    - Used for read-only preview.

## 3. Restore Transaction
- **Endpoint**: `POST /workspaces/:id/restore`
    - Body: `{ snapshot_id: <target_snapshot_id> }`
- **Logic**:
    1. Capture `original_head_id` (read `workspaces.head_snapshot_id`).
    2. Fetch `target_snapshot` from DB.
    3. Start Transaction.
    4. **INSERT**: New snapshot (S_new) with content of `target_snapshot`.
    5. **UPDATE** workspace head using CONDITIONAL UPDATE:
       ```sql
       UPDATE workspaces
       SET head_snapshot_id = :s_new_id
       WHERE id = :workspace_id AND head_snapshot_id = :original_head_id;
       ```
    6. **Commit** only if `affected_rows == 1`. Otherwise, the transaction MUST abort/rollback (head changed concurrently).
    7. **Return**: New snapshot metadata.
- **Safety**: No silent overwrite of the head is allowed.

## 4. State Synchronization
- Upon successful restore, the client MUST re-fetch the history list and update the `currentHead` in the local store.
- The UI should display the new snapshot ID and incremented count immediately.
