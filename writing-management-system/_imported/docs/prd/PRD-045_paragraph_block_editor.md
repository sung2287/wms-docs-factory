# PRD-045: Paragraph Block Editor v1.3 (Block Identity Hardened)

## 1. Title
**PRD-045: Paragraph Block Editor v1.3 (Block Identity Hardened)**  
**Status:** Draft / Ready for BCD  
**Layer:** UI Layer / Personal Writing Mode  
**System:** Writing Management System (WMS)

---

## 2. Objective
To enhance the Personal Writing Mode by transforming the monolithic `rawText` section body into a modular, block-based UI. This allows writers to manipulate, reorder, and edit paragraphs as discrete units while maintaining a simple, single-string persistence model and ensuring byte-stable data integrity for paragraph content.

---

## 3. Background
Currently, the system treats a Section body as a single `rawText` string. While efficient for storage and snapshotting, it hinders the creative writing process. PRD-045 introduces a "Virtual Block Layer" that exists only during the active editing session. Version 1.3 hardens the block identity logic to ensure that the relationship between the UI array and the persisted string is mathematically predictable and stable.

---

## 4. Scope

### 4.1 In-Scope (UI/UX Only)
- **Virtual Segmentation:** Logic to split `rawText` into an array of blocks upon loading.
- **Block Manipulation:** UI controls to Add, Edit, Delete, and Reorder (Move Up/Down) blocks.
- **Virtual Serialization:** Logic to join blocks back into a single `rawText` string upon saving.
- **Deterministic Normalization:** Idempotent white-space handling for paragraph separators.

### 4.2 Out-of-Scope (Non-Goals)
- **Persistence Changes:** No changes to the database schema or API save payloads.
- **Model Evolution:** No introduction of `Paragraph` entities or IDs in the backend.
- **Snapshot Impact:** No changes to how snapshots are computed or stored.
- **Markdown Parsing:** This remains a physical split based on blank lines.

---

## 5. Functional Requirements

### 5.1 Text Normalization Rule
Upon selecting a Section for editing, the system **MUST** normalize the text according to the following formal definition:

**normalize(text):**
1. Replace all `
` (CRLF) with `
` (LF).
2. Remove **ALL** leading `
` characters.
3. Remove **ALL** trailing `
` characters.
4. Do **NOT** modify any other characters.

**Clarification:**
- Removal of boundary newlines is mandatory (**MUST**), not optional.
- Internal whitespace (including leading spaces/tabs for indentation or trailing spaces on lines within a paragraph) **MUST** remain byte-stable.
- No trimming of spaces or tabs is allowed.

### 5.2 Segmentation (The "Split" Rule)
- The system must split the normalized `rawText` into an array of strings (Blocks).
- **Split Regex:** `/
{2,}/`
- **Clarification:** Two or more consecutive newline characters are treated as a single paragraph boundary.
- **Internal Double-Newline Constraint:** If a block contains internal `

` sequences, subsequent load cycles **MAY** re-segment that block according to the defined Split rule. This behavior is expected and deterministic.

### 5.3 Deterministic Lossless Guarantee
The system must satisfy the following formal identity condition:
`normalize(text) === join(split(normalize(text)))`

- The transformation **MUST** be idempotent.
- Repeated save/load cycles **MUST** produce identical output.

**Block Array Identity Guarantee:**
`split(join(blocks)) MUST return the original blocks array IF AND ONLY IF none of the blocks contain internal "

" sequences.`

- **Block order MUST be preserved.**
- **Block content MUST remain byte-identical.**
- **No additional normalization beyond the defined rules is allowed.**

### 5.4 Re-serialization (The "Join" Rule)
- Before invoking the existing `Save` pipeline, the block array must be joined into a single string.
- **Join Separator:** Exactly two newlines (`

`) **MUST** be used between blocks.
- **Normalization Effect:** Sequences like `



` in the original text will normalize to `

` after one save cycle. This is expected and documented behavior.

### 5.5 Block Internal Newline Behavior
- **Paste Logic:** A user may paste multi-paragraph content inside a single block.
- **No Auto-Split:** The editor does **NOT** auto-split content into multiple blocks during the active editing session after a paste action.
- **Delayed Segmentation:** Paragraph segmentation for pasted content only occurs during the next "Split" phase (i.e., the next time the section is loaded). This behavior is intentional.

---

## 6. Non-Functional Requirements

### 6.1 Performance
- The split/join operations must remain responsive (under 100ms lag) for sections containing up to 10,000 words.

### 6.2 Data Integrity
- The transformation must be byte-stable for all characters within a paragraph block. Indentation and internal formatting must be preserved exactly as entered.

---

## 7. Edge Cases

| Case | Requirement |
| :--- | :--- |
| **CRLF-only input** | Must be normalized to LF; join(split()) must remain LF-stable. |
| **Leading/Trailing Blank Lines** | **MUST** remove leading and trailing newline characters. |
| **Indented Blocks** | Intentional leading spaces (e.g., for blockquotes or code-like text) must be preserved in full. |
| **Multi-Blank Line Collapse** | `


` normalized to `

` upon join; subsequent cycles produce identical output. |
| **Empty Section** | Must render exactly one empty block for the user to begin typing. |
| **All Blocks Deleted** | System resets to one empty block. |

---

## 8. Acceptance Criteria
- [ ] Section with 5 paragraphs separated by varied blank line counts (`

`, `


`) renders exactly 5 UI blocks.
- [ ] Saving the section replaces all varied separators with a standard `

`.
- [ ] Paragraphs with leading tabs or spaces retain those characters exactly after a Save/Load cycle.
- [ ] Pasting three paragraphs into Block #2 keeps all three in Block #2 until the editor is closed and reopened.
- [ ] The formal identity condition `normalize(text) === join(split(normalize(text)))` is verified via unit tests.
- [ ] Repeatedly opening and saving a section without edits results in zero bytes of change to the `rawText`.

---

## 9. Risks
- **Cursor Positioning:** Managing focus during block insertion/deletion requires careful state handling.
- **Thematic Breaks:** Users who use multiple blank lines for "thematic breaks" will see them normalized to single blank lines; this must be communicated as a system constraint.

---

## 10. Future Extensions
- **Drag-and-Drop:** Intuitive reordering of blocks.
- **Thematic Break Support:** Recognition of `***` or `---` as distinct block types to preserve intentional vertical spacing.
- **Block-Level Metadata:** Session-only status markers or comments per block.
