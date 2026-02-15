# C-024: Workspace Save Model Refinement Intent Map

## 1. Scope
- Verification of Dirty state triggers.
- Validation of the Save lock-out mechanism.
- Confirmation of Revision updates.
- Testing of the Unload warning condition.

## 2. Non-goals
- Testing network latency simulation (Platform concern).
- Testing server-side storage format.

## 3. Scenarios & Expectations

### Scenario 1: Dirty Trigger - Content Edit
- **Given**: A clean workspace (`isDirty` = false).
- **When**: User modifies text in the Editor.
- **Expectation**: `isDirty` becomes `true`.

### Scenario 2: Dirty Trigger - Tree Structure
- **Given**: A clean workspace.
- **When**: User adds a new node to the Tree.
- **Expectation**: `isDirty` becomes `true`.

### Scenario 3: Save Operation - UI Locking
- **Given**: `isDirty` is true.
- **When**: User clicks Save.
- **Expectation**: 
  - `isSaving` becomes `true`.
  - Editor input becomes disabled/read-only.
  - Save button becomes disabled.

### Scenario 4: Save Operation - Success
- **Given**: A workspace with `rev` = 1, `isDirty` = true.
- **When**: Save completes successfully with server returning `rev` = 2.
- **Expectation**: 
  - `isSaving` becomes `false`.
  - `isDirty` becomes `false`.
  - Workspace `rev` updates to 2.
  - Editor becomes editable again.

### Scenario 5: Save Operation - Failure
- **Given**: `isDirty` is true.
- **When**: Save fails (e.g., network error).
- **Expectation**: 
  - `isSaving` becomes `false`.
  - `isDirty` remains `true`.
  - Workspace `rev` remains unchanged.
  - Editor becomes editable again.

### Scenario 6: Unload Warning
- **Given**: `isDirty` is true.
- **When**: User attempts to close the browser tab (`beforeunload` event).
- **Expectation**: The browser displays a confirmation dialog warning of unsaved changes.

### Scenario 7: No Auto-Save
- **Given**: `isDirty` is true.
- **When**: User waits for an arbitrary amount of time without clicking Save.
- **Expectation**: No save operation is initiated; `isDirty` remains true.
