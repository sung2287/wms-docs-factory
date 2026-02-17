# D-050: Tree Reorder Controls Platform
**Status: Draft**

## 1. Execution Path (Server-Rendered Baseline)
The reorder flow follows a strictly sequential, non-optimistic path:

1. **Capture**: Capture click event on the client.
2. **Calculate**: Compute indices and the subsequent `new_order_int` using the locally held Snapshot's TreeState.
3. **Mutate**: Apply `moveNode` to the local immutable tree reference.
4. **Register**: Mark `isDirty = true` in the global state registry.
5. **Autosave**: PRD-042 Autosave debounce (2s) initiates the network request.
6. **Lock**: Disable all reorder buttons during the `PUT` request pending state.

## 2. Refresh Mechanism
Reload MUST occur only after the following conditions are met:
1. Server returns `200 OK`.
2. Client `rev` (revision) is updated from the server response.
3. `isSaving` is set to `false`.
4. `isDirty` is cleared.

Once verified, trigger `window.location.reload()`. This prevents race conditions between the save finalization and the page refresh.

## 3. Conflict UI Requirement
When a `409 Conflict` is received:
- The platform MUST display an explicit modal or overlay.
- **Refresh Action**: Discards local changes and reloads the page to match the current Server Head.
- **Override Action**: The client resubmits the current local Snapshot after explicit user approval. The server performs an atomic comparison and appends a NEW snapshot on top of the latest head. "Override" is a new append operation and never a direct replacement of the existing head Snapshot record.

## 4. Observability
- All `TREE_REORDER_INTENT` calls and subsequent `moveNode` parameters should be logged (node_id, new_order_int, base_snapshot_id) to provide a clear audit trail for structural integrity issues.
