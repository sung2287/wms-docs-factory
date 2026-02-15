# B-028: Snapshot History Contract

## 1. Scope
- Definition of the Snapshot History view and interaction model.
- Rules for the "Restore" operation as a constructive action (append-only).
- State definitions for history listing and previewing.

## 2. Non-goals
- Snapshot difference (diff) calculation.
- Tagging or releasing snapshots.
- Garbage collection policies.

## 3. State Model
- **historyList**: Ordered list of Snapshot metadata (id, created_at, schema_version).
- **previewSnapshotId**: The ID of the snapshot currently being viewed (nullable).
- **isRestoring**: Boolean flag indicating an active restore operation.

## 4. Transitions
- **VIEW_HISTORY**: Loads `historyList` sorted by `created_at` DESC.
- **SELECT_PREVIEW**: Sets `previewSnapshotId`. Triggers read-only rendering of that snapshot.
- **CONFIRM_RESTORE**: User explicitly confirms the intent to restore.
- **EXECUTE_RESTORE**:
  - **Pre-condition**: `previewSnapshotId` is valid.
  - **Action**: Generates a *new* snapshot identical to the previewed one.
  - **Post-condition**: Workspace head points to the new snapshot. `snapshot_count` increments.

## 5. Constraints
- **Immutability**: Restoring a past snapshot MUST NOT modify the past snapshot record.
- **Append-only**: Restore MUST create a NEW snapshot record containing the data of the target snapshot.
- **Transaction**: The restore operation (insert new snapshot + update head) must be atomic.
- **Read-only Preview**: The preview view must strictly disallow any editing.

## 6. Failure Handling
- If `EXECUTE_RESTORE` fails, the workspace head MUST remain at its original position.
- No partial snapshot records should be created.
