# D-044: Effective Design Preview Platform Design

## 1. Objective
Define the UI layout and rendering strategy for the Design Preview Panel within the Writing Workspace.

## 2. Component Architecture
- **Location:** A collapsible drawer or persistent sidebar on the right side of the Workspace.
- **Rendering:** Uses an accordion or categorized list to display the four main blocks of the PRD-036 schema:
    - **Constitution & Series/Volume Meta**
    - **Narrative Logic (Role, Purpose, Core Question)**
    - **Constraints (Forbidden & Cautions)**
    - **Style (Metaphors)**

## 3. Visualization Features
- **Origin Badges:** Each item (e.g., a forbidden keyword) should be tagged with its source level (e.g., `[V]` for Volume, `[P]` for Part).
- **Review Alert:** If `node.review_required` is true, render a persistent warning banner: `⚠️ The DesignSpec has changed. Please review your manuscript against the updated constraints.`

## 4. Performance & Memoization
- Since the hierarchy is stable during a writing session, the `Effective DesignSpec` should be memoized per `nodeId`.
- Re-compute only if the `Node Tree` is updated via a new snapshot or re-import.

## 5. Failure Handling
- If a node is orphaned (no ancestors found), display only the local node's `design_spec`.
- If `computeEffectiveDesignSpec` throws an error, show a "Failed to resolve design context" placeholder.
