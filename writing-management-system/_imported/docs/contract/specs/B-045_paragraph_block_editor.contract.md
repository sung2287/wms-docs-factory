# B-045: Paragraph Block Editor Contract

## 1. Objective
Define the pure, deterministic logic for transforming a monolithic `rawText` string into a virtual array of paragraph blocks and back. This contract ensures data integrity, idempotency, and the mathematical identity of the document throughout the editing lifecycle.

## 2. Pure Functions

### 2.1 normalize(text: string): string
**Logic:**
1. Replace all occurrences of "\r\n" with "\n".
2. Remove all leading "\n" characters (mandatory).
3. Remove all trailing "\n" characters (mandatory).
4. Constraint: Do NOT modify any other characters.
5. Constraint: Do NOT trim internal spaces, tabs, or single "\n".
**Properties:** Deterministic, Idempotent.

### 2.2 splitParagraphBlocks(text: string): string[]
**Logic:**
1. Input must be a normalized string (via `normalize`).
2. Split using regex: /\n{2,}/
3. Return an array of strings.

**Precondition:**
Caller MUST pass normalize(text) into splitParagraphBlocks().

**Edge Case:** If input is an empty string, return `[""]` (at least one empty block).

### 2.3 joinParagraphBlocks(blocks: string[]): string
**Logic:**
1. Join using separator: "\n\n"
2. The resulting string is the "Normalized rawText".
**Constraint:** Do not add leading or trailing newlines to the resulting string.

**Precondition:**
blocks.length >= 1
If violated, the function MUST throw an error.

## 3. Formal Identity Conditions

### 3.1 Document Stability
For any string `T`:
`normalize(T) === joinParagraphBlocks(splitParagraphBlocks(normalize(T)))`
*This ensures that loading and saving without edits produces zero bytes of change to the normalized source.*

### 3.2 Block Identity
For any string array `B`:
`splitParagraphBlocks(joinParagraphBlocks(B)) === B`
**Pre-condition:** No element in `B` contains the internal sequence `\n\n`.
*This ensures that the UI block structure is preserved across save/load cycles unless the user intentionally introduces a split sequence within a block.*

## 4. Edge Case Definitions

| Input Scenario | Expected Behavior |
| :--- | :--- |
| `"\n\nText\n\n"` | `normalize()` → `"Text"`. |
| `"P1\n\n\n\nP2"` | `split()` → `["P1", "P2"]`. |
| `["P1\n\nModified"]` | `join()` → `"P1\n\nModified"`. Subsequent `split()` → `["P1", "Modified"]`. |
| `[]` (Empty Array) | Not allowed. UI must provide at least `[""]`. |

## 5. Side Effects
- **None.** These functions are pure and do not interact with the DOM, state, or persistence layer.
