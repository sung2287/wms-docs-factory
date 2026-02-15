# PRD-036: DesignSpec Persistent Model & Review Propagation Rules (Schema Fixed Version)

## 1. Objective

This PRD formalizes a permanent DesignSpec layer capable of fully representing the Excel design blueprint structure.

It defines:
- A fixed DesignSpec schema
- Hierarchical inheritance & composition rules
- Review propagation policy
- Snapshot inclusion policy

This system is designed for manual writing workflows.
No automatic AI mutation is included.

---

## 2. Core Philosophy

1. DesignSpec is constitutional.
2. snippet.body is the implementation result.
3. Design changes can invalidate completed writing.
4. Only completed sections are subject to re-review.
5. Human approval clears review state.

---

## 3. Node Data Model

Each Node (Series / Volume / Part / Chapter / Section) contains:

```
Node {
  node_id: UUID
  external_key: string | null
  title: string

  design_spec: DesignSpec

  snippet.body: string

  writing_status: "empty" | "completed"
  review_required: boolean
}
```

Both `design_spec` and `snippet.body` are snapshot-tracked.

---

## 4. Fixed DesignSpec Schema (Excel-Aligned)

DesignSpec is structured as follows:

```
DesignSpec {

  constitution: {
    rules: string[]
  }

  series: {
    core_sentence: string | null
    direction: string | null
    achievement: string | null
  }

  volume: {
    label: string | null
    subtitle: string | null
    role: string | null
    core_question: string | null
    achievement: string | null
    notes: string[]
  }

  part: {
    title_hint: string | null
    role: string | null
    core_insight: string | null
    next_question: string | null
    post_summary: string[]
  }

  chapter: {
    title_hint: string | null
    one_liner: string | null
    logic_role: string | null
    key_claim: string | null
    reader_state_change: string | null
    argument_log: string[]
    next_hooks: string[]
    post_summary: string[]
  }

  section: {
    file_key_source: string | null
    title_hint: string | null
    purpose: string | null
    notes: string[]
  }

  constraints: {
    forbidden: string[]
    cautions: string[]
  }

  style: {
    metaphors: string[]
  }
}
```

---

## 5. Composition Rules (Effective DesignSpec)

When preparing a section for writing:

```
effective_design_spec = compose(
  constitution,
  series,
  volume,
  part,
  chapter,
  section
)
```

### 5.1 Override Fields

Nearest level wins:
- core_sentence
- direction
- role
- core_question
- core_insight
- logic_role
- key_claim
- reader_state_change
- purpose


### 5.2 Accumulate Fields (Union)

- constitution.rules
- constraints.forbidden
- constraints.cautions
- style.metaphors

Duplicates removed.
Constitution rules cannot be overridden.


### 5.3 Append Fields (Ordered Concatenation)

Concatenate from root → leaf:
- volume.notes
- part.post_summary
- chapter.argument_log
- chapter.next_hooks
- chapter.post_summary
- section.notes

Each block should preserve source level metadata.

---

## 6. Review Propagation Policy

When any DesignSpec field changes at any node:

1. Traverse all descendant sections.
2. If writing_status == "completed":
   - review_required = true
3. If writing_status == "empty":
   - No change

Design changes MUST create a snapshot.

---

## 7. Manual Re-Approval

When user re-saves a reviewed section:

- review_required = false
- writing_status remains "completed"
- Snapshot is created

---

## 8. Snapshot Inclusion Policy

Snapshot captures full state:
- design_spec
- snippet.body
- writing_status
- review_required

Snapshots represent the constitutional + implementation state.

---

## 9. Non-Goals

- Automatic AI rewriting
- Automatic text mutation
- Merge policy
- Diff policy

---

## 10. Success Criteria

1. Entire Excel design blueprint can be stored without loss.
2. DesignSpec changes propagate review flags correctly.
3. Only completed sections require re-review.
4. Manual approval clears review flag.
5. Snapshot history tracks structural and textual evolution.

---

## 11. Out of Scope

- AI automation logic
- Prompt construction (handled in PRD-037)
- Structural merge logic

This PRD strictly defines structural design persistence and review governance.

