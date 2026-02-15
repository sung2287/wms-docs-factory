# B-022: Node State Visualization Contract (v1)

## 1. Scope
- Definition of visual states for nodes in the Tree: UNLINKED, LINKED, and DIRTY.
- Rules for state transitions and visual indicators (icons).
- Definition of the `dirtySnippetIdSet` as a session-level auxiliary state.

## 2. Non-goals
- Permanent persistence of the DIRTY icons.
- Acting as the SSOT for save logic (handled by `isDirty` in PRD-024).

## 3. Definitions
- **UNLINKED**: A node that has no `linkedSnippetId`. Represents a task not yet started.
- **LINKED**: A node that has a valid `linkedSnippetId`. Represents a task in progress or completed.
- **DIRTY (Visual)**: A node that reflects an unsaved change in the current session.
  - **Trigger**: Content change events OR Workspace structural changes (move, reorder, link change, create/delete nodes).
  - Focus, selection, or cursor movement must NOT trigger DIRTY state.
- **dirtySnippetIdSet**: A set of Snippet IDs used exclusively for node-level ✏️ icon visualization. This is an auxiliary state and NOT the SSOT for save decisions.

## 4. State Calculation Rules
- **UNLINKED Status**: `if node.linkedSnippetId == null`
- **LINKED Status**: `if node.linkedSnippetId != null`
- **DIRTY Visual**: `if linkedSnippetId ∈ dirtySnippetIdSet`.
  - A node displays the ✏️ icon if its `linkedSnippetId` is in the `dirtySnippetIdSet`.

## 5. Acceptance Criteria
- **Visual Distinction**:
  - UNLINKED nodes display ⚠️ icon.
  - LINKED nodes display 🔗 icon.
  - Nodes with unsaved changes in their linked snippets display ✏️ icon.
- **Dirty Visualization Propagation**:
  - Modifying content in the Editor or changing tree structure adds relevant IDs to `dirtySnippetIdSet`.
  - The corresponding node reflects the DIRTY visual immediately.
- **State Resolution**:
  - Upon PRD-024 `saveWorkspace` success, the `dirtySnippetIdSet` must be cleared (batch clear).
  - The DIRTY icons must disappear from the Tree.

## 6. Constraints
- The `dirtySnippetIdSet` is a derived/auxiliary state for UI purposes. The global save state is governed by `WorkspaceStore.isDirty`.

---
### PRD-024 정합성 체크리스트
- [x] canSave/isDirty 정렬
- [x] statusMessage/isDirty 정렬
- [x] LOCKED 정책 포함
- [x] dirtySnippetIdSet은 보조 상태로만 남김
- [x] Save 성공/실패 시점의 상태전이가 PRD-024와 일치
