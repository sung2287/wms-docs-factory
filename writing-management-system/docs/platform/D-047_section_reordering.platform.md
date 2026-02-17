# D-047: Section Reordering Platform Design

## 1. UI Feedback for Cascading Changes
- **Visual Alert:** When a reparenting move is attempted, show a non-blocking toast: *"Moving this subtree will require a review of completed sections due to design inheritance changes."*
- **Auto-Expansion:** Highlight the target parent and auto-expand after 500ms hover.

## 2. Recursive Key Generation Implementation
- The platform must implement a deterministic key generation utility that derives `external_key` from the parent's key and the node's `title_hint` or `index`.
- This utility must be used during the `Move` operation to prepare the update payload.

## 3. State Synchronization
- **Optimistic UI:** Tree Explorer updates immediately.
- **Background Task:** Key regeneration and review flagging should be computed locally first, then synced to the backend to avoid UI lag.

## 4. Constraints
- **Locking:** While a structural move is in progress, editing of nodes within that subtree should be temporarily disabled to prevent merge conflicts.
