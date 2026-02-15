# C-021: Unified Layout Intent Map

## 1. Scope
- Verification of the integration between Tree navigation and Editor display.
- Validation of the "Select-to-View" and "Create-to-Link" flows.

## 2. Non-goals
- Testing persistence logic or database synchronization.
- Testing CSS animations or layout resizing.

## 3. Scenarios & Expectations

### Scenario 1: Select Node with Linked Snippet
- **Given**: A workspace where Node A is linked to Snippet S1.
- **When**: User clicks on Node A.
- **Expectation**: `selectedNodeId` becomes Node A ID, and the Editor Panel displays the content of Snippet S1.

### Scenario 2: Select Node without Linked Snippet
- **Given**: A workspace where Node B has no `linkedSnippetId`.
- **When**: User clicks on Node B.
- **Expectation**: `selectedNodeId` becomes Node B ID, and the Editor Panel displays the Placeholder UI with a "Create Snippet" button.

### Scenario 3: Create Snippet from Node
- **Given**: Node B is selected and has no `linkedSnippetId`.
- **When**: User clicks "Create Snippet" button.
- **Expectation**: 
  - A new Snippet is created with the title of Node B.
  - Node B's `linkedSnippetId` is updated to the new Snippet's ID.
  - The Editor Panel immediately switches from Placeholder UI to the Editor for the new Snippet.
  - The update must not mutate existing TreeState references (structural sharing expected).

### Scenario 4: Switching Nodes
- **Given**: Node A (with snippet) is selected.
- **When**: User clicks on Node B (with snippet).
- **Expectation**: The Editor content updates from Snippet A to Snippet B without unnecessary screen flashing or loss of selection state in the tree.
