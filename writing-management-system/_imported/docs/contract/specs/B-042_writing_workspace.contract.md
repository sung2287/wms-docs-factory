# B-042: Writing Workspace Contract

## 1. Objective
Define the behavioral logic and state constraints for the Writing Workspace, specifically governing the Auto-Save lifecycle, Navigation Guards, and the deterministic conditions for snapshot generation in Personal Writing Mode.

## 2. Auto-Save State Machine
The workspace must implement a deterministic state machine:
- **IDLE**: Content is synchronized with the last saved snapshot.
- **DIRTY**: Local content differs from the last saved normalized text; inactivity timer is active.
- **SAVING**: A save request is currently in-flight.
- **ERROR**: The last save attempt failed; local changes are retained.

### 2.1 State Transitions
- `IDLE` + `MUTATION` → `DIRTY` (Start 2000ms Debounce Timer)
- `DIRTY` + `MUTATION` → `DIRTY` (Reset 2000ms Debounce Timer)
- `DIRTY` + `TIMER_EXPIRED` → `SAVING`
- `DIRTY` + `NAVIGATION_EVENT` → `SAVING` (Immediate; Bypass timer)
- `DIRTY` + `COMPLETION_EVENT` → `SAVING` (Immediate; Cancel pending timer)
- `SAVING` + `SUCCESS` → `IDLE`
- `SAVING` + `FAILURE` → `ERROR`
- `ERROR` + `MUTATION` → `DIRTY` (Start/Reset 2000ms debounce)
- `ERROR` + `NAVIGATION_EVENT` → `SAVING` (Immediate; bypass timer)
- `ERROR` + `COMPLETION_EVENT` → `SAVING` (Immediate; cancel timer)

## 3. Save Logic Contracts

### 3.1 Debounce & Concurrency
- **Debounce:** The timer must be a 2000ms debounce (not throttle). Every mutation resets the clock.
- **Single-Flight Policy:**
    - At most one save operation may be in-flight.
    - If a save trigger occurs while SAVING, set pendingSave = true.
    - When current save resolves SUCCESS:
        - If pendingSave == true AND content is still dirty, immediately execute one additional save.
        - Reset pendingSave = false.
    - No unbounded queue is allowed.

**Pending Save Initialization Rule:**
- pendingSave MUST be initialized to false.
- pendingSave MUST be scoped per editor instance.
- pendingSave MUST NOT persist across node changes.
- After SUCCESS resolution and any conditional re-save, pendingSave MUST be reset to false.

- **Dirty Check:** A save operation MUST be skipped if the current normalized `rawText` is identical to the `lastSavedNormalizedText`.

### 3.2 Snapshot Generation Condition
- A new snapshot is generated IF AND ONLY IF `normalize(currentText) !== lastSavedNormalizedText`.
- `normalize()` MUST follow the rules defined in PRD-045 v1.3.

**On SUCCESS:**
lastSavedNormalizedText MUST be set to normalize(currentTextAtCommit).

## 4. Navigation Guard Behavior
- **Block Navigation:** When a user attempts to leave the current node while in `DIRTY` or `SAVING` state, the workspace MUST block the transition.
- **Immediate Save:** Trigger an immediate save request.
- **Resolution:**
  - On Success: Proceed with navigation.
  - On Failure: Remain on the current node, transition to `ERROR`, and notify the user.
- **No Silent Loss:** Silent navigation during a dirty state is strictly forbidden.

## 5. Completion Save Behavior
- **Priority:** The "Mark as Completed" action is a high-priority commit.
- **Atomic Operation:**
  1. Cancel any pending debounce timer immediately.
  2. Perform immediate `join()` of blocks.
  3. Execute save with `writing_status: "completed"`.
  4. Ensure no background auto-saves can fire after this action is initiated.
