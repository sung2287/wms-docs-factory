# B-050: Tree Reorder Controls Contract
**Status: Draft**

## 1. Canonical Action: TREE_REORDER_INTENT
All structural reorder operations MUST conform to this internal intent structure.

```typescript
interface TreeReorderIntent {
  node_id: string;          // Target node to move
  parent_id: string;        // Parent container ID (must match for siblings)
  from_index: number;       // Current index in Snapshot TreeState
  to_index: number;         // Target index in Snapshot TreeState
  base_snapshot_id: string; // Version ID at the start of the action
}
```

## 2. API Expectations
- **Method**: `PUT`
- **Endpoint**: `/api/workspaces/{workspace_id}` (Standard Workspace Save API).
- **Payload**: Full Snapshot including the mutated TreeState.
- **Append-only Strategy**: Every successful reorder MUST result in a new Snapshot record (PRD-025). The server appends the new state to the history; existing Snapshots MUST NOT be modified.

## 3. Error Surface: 409 Conflict
The system MUST detect state drift between the action trigger and the server persistence.

- **Detection**: Server-side comparison of `base_snapshot_id` in the request vs current `head_snapshot_id` in the database.
- **Response**: `409 Conflict` on mismatch.
- **Client Behavior**: Surface Conflict UI. No silent retries. "Override" means the client resubmits the state for a fresh atomic append on the current server head.

## 4. Integrity Constraints
- **Authority**: The `order_int` values in the immutable TreeState are the sole authority for sequence.
- **Sibling Validation**: If the `parent_id` of the node at `from_index` does not match the `parent_id` at `to_index`, the action MUST be aborted (Sibling-only constraint).
- **Core Mapping**: The intent MUST be mapped to `moveNode` using a calculated `new_order_int` derived from the Snapshot's `order_int` list.
