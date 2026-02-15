# C-030: Save UX Enhancement Intent Map

## 1. Scope
- Verify the Save State Machine (Idle -> Dirty -> Saving -> Saved).
- Validate status bar info update (Snapshot ID/Count, Last Saved Time).
- Save is disabled in TIME_TRAVEL_MODE (read-only); saving is only allowed in ACTIVE_HEAD_MODE.

## 2. Scenarios & Expectations

### Scenario 1: Idle State
- **Given**: A workspace with no unsaved changes.
- **When**: Viewing the Save Button.
- **Expectation**: Button is `IDLE` (disabled or checkmark). Status bar shows "Last saved at [time]".

### Scenario 2: Edit to Dirty
- **Given**: Workspace is `IDLE`.
- **When**: User modifies a snippet.
- **Expectation**:
  - Button state becomes `DIRTY`.
  - "Unsaved changes" indicator appears.
  - Status bar might show a `*` or similar.

### Scenario 3: Trigger Save
- **Given**: Workspace is `DIRTY`.
- **When**: User clicks Save.
- **Expectation**:
  - Button state becomes `SAVING` (Spinner).
  - Editor input is BLOCKED.

### Scenario 4: Save Success
- **Given**: Save completes successfully.
- **When**: API returns new snapshot ID (e.g., S2).
- **Expectation**:
  - Button state becomes `SAVED` (e.g., "Saved!").
  - `snapshotId` updates to S2.
  - `snapshotCount` increments (e.g., 2).
  - Last saved time updates.
  - After timeout, button returns to `IDLE`.
  - Editor input is UNBLOCKED.

### Scenario 5: Save Failure
- **Given**: Save fails.
- **When**: API returns error.
- **Expectation**:
  - Button state becomes `ERROR`.
  - Error toast appears.
  - `DIRTY` state remains internally (button might allow retry).
  - Editor input is UNBLOCKED.
