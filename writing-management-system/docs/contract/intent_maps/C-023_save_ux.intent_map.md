# C-023: Save UX Intent Map

## 1. Scope
- Verification of Save button activation based on the `isDirty` flag.
- Validation of UI locking during the save process.
- Confirmation of state updates (isDirty, rev, head_snapshot_id) upon save completion via append-only creation.

## 2. Non-goals
- Testing internal database constraints.

## 3. Scenarios & Expectations

### Scenario 1: Initial/Clean State
- **Given**: A workspace with `isDirty = false`.
- **When**: Looking at the Top Bar.
- **Expectation**: 
  - Save button is disabled.
  - Status message says "All changes saved".

### Scenario 2: Modification Trigger (Content or Structure)
- **Given**: `isDirty = false`.
- **When**: User modifies snippet text OR reorders tree nodes.
- **Expectation**: 
  - `isDirty` becomes `true`.
  - Save button becomes enabled (`canSave` is true).
  - Status message changes to "Unsaved changes".

### Scenario 3: Successful Save Execution (LOCKED Policy)
- **Given**: `isDirty = true`.
- **When**: User clicks "Save".
- **Expectation**: 
  - `isSaving` becomes `true`.
  - Editor becomes read-only; Tree reordering is disabled.
  - **Action**: A new Snapshot is created and Workspace head is updated (no data overwrite).
  - (Success) -> `isDirty` becomes `false`.
  - `dirtySnippetIdSet` is cleared.
  - Status message returns to "All changes saved".
  - `isSaving` becomes `false`; Editor and Tree are unlocked.

### Scenario 4: Failed Save Execution
- **Given**: `isDirty = true`.
- **When**: User clicks "Save" and the API fails.
- **Expectation**: 
  - Error message is displayed.
  - `isDirty` remains `true`.
  - `dirtySnippetIdSet` is NOT cleared.
  - Save button remains enabled.
  - `isSaving` becomes `false`; Editor and Tree are unlocked.

### Scenario 5: Prevent Concurrent Save
- **Given**: `isSaving = true`.
- **When**: User clicks the Save button again.
- **Expectation**: 
  - No additional save call is executed.
  - Save button remains disabled/loading.

---
### 정합성 체크리스트
- [x] 저장의 의도가 "새로운 상태를 확정(Append)"하는 것임을 명시
- [x] isDirty 기반 시나리오 유지
- [x] LOCKED 정책 검증 포함 유지
- [x] 중복 클릭 방지 로직 유지
