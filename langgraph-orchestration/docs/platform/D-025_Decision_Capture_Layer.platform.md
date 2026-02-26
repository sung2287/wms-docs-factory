# D-025 — Decision Capture Platform Spec

## 1. Storage Layer

### SQLite Schema Summary
- **`work_items`**:
  - `id` (PRIMARY KEY)
  - `decision_id` (FOREIGN KEY REFERENCES `decisions.id` ON DELETE RESTRICT)
  - `root_decision_id` (TEXT)
  - `status` (CHECK status IN ('PROPOSED', 'ANALYZING', 'DESIGN_CONFIRMED', 'IMPLEMENTING', 'IMPLEMENTED', 'VERIFIED', 'CLOSED'))
  - `created_at`, `updated_at`, `locked_by_prd`
  - `INDEX idx_work_items_decision_id` (Added for performance)
- **`work_item_transitions`**:
  - `id` (PRIMARY KEY)
  - `work_item_id` (FOREIGN KEY REFERENCES `work_items.id` ON DELETE RESTRICT)
  - `from_status`, `to_status`
  - `triggered_by`, `conversation_turn_ref`, `evidence_refs`, `reason`
  - `created_at`
  - `INDEX idx_work_item_transitions_work_item_id` (Added for performance)

## 2. Execution Layer

### Transaction Boundary
- The **`persistDecision`** handler in `src/core/plan/plan.handlers.ts` or its service layer equivalent MUST use a single SQLite transaction to:
  1. Commit `DecisionVersion` using `createNextVersionAtomically`.
  2. Insert a new `work_items` row.
  3. Insert an initial `work_item_transitions` row.
- **Fail-Safe Mechanism**: The `db.transaction()` wrapper must be utilized to ensure all operations fail if one does.

### Enforcer Rules
- The code-layer enforcer MUST check `DecisionProposal` fields BEFORE initiating the transaction.
- If `evidenceRefs` is `null` or `empty`, or `changeReason` is `null` or `empty`, the process MUST throw a `ValidationError` and stop.

## 3. Runtime Integration

### Runtime Adapter Connection
- The Decision Capture Layer executes within the `executePlan` loop prior to `PersistSession`, and does not directly interact with Atlas.
- It enriches the `Change Context` with `DecisionProposal` metadata.
- It uses the `DecisionContextProviderPort` (from PRD-021) to supply the necessary context for validation.

### Atlas Update Placement
- Atlas index updates occur only in the **`Cycle End`** handler after `PersistSession` is confirmed.
- `AtlasIndexUpdater` (from PRD-026) is the component responsible for this synchronization.

## 4. Failure Policy

### Error Handling Layer
- **`BudgetExceededError`**: Categorized as `FailFast`. It stops the current graph execution and prevents any further state machine transitions.
- **`ConflictError`**: If `conflictStrength` is `STRONG` or `LOCK`, it triggers `InterventionRequired`, stopping the automatic commit process until user approval.
- **`Atlas Update Failure`**: Stale Atlas index is allowed but MUST be logged via `Telemetry`. It does NOT trigger a `Decision/WorkItem` rollback.

## 5. Observability

- **`work_item_transitions`**: Acts as the definitive audit log for all decision-making progress.
- **`conversationTurnRef`**: Links every `DecisionProposal` and its subsequent commit to the specific conversation event.
- **`Telemetry`**: Used to track `Atlas` stale states and `Enforcer` rejection events.

---
*Platform Spec generated for PRD-025. Following ABCD spec.*
