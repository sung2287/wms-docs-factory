# C-022: Node State Visualization Intent Map

## 1. Intent-Reaction Mapping

| User Intent | UI Action / Trigger | System Reaction |
| :--- | :--- | :--- |
| **Track Progress** | Open Tree Explorer | Map all nodes to `VisualStatus`. Render icons. |
| **Identify Revisions**| Design Spec Changes | Background: `review_required` flips to true. Tree: `⚠️` icon appears. |
| **Confirm Save** | Auto-save Success | `isDirty` becomes false. `*` icon disappears. |
| **Finalize Section** | Mark as Completed | `writing_status` -> "completed", `review_required` -> false. Tree: `●` icon appears. |

## 2. Visualization Lifecycle
1. **Source Update:** A mutation occurs in the Node Tree or Session State.
2. **Re-calculation:** The `calculateVisualStatus` pure function is executed for the affected node.
3. **UI Sync:** The Tree Explorer node component re-renders with the appropriate icon and color.
