# C-045: Paragraph Block Editor Intent Map

## 1. Objective
Map user interactions in the Block Editor UI to specific mutations of the virtual block array and define the trigger rules for the persistence pipeline.

## 2. Intent-Action Mapping

| User Intent | UI Action | Block Array Mutation |
| :--- | :--- | :--- |
| **Start Writing** | Load Node | `blocks = split(normalize(rawText))` |
| **Edit Content** | Type in Block `i` | `blocks[i] = newText` |
| **New Paragraph** | Click "Add Block" / Enter | `blocks.splice(i + 1, 0, "")` |
| **Delete Paragraph**| Click "Delete" / Backspace | `blocks.splice(i, 1)`. If `blocks.length == 0`, reset to `[""]`. |
| **Reorder Up** | Click "Move Up" | Swap `blocks[i]` and `blocks[i-1]` |
| **Reorder Down** | Click "Move Down" | Swap `blocks[i]` and `blocks[i+1]` |
| **Finish Editing** | Navigation / Auto-Save | `normalizedText = normalize(join(blocks))` → Invoke Save Pipeline |

**Block Array Stability Rule:**
- All block mutations MUST preserve array order except explicit Move operations.
- Swap operations MUST be atomic (no intermediate state observable by dirty check).

## 3. Dirty Detection Trigger Rules

### 3.1 Determination of "Dirty" State
A Section is considered **Dirty** if:
`normalize(join(current_blocks)) !== lastSavedNormalizedText`

**Normalization Consistency Rule:**
- The same normalizedText value MUST be used for:
  (1) Dirty comparison
  (2) Snapshot comparison
  (3) Auto-save dispatch
This prevents double-normalization drift.

### 3.2 Trigger Conditions
- **Keystroke/Mutation:** Reset the 2s inactivity timer (PRD-042).
- **Timer Expiry:** If Dirty, Use the precomputed normalizedText from Dirty evaluation and dispatch normalizedText to Save pipeline.
- **Node Navigation:**
  Cancel pending timer.
  Use the precomputed normalizedText from Dirty evaluation.
  Dispatch normalizedText to Save pipeline.
- **Manual Completion:**
  Cancel pending timer.
  Use the precomputed normalizedText from Dirty evaluation.
  Dispatch normalizedText to Save pipeline with status=Completed.

**Evaluation Invariant:**
- normalize(join(blocks)) MUST be evaluated at most once per state transition.
- That evaluated value MUST be reused for:
    (1) Dirty comparison
    (2) Snapshot comparison
    (3) Save dispatch.
- Dirty check MUST execute BEFORE dispatching any save trigger.

## 4. Integrity Constraints
- Every UI action that modifies the `blocks` array must trigger a Dirty Check.
- Any attempt to paste text containing `

` into a block is permitted, but the user is visually notified that it will be split upon the next load (per PRD-045 v1.3).

**Determinism Invariant:**
- split(normalize(rawText)) MUST be the only initialization path.
- join(blocks) MUST NOT mutate block contents.
- Dirty evaluation MUST always compare normalized strings.
