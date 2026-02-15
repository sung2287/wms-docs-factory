# C-029: Time Travel View Mode Intent Map

## 1. Scope
- Defining read-only time travel behavior.
- Clear separation between ACTIVE_HEAD_MODE and TIME_TRAVEL_MODE.

## 2. User-Visible Meaning

- Time Travel allows safe exploration of past snapshots.
- It does NOT change current state.
- It does NOT create new snapshots.
- It does NOT modify head.

## 3. Semantic Guarantees

- Read-only enforcement: editor must be non-editable.
- Save button must be hidden or disabled.
- No snapshot mutation allowed.
- Local draft state must not be overwritten when entering or exiting Time Travel.

## 4. Mode Separation

ACTIVE_HEAD_MODE:
- Editing enabled
- Save allowed
- Head snapshot active

TIME_TRAVEL_MODE(snapshot_id):
- Editing disabled
- Save disabled
- Viewing historical snapshot only

## 5. Restore Relationship

- Restore is an explicit action.
- Restore creates a new snapshot.
- After restore, system returns to ACTIVE_HEAD_MODE.
