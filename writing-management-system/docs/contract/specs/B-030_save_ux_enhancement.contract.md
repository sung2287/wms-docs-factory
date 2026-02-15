# B-030: Save UX Enhancement Contract

## 1. Scope
- State model for the Save State Machine (Idle, Dirty, Saving, Saved, Error).
- Integration of the status bar showing snapshot count and last saved time.
- Implementation of the "Saved" transient state logic.

## 2. Non-goals
- Partial save operations.
- Undo/Redo of local edits (managed by editor state, not save state).

## 3. State Model
- **saveState**: Enum { `IDLE`, `DIRTY`, `SAVING`, `SAVED`, `ERROR` }.
- **snapshotCount**: Integer (Total number of snapshots).
- **snapshotId**: Current snapshot ID (HEAD).
- **lastSavedAt**: Timestamp.

## 4. Transitions
- **USER_EDIT**: `IDLE` -> `DIRTY` or `SAVED` -> `DIRTY` (if transient).
- **TRIGGER_SAVE**: `DIRTY` -> `SAVING`.
- **SAVE_SUCCESS**: `SAVING` -> `SAVED`.
  - **Effect**: Updates `snapshotId`, `snapshotCount`, `lastSavedAt`.
  - **Post-condition**: Transient timeout clears `SAVED` to `IDLE` after X seconds.
- **SAVE_FAILURE**: `SAVING` -> `ERROR`.
  - **Effect**: Displays error message. Retains `DIRTY` flag internally (or allows retry).

## 5. Constraints
- **Save Blocking**: While `saveState === SAVING`, user input MUST be blocked (LOCKED policy).
- **Immediate Feedback**: `snapshotCount` and `snapshotId` MUST update immediately upon successful API response.
- **Dirty Persistence**: If `SAVE_FAILURE` occurs, the `DIRTY` state and unsaved changes MUST remain intact.
