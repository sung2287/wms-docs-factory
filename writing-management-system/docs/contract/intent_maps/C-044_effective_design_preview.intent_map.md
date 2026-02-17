# C-044: Effective Design Preview Intent Map

## 1. Objective
Map user navigation and system state changes (like design re-imports) to the refreshing of the Design Preview Panel.

## 2. Intent-Reaction Mapping

| User Intent | Trigger / UI Action | System Reaction |
| :--- | :--- | :--- |
| **Review Context** | Select Node (Tree) | Fetch ancestor path. `computeEffectiveDesignSpec`. Render Panel. |
| **Verify Compliance**| View Panel | Display "Review Required" banner if `node.review_required === true`. |
| **Inspect Rule Source**| Hover Rule Item | Show tooltip/badge indicating the origin node (e.g., "From: Volume 1"). |
| **Manage Cognitive Load**| Click Category Header| Collapse/Expand spec groups (Constitution, Constraints, Style). |

## 3. Panel Update Lifecycle
1.  **Event:** Node `A` is selected in the Tree Explorer.
2.  **Action:** Writing Workspace fetches the full path from Root to `A`.
3.  **Calculation:** `computeEffectiveDesignSpec` generates the visual model.
4.  **Display:** Panel renders categorized sections. If `review_required` is true, the "Design Changed" alert is injected at the top.
