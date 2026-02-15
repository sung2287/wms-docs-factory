# D-021: Unified Layout Platform Implementation

## 1. Scope
- Implementation sketch for the 2-pane layout.
- State store structure for selection management.
- Rendering optimization strategy.

## 2. Non-goals
- Finalizing the storage adapter implementation.
- Implementing drag-and-drop resizing (reserved for future).

## 3. UI Composition
- **MainLayout**: A container using CSS Flexbox or Grid.
  - `display: flex; height: 100vh;`
- **TreePanel**: `flex: 0 0 30%; overflow-y: auto; border-right: 1px solid #ccc;`
- **EditorPanel**: `flex: 1; overflow-y: auto;`
- **TopBar**: Fixed height at the top, spanning both panels or just the editor (as per PRD sketch, spans both).

## 4. State Management (Proposed)
- **Store**: `WorkspaceStore`
  - `selectedNodeId: string | null`
- **Selectors**:
  - `selectCurrentSnippet`: Resolves the snippet by looking up `selectedNodeId` -> `treeState` -> `linkedSnippetId` -> `snippetPool`.

## 5. Rendering Optimization
- **TreeNode Memoization**: Each `TreeNode` component should be wrapped in `React.memo` (or equivalent) to prevent re-rendering the entire tree when `selectedNodeId` changes. Only the previously selected and newly selected nodes should re-render.
- **Editor Decoupling**: The Editor Panel should subscribe to the `selectedNodeId` and its resolved snippet data, ensuring it only updates when the selection actually points to a different snippet or content changes.

## 6. Interaction Logic
- **Selection**: `onClick` on a TreeNode dispatches `SET_SELECTED_NODE(id)`.
- **Snippet Creation**: `handleCreateSnippet` dispatches `CREATE_SNIPPET_FOR_NODE(nodeId)`. This action:
  1. Generates a new ID and Snippet object.
  2. Updates `snippetPool`.
  3. Updates the specific node in `treeState`.
  4. (Optionally) keeps the selection on the same node.
  - All updates to treeState and snippetPool must follow immutable update patterns.
  - No in-place mutation is allowed.
  - After snippet creation, selectedNodeId must remain unchanged to ensure consistent editor focus.
