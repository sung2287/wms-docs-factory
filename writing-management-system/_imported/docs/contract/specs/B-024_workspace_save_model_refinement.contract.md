# B-024: Workspace Save Model Refinement Contract

## 1. Scope
- Definition of the "Memory-first + Explicit Save" persistence model.
- Rules for `isDirty` state transitions based on user actions.
- Behavior of the Save operation: Full Snapshot Replace.
- Revision (`rev`) management policy.
- Browser `beforeunload` integration.

## 2. Non-goals
- Partial updates or patch-based saving.
- Auto-save mechanisms.
- Multi-user conflict resolution.
- Snapshot internal structure optimization (PRD-025).
- Backup/Restore features (PRD-026).
- Schema migration (PRD-027).

## 3. Definitions
- **WorkspaceSnapshot**: The complete state of the workspace including the tree structure, snippet pool, and metadata.
- **isDirty**: A boolean flag indicating that a mutating user action has occurred since the last successful save.
- **isSaving**: A boolean flag indicating an active persistence operation.
- **rev**: A revision number managed by the server, incremented only upon successful save.

## 4. State Transition Rules

### 4.1. Dirty Logic (Action-based)
`isDirty` must transition to `true` upon:
- Tree structure changes (add/remove/move nodes).
- Snippet creation or deletion.
- Snippet content modification (`rawText` change).
- Node-Snippet linkage changes (`linkedSnippetId` update).

`isDirty` must transition to `false` upon:
- Successful completion of a Save operation.
- Initial load of the workspace.

### 4.2. Save Operation (Explicit)
- **Trigger**: User explicitly clicks the "Save" button.
- **Process**:
  1. Set `isSaving` to `true`.
  2. **Lock UI**: Disable all editing inputs and the Save button.
  3. **Execute**: Send the *entire* `WorkspaceSnapshot` to the persistence layer (PUT).
  4. **On Success**:
     - Update client-side `rev` to match the server response.
     - Set `isDirty` to `false`.
     - Set `isSaving` to `false`.
     - Unlock UI.
  5. **On Failure**:
     - Keep `isDirty` as `true`.
     - Set `isSaving` to `false`.
     - Unlock UI.
     - Display error feedback.

### 4.3. Unload Policy
- If `isDirty` is `true`, the system must intercept the `beforeunload` event to warn the user of potential data loss.

## 5. Acceptance Criteria
1. **Dirty Triggering**: Any content or structural edit immediately sets `isDirty` to `true`.
2. **Save Locking**: During the save process (`isSaving` = true), the editor and tree must be read-only.
3. **Full Replacement**: The save operation must transmit the full snapshot, not a delta.
4. **Rev Consistency**: The `rev` number must only increment on a successful save and must match the server's value.
5. **Unload Warning**: Closing the tab with unsaved changes triggers a browser warning.
6. **No Auto-save**: No background timers or event-driven saves occur.
