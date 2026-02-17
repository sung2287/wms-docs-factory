# C-050: Tree Reorder Controls Intent Map
**Status: Draft**

## 1. Intent Transformation Map
- **User Intent**: "Move this section up."
- **Trigger**: Up Button Click.
- **Action**: `TREE_REORDER_INTENT` calculation.
- **Core Transformation**: 
    1. Identify target index neighbors in the current TreeState.
    2. Calculate `new_order_int` (mid-point or increment).
    3. `TreeEngine.moveNode(state, { id: node_id, new_parent_id: parent_id, new_order_int: calculated_order_int })`.
    4. Normalization is an engine-internal responsibility (PRD-012) and not a UI-level concern.
- **Persistence**: Snapshot Append (Append-only).
- **Sync**: Full Page Reload (Stability-first).

## 2. Rationale: Snapshot as Authority
- **Avoidance of Drift**: DOM order is susceptible to browser-side inconsistencies. By calculating indices strictly from the `TreeState` in the current Snapshot, we ensure the intent matches the actual data model.

## 3. Rationale: Stability-first (Full Reload)
- **Elimination of Ghosting**: In v1, we prioritize data integrity. A full page reload after a successful save ensures that the client-side state is completely reset to the server's truth, preventing "ghost" states or complex optimistic reconciliation issues.

## 4. Rationale: Append-only Strategy
- Reordering is a structural change. By following the PRD-025 append-only principle, reorder actions are recorded as part of the `Snapshot History`. This allows users to use `Time Travel` (PRD-028) to revert an accidental reorder.
