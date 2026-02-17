# B-047: Section Reordering Contract

## 1. Objective
Define the logic for manipulating the node hierarchy, ensuring structural integrity, recursive metadata updates (Cascading), and design compliance tracking (Review Propagation).

## 2. Structural Operations

### 2.1 Move Node Operation (Reparenting)
- **Input:** `nodeId`, `newParentId`, `newPosition`.
- **Validation:**
    - Cyclic Prevention: Target cannot move into its own descendant.
    - Leaf Constraint: Cannot move a node under a `Section` type node.
- **Logic:**
    1. Remove `nodeId` from the current parent's `children`.
    2. Insert `nodeId` into `newParentId`'s `children` at `newPosition`.
    3. **Subtree Cascading (Recursive):** Regenerate `external_key` for the moved node and ALL its descendants based on the new path.
    4. **Review Propagation:** Set `review_required: true` for the moved node and ALL its descendants that have `writing_status: "completed"`.

### 2.2 Reorder Siblings
- **Input:** `parentId`, `nodeId`, `newPosition`.
- **Logic:** Adjust `order_int` or index within the same `children` array. No cascading or propagation required.

## 3. Atomic Identity & Transaction
- **Stable Identity:** `node_id` MUST remain unchanged.
- **Atomic Transaction:** Reparenting, key regeneration, and review flag updates MUST be committed as a single Snapshot.

## 4. Edge Cases
- **Move to Series Root:** Permitted only for Volume-type nodes.
- **External Key Conflict:** If regenerated key exists, append a unique suffix (deterministic).
