# D-029: Time Travel View Mode Platform

## 1. Scope
- Implementation of the `TIME_TRAVEL_MODE` state.
- Separation of `activeDraft` and `timeTravelSnapshot` in the Workspace Store.
- Read-only enforcement in the UI layer.

## 2. Store Integration
- **State Properties**:
  - `viewMode: 'ACTIVE' | 'TIME_TRAVEL'`
  - `activeDraft: WorkspaceSnapshot` (Contains in-memory tree/snippets/metadata)
  - `timeTravelSnapshot: WorkspaceSnapshot | null`
  - `snapshotId: string` (Current displayed snapshot ID)
- **Draft Preservation**: When `ENTER_TIME_TRAVEL` is called, `activeDraft` remains in memory. The UI renders from `timeTravelSnapshot`.
- **Exit Logic**: `EXIT_TIME_TRAVEL` simply flips `viewMode` back to `ACTIVE`, causing the UI to re-render `activeDraft`.

## 3. Read-Only Components
- All editor and tree components must receive a `readOnly` prop based on `viewMode`.
- **Input Blocking**:
  - If `readOnly === true`, disable `onChange`, `onDrop`, `onKeyDown` handlers.
  - Disable toolbar buttons (Save, Delete, New Snippet).
  - Show a persistent banner: "Viewing Read-Only Snapshot".
- The Save action MUST NOT invoke the Save API when `viewMode === TIME_TRAVEL_MODE`.
- Platform layer must guard against accidental Save dispatch in TIME_TRAVEL_MODE.

## 4. Restore Integration
- The "Restore" button triggers the `EXECUTE_RESTORE` action (PRD-028).
- Upon success, the store:
  1. Updates `activeDraft` with the new snapshot content.
  2. Sets `viewMode` to `ACTIVE`.
  3. Clears `timeTravelSnapshot`.
