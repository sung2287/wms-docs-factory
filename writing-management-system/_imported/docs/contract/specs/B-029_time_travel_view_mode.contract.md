# B-029: Time Travel View Mode Contract

## 1. Scope
- Definition of the read-only time travel mode behavior.
- Rules for draft state persistence during time travel.
- Constraints on actions allowed within Time Travel mode.

## 2. Non-goals
- Partial restoration of specific snippets (PRD-029 implies full snapshot restore).
- Merging draft with historical snapshot.

## 3. State Model
- **viewMode**: Enum { `ACTIVE_HEAD_MODE`, `TIME_TRAVEL_MODE` }.
- **timeTravelSnapshotId**: Valid snapshot ID when `viewMode === TIME_TRAVEL_MODE`.
- **activeDraft**: The in-memory state of the current workspace head (preserved).

## 4. Transitions
- **ENTER_TIME_TRAVEL**:
  - **Action**: Switch `viewMode` to `TIME_TRAVEL_MODE`.
  - **Pre-condition**: Valid `snapshotId` provided.
  - **Effect**: Editor becomes Read-Only. Render content from `timeTravelSnapshotId`. Draft state is NOT CLEARED.
- **EXIT_TIME_TRAVEL**:
  - **Action**: Switch `viewMode` to `ACTIVE_HEAD_MODE`.
  - **Effect**: Editor becomes Editable. Render content from `activeDraft` (or current head if no draft).
- **RESTORE_FROM_TIME_TRAVEL**:
  - **Action**: Confirm intent to restore the viewed snapshot.
  - **Effect**: Triggers the restore transaction defined in PRD-028.
  - **Post-condition**: Workspace head updates to the new snapshot. `viewMode` switches to `ACTIVE_HEAD_MODE` with the new snapshot as base.

## 5. Constraints
- **Read-only Enforcement**: In `TIME_TRAVEL_MODE`, all editing actions (typing, delete, create node) MUST be blocked.
- **Draft Preservation**: Entering Time Travel MUST NOT discard unsaved changes in the `ACTIVE_HEAD_MODE`.
- **Save Prohibition**: The "Save" action is disabled in `TIME_TRAVEL_MODE`.
- In TIME_TRAVEL_MODE, the displayed `snapshotId` MAY differ from the current `head_snapshot_id`.
- Entering or exiting TIME_TRAVEL_MODE MUST NOT change `head_snapshot_id`.
