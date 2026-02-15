# D-030: Save UX Enhancement Platform

## 1. Scope
- State model for the Save State Machine.
- Integration of `snapshotCount`, `snapshotId`, and `lastSavedAt` with the workspace store.
- Transient state (`SAVED` -> `IDLE`) logic.

## 2. Store Integration
- **State Properties**:
  - `saveState: 'IDLE' | 'DIRTY' | 'SAVING' | 'SAVED' | 'ERROR'`
  - `snapshotCount: number`
  - `snapshotId: string`
  - `lastSavedAt: number`

## 3. Save Workflow
- **Execute Save**:
  - If `viewMode !== 'ACTIVE'`, the Save action MUST abort without API call.
  1. Set `saveState` to `SAVING` (blocked UI).
  2. Call `D-025` Save API (Append-only).
  3. **Success**:
     - Receive: `newSnapshotId`, `newSnapshotCount`, `serverTimestamp`.
     - Update store with these values.
     - Set `saveState` to `SAVED`.
     - Schedule timeout (e.g., 2000ms) to reset `saveState` to `IDLE` (if no new edits).
  4. **Failure**:
     - Receive: Error message.
     - Set `saveState` to `ERROR`.
     - Retain unsaved changes in store.

## 4. UI Rendering
- **Status Bar**: Always render `snapshotCount` and `snapshotId`. If `saveState === SAVING`, show loading indicator.
- **Button**: Disable if `IDLE` or `SAVING`. Enable if `DIRTY` or `ERROR`.
