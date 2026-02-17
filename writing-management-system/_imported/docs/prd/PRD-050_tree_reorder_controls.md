# PRD-050: Tree Reorder Controls v1 (Button-Based Canonical Execution Path)
**Status: Draft**

## 1. Objective
Establish the canonical execution path for tree node reordering within the Writing Management System (WMS). This document defines the core logic, state transitions, and interaction rules for reordering sibling nodes via UI controls (Up/Down buttons), ensuring a stability-first architecture that serves as the foundation for all reorder UX (including drag-and-drop).

## 2. In Scope (v1 LOCKED)
- **Sibling-only Reorder**: Moving a node exactly one position up or down within the same `parent_id`.
- **Button-based Controls**: Discrete "Up" and "Down" buttons per node.
- **Canonical Action Contract**: Definition of the shared intent object (`TREE_REORDER_INTENT`) used by all reorder triggers.
- **Stability-first UI Refresh**: Full page reload upon successful server synchronization (200 OK) and local state resolution.
- **Conflict Handling**: Explicit resolution of version mismatches (409 Conflict) based on Snapshot IDs.

## 3. Out of Scope
- **Reparenting**: Moving nodes between different parents or changing hierarchy levels.
- **Drag-and-Drop UX**: Defined in PRD-048 (which will consume the action defined here).
- **Partial Rerendering**: Optimistic UI or partial DOM updates without reload (v2).
- **Multi-node selection**: Reordering multiple nodes simultaneously.

## 4. Canonical Execution Flow
1. **Trigger**: User clicks "Up" or "Down" button.
2. **Intent Construction**: System maps the action to a `TREE_REORDER_INTENT`. Indices (`from_index`, `to_index`) are calculated based on the current **active Snapshot's TreeState** (Authoritative source).
3. **Core Mutation**: 
    - Calculate the target `new_order_int` based on the neighbors of the `to_index` within the current TreeState.
    - Invoke PRD-012 `moveNode(state, { id, new_parent_id, new_order_int })`.
    - Order normalization MUST follow PRD-012 internal guarantees. Client code MUST NOT invoke reorderSiblings redundantly if moveNode already ensures correct sibling ordering.
4. **State Transition**: Set `isDirty = true` in WorkspaceState.
5. **Autosave**: PRD-042 2-second debounce triggers a `PUT` request with the full Snapshot.
6. **Finalization**: 
    - Server responds 200 OK.
    - Client updates `rev` from the server response.
    - `isSaving` is set to `false` and `isDirty` is cleared.
    - **THEN**, trigger a full page reload to synchronize the client with the new Server Head.

## 5. UI & Interaction Rules
- **Boundary Behavior**:
    - **Up Button**: Disabled if the node is the first child of its parent.
    - **Down Button**: Disabled if the node is the last child of its parent.
- **Saving State**: All reorder controls MUST be disabled while an autosave is in progress (no queueing/buffering of multiple reorders).
- **Index Authority**: All indices MUST be computed from the current head TreeState sibling list ordered by `order_int`. DOM order is considered a projection and MUST NOT be used for calculation.

## 6. Conflict & Error Policy (PRD-041 Alignment)
- **Snapshot Integrity**: The Save request MUST include the `base_snapshot_id`.
- **409 Conflict Handling**: If `base_snapshot_id != head_snapshot_id` on the server:
    - Block the mutation/save.
    - Transition UI to **Conflict State**.
    - Present explicit user choices: **Refresh** (Discard local reorder) or **Override** (Append as a new Snapshot).

## 7. Relationship to PRD-048
PRD-050 defines the **Canonical Execution Path**. PRD-048 (Drag Handle UX) MUST call the same `TREE_REORDER_INTENT` defined in this document once a drop is validated, ensuring consistent core logic regardless of the UI trigger.

## 8. Acceptance Criteria
- Clicking "Up" moves the node exactly one position up among siblings via `moveNode` and triggers autosave.
- Buttons are disabled at boundaries (first/last node).
- Controls are disabled during the saving process.
- Reload occurs only after 200 OK, `rev` update, and clearing of saving/dirty states.
- Version mismatch triggers the 409 Conflict UI as defined in PRD-041.
