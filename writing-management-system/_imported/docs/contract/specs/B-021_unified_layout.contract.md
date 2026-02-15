# B-021: Unified Layout Contract (v1)

## 1. Scope
- Definition of a 2-pane workspace layout consisting of a Tree Panel and an Editor Panel.
- Standardization of the interaction flow between node selection in the Tree and content display in the Editor.
- Contract for node-snippet linkage resolution and initial snippet creation UX.

## 2. Non-goals
- Persistence strategies for content changes (defined in PRD-024).
- Drag-and-drop tree reorganization.
- Rich text editor features.
- Layout persistence (storing pane widths in local storage).
- Responsive layout collapse behavior (reserved for future PRD).

## 3. Definitions
- **selectedNodeId**: The unique identifier of the currently active node in the Workspace.
- **linkedSnippetId**: A reference stored within a node pointing to a specific Snippet in the Snippet Pool.
- **Placeholder UI**: A state displayed in the Editor Panel when the selected node has no `linkedSnippetId`.
- TreeState updates must be immutable. Any update to linkedSnippetId must produce a new TreeState reference.

## 4. Acceptance Criteria
- **Layout Consistency**: The screen must be divided into a Tree Panel (left) and an Editor Panel (right) with a defined ratio (default 30:70).
- **Selection Synchronization**:
  - When a user selects a node, `selectedNodeId` must be updated.
  - The Editor Panel must reactively resolve and display the Snippet associated with `selectedNodeId`.
- **Linkage Resolution**:
  - If `linkedSnippetId` exists, display Snippet content.
  - If `linkedSnippetId` is null, display a "Snippet not linked" message and a "Create Snippet" button.
- **Snippet Creation**:
  - Clicking "Create Snippet" must generate a new Snippet.
  - The new Snippet's initial title should default to the selected Node's name.
  - The `linkedSnippetId` of the selected node must be updated immediately upon creation.

## 5. Failure / Error Handling
- **Node Not Found**: If `selectedNodeId` refers to a non-existent node, the Editor Panel must display a "Select a node" initial state.
- **Resolution Failure**: If `linkedSnippetId` refers to a missing Snippet, an error state or placeholder must be shown instead of crashing.
