# B-043: Conflict Comparison Contract

## 1. Objective
Define the logic for comparing two document states (Server Head vs. Local Draft) using a block-based sequential diff algorithm. This contract ensures that differences are calculated deterministically and presented clearly to the user for conflict resolution.

## 2. Diff Logic (Sequential Positional Comparison)

### 2.1 Algorithm Constraints
- **Unit of Comparison:** The Paragraph Block (as defined by PRD-045 split rules).
- **Comparison Type:** Strict sequential positional comparison.
- **Identity Condition:** Two blocks are identical IF AND ONLY IF `normalize(blockA) === normalize(blockB)`.
- **Exclusion:** No LCS (Longest Common Subsequence) or heuristic-based move detection is allowed.
- **Explicit Reorder Behavior:** Because comparison is strictly positional, any block reordering MUST manifest as REMOVED + ADDED. No move detection is permitted.

### 2.2 Block Diff State Mapping
For each index `i` in range:
0 to max(headBlocks.length, draftBlocks.length) - 1:

- **UNCHANGED**:
  normalize(Head[i]) === normalize(Draft[i])

- **MODIFIED**:
  Head[i] exists AND Draft[i] exists AND
  normalize(Head[i]) !== normalize(Draft[i])

- **REMOVED**: `Head[i]` exists, but `Draft[i]` does not (at this position).
- **ADDED**: `Draft[i]` exists, but `Head[i]` does not (at this position).

## 3. Determinism Guarantee
- The diff result for any pair of `(Head, Draft)` must be identical across all platforms.
- `diff(Head, Draft)` must use the exact `split()` and `normalize()` logic from B-045.

## 4. Conflict Resolution Contracts

### 4.1 Override Contract
- **Input:** `User Draft`.
- **Result:** Generate a new snapshot using the `Draft` content.
- **Constraint:** Must provide the `current_head_snapshot_id` as the parent to the save API to ensure atomic re-validation.

### 4.2 Refresh Contract
- **Input:** `Server Head`.
- **Result:** Discard `Draft` content. Update local store with `Head` content.
- **Action:** Transition UI back to `IDLE` state in the Editor.
