# PRD-022: Node State Visualization v1.2 (Aligned with Node Model v1.3)

---

## 1. Objective
To provide visual feedback in the Tree Explorer so that writers can immediately identify which sections are empty, completed, or requiring review due to design changes.

## 2. Scope
- Visual representation of `writing_status` ("empty", "completed").
- Visual representation of `review_required` (boolean).
- Visual representation of the `DIRTY` state (unsaved local changes).

## 3. Node Visual States

### 3.1 Writing Status
1. **EMPTY**:
   - Condition: `writing_status === "empty"`
   - Meaning: No manuscript content has been written.
   - Indicator: `○` (Empty circle) or dimmed text.
2. **COMPLETED**:
   - Condition: `writing_status === "completed"`
   - Meaning: The writer has explicitly marked this section as finished.
   - Indicator: `●` (Filled circle) or green checkmark.

### 3.2 Review State
1. **REVIEW REQUIRED**:
   - Condition: `review_required === true`
   - Meaning: An ancestor's DesignSpec has changed, or the node was moved, potentially violating design constraints.
   - Indicator: `⚠️` (Warning icon) or amber background/text.
   - Priority: This indicator overrides the "Completed" status visually to signal that the completion might no longer be valid.

### 3.3 Session State (Dirty)
1. **DIRTY**:
   - Condition: Local `snippet_body` differs from the last saved snapshot (Auto-save pending).
   - Meaning: Unsaved changes exist in the current session.
   - Indicator: `*` (Asterisk) next to the title or a "pencil" icon.
   - Reset: Cleared immediately upon successful Auto-save or Manual Completion.

---

## 4. UI Guidelines
- **Tree Explorer**: The icons should be placed to the left of the `external_key`.
- **Tooltip**: Hovering over a `⚠️` icon should display: *"Design change detected. Please review against the updated Effective DesignSpec."*
- **Color Coding**:
  - Green: Completed & Not requiring review.
  - Amber: Review Required (Action needed).
  - Grey: Empty.
