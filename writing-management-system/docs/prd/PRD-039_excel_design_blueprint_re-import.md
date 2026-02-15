# PRD-039: Excel Design Blueprint Re-Import (Update + Structural Diff v2)

## 1. Objective

Define the deterministic re-import mechanism for updating an existing Workspace
using a revised Excel Design Blueprint (fixed template 00~04 + 99).

This PRD enables:
- DesignSpec updates
- Structural diff processing (add/remove/move/rekey/reorder)
- Conditional Markdown body updates
- Review propagation for completed sections

This is NOT a seed creation PRD. It updates an existing Workspace.

---

## 2. Scope Separation

- PRD-032: Seed Workspace Creation (Create Only)
- PRD-036: DesignSpec Persistent Model
- PRD-037: Writing Packet Extraction
- PRD-039: Re-Import Update + Structural Diff

---

## 3. Re-Import Preconditions

1. Excel must follow fixed template (00~04, 99).
2. Target Workspace must already exist.
3. external_key is the structural identity anchor.

---

## 4. High-Level Flow

1. Parse Excel → Build New Blueprint Tree (DesignSpec only)
2. Compare with Existing Workspace Tree
3. Generate Structural Diff
4. Apply Diff Deterministically
5. Optional Markdown Body Update
6. Propagate Review Flags
7. Create Snapshot

---

## 5. Structural Diff Types

The system must classify changes into the following types:

### 5.1 Add
New node exists in Excel but not in Workspace.
→ Create node (design_spec initialized, body empty unless Markdown provided).

### 5.2 Remove
Node exists in Workspace but not in Excel.
→ Remove from active tree.
→ Move node (with body + design_spec) to Archive.

### 5.3 Move (Re-parent)
Node exists but parent changed.
→ Move node with body and design_spec intact.

### 5.4 Rekey (external_key change)
Node identity maintained but key changed.
→ Update external_key.
→ Body and DesignSpec move with node.

### 5.5 Reorder
Sibling order changed.
→ Update ordering only.

### 5.6 DesignSpec Update
Node exists in both trees but design_spec differs.
→ Update design_spec.

### 5.7 Markdown Body Update (Optional)
If Markdown files provided:
- Matching external_key → overwrite snippet.body
- No file → keep existing body

---

## 6. Archive Policy

When Remove occurs:

- Node removed from active hierarchy
- Stored in Archive container
- snippet.body preserved
- design_spec preserved
- Remains accessible via history

Archive nodes are excluded from writing packet extraction.

---

## 7. Review Propagation Rules

After diff application:

For each node where DesignSpec changed:

1. Traverse descendant sections.
2. If writing_status == "completed":
   → review_required = true
3. If writing_status == "empty":
   → No change

Markdown body overwrite does NOT automatically clear review flags.

---

## 8. Body Conflict Policy

If:
- Section already has body
- DesignSpec updated

Then:
- snippet.body remains unchanged
- review_required = true (if completed)

No automatic body deletion occurs.

---

## 9. Determinism Guarantee

For identical:
- Existing Workspace snapshot
- Excel blueprint input
- Markdown input set

The resulting updated Workspace state MUST be identical.

---

## 10. Snapshot Policy

After successful re-import:

- Create new snapshot
- Snapshot captures full tree, design_spec, body, review flags
- Snapshot message: "Blueprint Re-Import"

---

## 11. Failure Conditions

Re-import MUST fail if:
- Excel template invalid
- external_key duplication detected
- Structural inconsistency detected

No partial application allowed.

---

## 12. Non-Goals

- Merge of concurrent edits
- Automatic AI rewriting
- Prompt-level diff
- Fine-grained paragraph diff

---

## 13. Success Criteria

1. Blueprint updates can safely evolve project structure.
2. Structural changes preserve writing history.
3. Completed sections correctly enter review state after spec change.
4. No data loss occurs.
5. Deterministic repeatability guaranteed.

---

## 14. Future Extensions

- Visual structural diff UI
- Impact visualization dashboard
- Selective diff preview mode
- Review batch approval tools

This PRD defines structural evolution governance for the Workspace.

