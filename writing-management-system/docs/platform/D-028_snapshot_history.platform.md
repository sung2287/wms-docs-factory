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
    1. Fetch `target_snapshot` from DB.
    2. Start Transaction.
    3. **INSERT**: New snapshot (S_new) with content of `target_snapshot`.
    4. **UPDATE**: Workspace `head_snapshot_id` = S_new.id.
    5. **Commit**.
    6. Return: New snapshot metadata.

## 4. State Synchronization
- Upon successful restore, the client MUST re-fetch the history list and update the `currentHead` in the local store.
- The UI should display the new snapshot ID and incremented count immediately.
