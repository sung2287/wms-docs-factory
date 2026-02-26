# B-025 — Decision Capture Layer Contract
Status: LOCKED
Depends On: PRD-026

## 1. Data Contract

- **DecisionProposal**:
  - `proposalId`: (UUID v4)
  - `conversationTurnRef`: (Required)
  - `content`: (String)
  - `evidenceRefs`: (Required, Non-empty array)
  - `changeReason`: (Required, Non-empty string)
  - `create_work_item`: (Boolean, Default: true)
  - `conflictStrength`: ('NORMAL' | 'STRONG' | 'LOCK')
- **WorkItem**:
  - `decision_id`: (Version UUID) - Must be immutable once created.
  - `status`: ('PROPOSED', 'ANALYZING', 'DESIGN_CONFIRMED', 'IMPLEMENTING', 'IMPLEMENTED', 'VERIFIED', 'CLOSED')

## 2. Transition Contract

- **Allowed Transitions**:
  - `(None)` -> `PROPOSED` (At creation)
  - `PROPOSED` -> `ANALYZING`
  - `ANALYZING` -> `DESIGN_CONFIRMED`
- **Locked Transitions**:
  - `IMPLEMENTING`, `IMPLEMENTED`, `VERIFIED`, `CLOSED` are locked until PRD-027.
- **Guard Mechanism**:
  - All status transitions must be recorded in `work_item_transitions` in an append-only manner.
  - Attempting an unauthorized jump must trigger a safety abort.

## 3. Transaction Boundary Contract

- **Decision Commit + WorkItem Creation**:
  - MUST be performed within a single atomic database transaction.
  - Failure in WorkItem creation must rollback the Decision version commit.
- **Atlas Update**:
  - MUST occur only at Cycle End after `PersistSession` success.
  - MUST NOT be part of the Decision-WorkItem atomic transaction.

## 4. Invariants (INV-1 ~ INV-7)

- **INV-1**: `WorkItem.decision_id` is fixed to the version UUID at creation — No changes allowed.
- **INV-2**: `Decision/Evidence` are Non-Overwrite (Version chain only).
- **INV-3**: `WorkItem` status transitions must pass the transition guard.
- **INV-4**: `Atlas` cannot trigger `WorkItem/Decision` changes (Unidirectional flow only).
- **INV-5**: `Commit` and `WorkItem` creation share a single transaction boundary.
- **INV-6**: `conversation_turn_ref` exists only in `work_item_transitions`.
- **INV-7**: `BudgetExceededError` does not trigger `WorkItem` status transitions. FailFast is handled outside the state machine.

## 5. Forbidden Behaviors

- **Atlas Reverse Trigger**: Forbidden for Atlas lookup results to directly trigger Decision changes.
- **Loop Mutation**: No `GraphState` mutation by Atlas or Guardian hooks that bypasses the formal Decision Proposal/Commit process.
- **Overwrite**: Overwriting existing Decision versions is strictly forbidden.
- **Direct Atlas Update**: WorkItem cannot directly update the Atlas index; Atlas is derived at Cycle End.

---
*LOCK-A/B/C/D compliant. Generated for PRD-025.*
