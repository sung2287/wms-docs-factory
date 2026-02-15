# B-023: Save UX Contract (v1)

## 1. Scope
- Definition of the Save button behavior in the Top Bar.
- Contract for save states: `isSaving`, `lastSavedAt`, and `canSave`.
- Standardization of feedback mechanisms (Toasts/Status Messages) after save operations.
- Implementation of the LOCKED policy during persistence.

## 2. Non-goals
- Auto-save implementation (scheduled or debounced).
- Version history or undo/redo persistence UI.
- Handling partial saves (v1 assumes "Workspace Save" as an atomic unit).

## 3. Definitions
- **isSaving**: Boolean flag indicating an ongoing save operation. Prevents concurrent save calls.
- **lastSavedAt**: Timestamp (Date or null) of the last successful save operation.
- **isDirty**: Boolean flag (SSOT) indicating that mutating user actions have occurred since the last save.
- **canSave**: Computed boolean: `!isSaving && isDirty`.
- **saveStatusMessage**: User-facing string:
  - `isDirty === false` => "All changes saved"
  - `isDirty === true` => "Unsaved changes"
- **LOCKED Policy**: A state during `isSaving === true` where:
  - Editor is read-only or disabled.
  - Tree operations (move, reorder, add, delete nodes) are disabled.

## 4. Save Execution Contract
- **Trigger**: User clicks "Save" button while `canSave` is true.
- **Process**:
  1. Set `isSaving` to true.
  2. **Apply LOCKED Policy**: Disable editing and tree manipulations.
  3. Invoke `IStorageAdapter.saveWorkspace(workspaceData)`.
     - **Mechanism (PRD-025)**: Create a new Snapshot record (append-only) and update the Workspace head reference. No overwrite of existing snapshots.
- **On Success**:
  1. Set `isDirty` to false.
  2. Clear `dirtySnippetIdSet` (optional UI derived state).
  3. **Data Update**: Reflect server response containing:
     - `new_snapshot_id`
     - `updated_head_snapshot_id`
     - `rev` (incremented)
     - `updatedAt`
  4. Update `lastSavedAt` to current timestamp.
  5. Display "Success" feedback (Toast).
- **On Failure**:
  1. Maintain `isDirty` as true.
  2. Maintain `dirtySnippetIdSet`.
  3. Display "Error" feedback (Toast).
- **Finally**:
  1. Set `isSaving` to false.
  2. **Release LOCKED Policy**: Re-enable editing and tree manipulations.

## 5. Acceptance Criteria
- **Button State**: The Save button must be disabled when `isDirty` is false or `isSaving` is true.
- **LOCKED Enforcement**: Users must not be able to type in the editor or reorder the tree while `isSaving` is true.
- **Feedback**:
  - Show "Saving..." or similar during the process.
  - Provide immediate visual confirmation upon success.
- **Persistence Strategy**: Saving must result in a new snapshot entry rather than a mutation of the current head.

## 6. Constraints
- The `isDirty` flag is the Single Source of Truth for the save availability.
- The Save operation is treated as an atomic action at the Workspace level for v1.

---
### 정합성 체크리스트
- [x] canSave/isDirty 정렬 유지
- [x] LOCKED 정책 포함 유지
- [x] 저장 API 동작이 append-only임을 명시 (new snapshot 생성 + head 갱신)
- [x] 응답 필드 명시 (new_snapshot_id, head_snapshot_id 등)
