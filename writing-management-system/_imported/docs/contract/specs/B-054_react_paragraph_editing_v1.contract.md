# B-054: React Paragraph Editing v1 Contract

## 1. State Model Definitions
### 1.1 UI Focus State (Local Only)
- **FOCUSED (Formerly EDITING):** The user has focused the textarea; `readOnly` is false. This state facilitates UI affordance and is independent of the persistence state machine.

### 1.2 Persistence State Machine
The React Editing Layer MUST track the following canonical persistence states:
- **IDLE:** Content is synchronized with the latest local Head Snapshot.
- **DIRTY:** Local draft content differs from the Head Snapshot. **Note:** DIRTY MUST be computed via snapshot diffing (content comparison) rather than focus or input events alone.
- **SAVING:** A `writing-save` request is in flight.
- **COMPARISON:** UI has transitioned to Comparison Mode (PRD-043) following a conflict; editing and saving are frozen.
- **ERROR:** A non-conflict terminal error has occurred (e.g., 500 Internal Server Error).

## 2. Save Flow Contract
### 2.1 Triggering Logic
- **Auto-save:** MUST follow PRD-042 (2-second debounce).
- **Explicit Save:** MUST follow PRD-030 state machine and UI indicators.
- **Reuse:** React UI MUST NOT define new save triggers; it MUST call the existing Save Scheduler.

### 2.2 Response Handling
- **HTTP 200 (Success):** Advance local Head Snapshot; transition to IDLE.
- **HTTP 409 (Conflict):** 
    - Transition Trigger -> **COMPARISON Mode**.
    - MUST NOT be treated as a terminal error.
    - MUST trigger a Mode Transition from Authoring to Comparison (PRD-043).
    - MUST preserve the current local Draft in memory.

## 3. Draft Preservation & Execution Freeze
Upon receiving HTTP 409:
- **Preservation:** The current `raw_text` and block state MUST be retained until Override or Refresh is selected.
- **Freeze:** All pending Auto-save timers MUST be cleared immediately.
- **Block:** Further `writing-save` API calls for the affected workspace MUST be blocked while in Comparison Mode.

Upon entering **COMPARISON Mode**:
- Editing textareas MUST switch to read-only.
- Explicit Save controls MUST be disabled.
- No further mutation to local Draft state is permitted.

## 4. Architectural Constraints
- **Core Immutability:** No modifications to `src/core/**` are permitted.
- **Contract Stability:** The existing `POST /api/workspaces/<workspaceId>/writing-save` contract MUST be reused without modification.
- **No Side Effects:** Local state transitions MUST NOT modify the canonical tree state outside of the defined snapshot advancement.

## 5. Alignment
- **PRD-041/043:** Conflict resolution and comparison UI integration.
- **PRD-042:** Autosave timing and debounce policy.
- **PRD-045:** Block editor rendering and codec rules.
