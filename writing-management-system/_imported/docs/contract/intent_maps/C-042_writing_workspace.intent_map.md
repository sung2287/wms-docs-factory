# C-042: Writing Workspace Intent Map

## 1. Objective
Map user intents to system reactions and state transitions within the Writing Workspace, ensuring absolute data safety and preventing race conditions during save operations.

## 2. Intent-Reaction Mapping

| User Intent | UI Action / Trigger | System Reaction |
| :--- | :--- | :--- |
| **Typing / Edit** | Keystroke / Block Move | Transition to `DIRTY`. Reset 2000ms debounce timer. |
| **Idle Pause** | 2s without mutation | If state === DIRTY, transition to SAVING. Freeze normalizedText at transition time. |
| **Change Node** | Click Tree Node / Route | If state === DIRTY, trigger immediate `SAVING`. Block navigation. |
| **Complete Section**| Click "Mark as Completed" | **Cancel Debounce Timer**. Trigger immediate `SAVING` (Status: Completed). Completion-triggered SAVING MUST bypass debounce and freeze normalizedText immediately. |
| **Save Failure** | API 4xx/5xx | Transition to `ERROR`. Show toast. Stay on node. |
| **Save Success** | API 200/201 | Transition to `IDLE`. Show "Saved" indicator for 1.5s. On SUCCESS: lastSavedNormalizedText MUST be updated to the frozen normalized value used during SAVING. |

**State Safety Rule:**
- Auto-save MUST only trigger when state === DIRTY.
- If state === SAVING, mutation MUST set DIRTY and pendingSave = true.
- ERROR MUST NOT imply Dirty resolution.
- From ERROR, only MUTATION, NAVIGATION, or COMPLETION events may re-enter SAVING.

**Consistency Invariant:**
- DIRTY MUST imply normalize(join(blocks)) !== lastSavedNormalizedText.
- SAVING MUST freeze the normalized text used for comparison until SUCCESS or FAILURE.

**Freeze Invariant:**
- When transitioning from DIRTY → SAVING, the system MUST freeze a single normalizedText value.
- That frozen value MUST be the one used for: (1) Snapshot comparison (2) Save payload (3) lastSavedNormalizedText update on SUCCESS.
- Mutations occurring during SAVING MUST NOT alter the frozen value.

**Single-Source-of-Truth Rule:**
- lastSavedNormalizedText MUST only update inside SUCCESS transition.
- No other state transition may modify it.

## 3. Race Condition Handling (Completion vs Auto-save)
- **Scenario:** User types a character (timer starts) and immediately clicks "Mark as Completed".
- **Rule:** The click event MUST call `clearTimeout()` on the auto-save timer before initiating the completion save.
- **Outcome:** Only one "Completed" snapshot is generated; the redundant "Draft" auto-save is suppressed.

## 4. Navigation Flow (D-042 Integration)
1. **User Action:** Intent to navigate (e.g., clicking a new `node_id`).
2. **Check:** `if (state === DIRTY)`.
3. **Execution:** `triggerImmediateSave()`.
4. **Guard:** `await savePromise`.
5. **Success:** Proceed to `fetchNode(newNodeId)`.
6. **Error:** Abort navigation.

**Navigation Invariant:**
- Navigation MUST NOT change editor instance until the savePromise resolves.
- lastSavedNormalizedText MUST NOT update during blocked navigation.
