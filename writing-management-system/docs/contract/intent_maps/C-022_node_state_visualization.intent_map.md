# C-022: Node State Visualization Intent Map

## 1. Scope
- Verification of ⚠️, 🔗, ✏️ icon rendering.
- Validation of visualization triggers (content vs structural changes).
- Confirmation of icon removal upon PRD-024 save success.

## 2. Non-goals
- Testing persistence of the icons across sessions.

## 3. Scenarios & Expectations

### Scenario 1: Initial State Rendering
- **Given**: Node A (linked) and Node B (unlinked).
- **When**: Tree renders.
- **Expectation**: Node A shows 🔗, Node B shows ⚠️.

### Scenario 2: Transition to DIRTY - Content Edit
- **Given**: Node A is selected.
- **When**: User modifies text in the Editor.
- **Expectation**: 
  - `isDirty` becomes `true`.
  - Node A's `linkedSnippetId` is added to `dirtySnippetIdSet`.
  - Node A in Tree shows ✏️ icon.

### Scenario 3: Transition to DIRTY - Tree Reorder (Structure Change)
- **Given**: Node A and Node C are in the tree.
- **When**: User changes the order of Node A and Node C.
- **Expectation**: 
  - `isDirty` becomes `true` (as per PRD-024 action-based logic).
  - (Optional) Related node IDs added to `dirtySnippetIdSet`.
  - Relevant nodes show ✏️ icon to indicate unsaved structural change.

### Scenario 4: Save and DIRTY Resolution
- **Given**: Node A and Node C show ✏️ icons.
- **When**: User clicks Save and operation succeeds (PRD-024 saveWorkspace success).
- **Expectation**: 
  - `isDirty` becomes `false`.
  - `dirtySnippetIdSet` is cleared (batch clear).
  - All ✏️ icons are removed from the Tree.

### Scenario 5: Multiple DIRTY Nodes
- **Given**: Node A and Node C have unsaved changes.
- **When**: Looking at the Tree.
- **Expectation**: Both show ✏️ icons based on their presence in `dirtySnippetIdSet`.

---
### PRD-024 정합성 체크리스트
- [x] canSave/isDirty 정렬
- [x] statusMessage/isDirty 정렬
- [x] LOCKED 정책 포함
- [x] dirtySnippetIdSet은 보조 상태로만 남김
- [x] Save 성공/실패 시점의 상태전이가 PRD-024와 일치
