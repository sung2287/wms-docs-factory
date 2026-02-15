# C-028: Snapshot History Intent Map

## 1. Scope
- Listing snapshots.
- Viewing a specific snapshot (preview).
- Restoring a past snapshot.

## 2. Scenarios & Expectations

### Scenario 1: List Snapshots
- **Given**: Workspace W1 with 5 snapshots (S1, S2, S3, S4, S5).
- **When**: User views the history panel.
- **Expectation**:
    - The list shows S5, S4, S3, S2, S1 in order (descending by created_at).
    - S5 is clearly marked as the current HEAD.
    - Each item shows ID (S5), date, and schema_version.

### Scenario 2: Preview Snapshot
- **Given**: User is viewing the list from Scenario 1.
- **When**: User clicks on S3.
- **Expectation**:
    - The Preview Panel renders the content of S3.
    - The editor is in READ-ONLY mode.
    - A "Restore this version" button appears.
    - A warning banner "Viewing past snapshot" is displayed.

### Scenario 3: Restore Confirmation
- **Given**: User is previewing S3.
- **When**: User clicks "Restore this version".
- **Expectation**:
    - A confirmation modal appears explaining that a new snapshot will be created from the selected snapshot (append-only).
    - After successful restore, the workspace head updates to the new snapshot and the UI returns to ACTIVE_HEAD_MODE.
    - Draft behavior is governed by PRD-029 / PRD-030 and is out of scope here.

### Scenario 4: Execute Restore
- **Given**: User confirms restore of S3.
- **When**: The operation completes successfully.
- **Expectation**:
    - A new snapshot S6 is created with content identical to S3.
    - Workspace head updates to S6.
    - Snapshot count becomes 6.
    - The UI switches back to standard edit mode with S6 as the base.
    - The history list refreshes to show S6 at the top.

### Scenario 5: Restore Failure
- **Given**: User confirms restore of S3.
- **When**: The server transaction fails.
- **Expectation**:
    - Workspace head remains at S5 (or whatever it was).
    - No new snapshot S6 exists.
    - UI shows an error message.
    - User remains in preview mode of S3.
