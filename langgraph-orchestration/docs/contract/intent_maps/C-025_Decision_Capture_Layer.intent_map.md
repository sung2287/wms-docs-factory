# C-025 — Decision Capture Intent Map

| Intent ID | Trigger | Expected Outcome | Forbidden |
|:---|:---|:---|:---|
| `INT-001` | Conversation Turn Detected | `DecisionProposal` generated with `proposalId` and `conversationTurnRef`. | No `conversationTurnRef` or `proposalId`. |
| `INT-002` | `DecisionProposal` Submitted | `DecisionVersion` commit initiated with `rootId` lookup. | Overwrite existing version. |
| `INT-003` | `create_work_item=true` | `WorkItem` created with `status='PROPOSED'` and `decision_id=version.id`. | Create `WorkItem` with incorrect `status`. |
| `INT-004` | `Commit` & `Create` Atomic | `Decision` and `WorkItem` both saved or both failed. | Partial success in saving. |
| `INT-005` | `ANALYZING` Transition | `WorkItem` status updated to `ANALYZING`; `work_item_transitions` entry added. | Update without transition log. |
| `INT-006` | `DESIGN_CONFIRMED` | `WorkItem` status updated to `DESIGN_CONFIRMED`. | Transition to `IMPLEMENTING` before PRD-027. |
| `INT-007` | Commit Rejected | `Decision` commit fails if `evidenceRefs` or `changeReason` are missing. | Commit without evidence/reason. |
| `INT-008` | `Cycle End` Signal | `Atlas Index` updated based on committed `DecisionVersion`. | Atlas update during `executePlan` loop. |
| `INT-009` | `BudgetExceededError` | Execution stops (FailFast); `WorkItem` remains in current status. | Status transition on budget failure. |
| `INT-010` | `CONFLICT=STRONG/LOCK` | Automatic commit blocked; `InterventionRequired` triggered. | Auto-commit without `Guardian` approval. |
| `INT-011` | `create_work_item=false` | `DecisionVersion` committed without `WorkItem` creation. | Implicit WorkItem auto-generation. |

---
*Intent Map generated for PRD-025. Following ABCD spec.*
