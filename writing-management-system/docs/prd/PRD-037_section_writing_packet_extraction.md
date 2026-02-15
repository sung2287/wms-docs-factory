# PRD-037: Section Writing Packet Extraction Specification

## 1. Objective

Define a deterministic "Section Writing Packet" extraction mechanism.

This PRD specifies how the system prepares all necessary structured information
for writing a single section (절) based on DesignSpec.

This is a preparation layer only.
No automatic AI integration is included.

---

## 2. Core Philosophy

1. Writing is design-driven.
2. The system prepares structured context.
3. The human performs final writing externally.
4. The packet must be deterministic and reproducible.

---

## 3. Input

```
workspace_id
section_external_key
optional_context_depth (default = 0)
```

---

## 4. Output: Section Writing Packet Schema

```
SectionWritingPacket {
  target: TargetSection
  effective_design_spec: EffectiveDesignSpec
  hierarchy_context: HierarchyContext
  neighborhood_context: NeighborhoodContext
  constraints_summary: ConstraintsSummary
}
```

---

## 5. Target Section

```
TargetSection {
  external_key: string
  title: string
  writing_status: "empty" | "completed"
  review_required: boolean

  design_spec: DesignSpec (raw, section-level only)
  snippet_body: string
}
```

---

## 6. Effective DesignSpec

Calculated dynamically using PRD-036 composition rules.

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

This result is NOT persisted.
It is a computed view.

---

## 7. Hierarchy Context

Provide full ancestor visibility.

```
HierarchyContext {
  series: { title, design_spec }
  volume: { title, design_spec }
  part: { title, design_spec }
  chapter: { title, design_spec }
}
```

Raw design_spec must be included for transparency.

---

## 8. Neighborhood Context

By default, no body context is included.

If optional_context_depth > 0:

```
NeighborhoodContext {
  previous_sections: [
    { external_key, title, snippet_body }
  ]
  next_sections: [
    { external_key, title }
  ]
}
```

Default system behavior:
- context_depth = 0
- Only design-driven writing

---

## 9. Constraints Summary

Explicit extraction of all constraint-type fields.

```
ConstraintsSummary {
  constitution_rules: string[]
  forbidden: string[]
  cautions: string[]
  tone_rules: string[]
  metaphors: string[]
}
```

All accumulated from effective_design_spec.

---

## 10. Determinism Guarantee

For the same:
- workspace snapshot
- section_external_key
- context_depth

The resulting SectionWritingPacket MUST be identical.

---

## 11. Interaction Policy

This PRD does NOT:
- Send prompts to AI
- Modify snippet.body
- Auto-generate content

User workflow:
1. Extract packet
2. Copy relevant structured data
3. Write externally (AI or manual)
4. Paste result back into snippet.body
5. Save → snapshot created

---

## 12. Review State Awareness

If review_required == true:
- Packet must include a visible flag
- User must manually review before saving

---

## 13. Non-Goals

- Prompt templating logic
- AI orchestration
- Diff comparison
- Merge logic

---

## 14. Success Criteria

1. Any section can produce a deterministic writing packet.
2. Packet includes full hierarchical design visibility.
3. Packet respects PRD-036 composition rules.
4. No automatic mutation occurs.
5. System remains human-controlled.

---

## 15. Future Extensions

- Prompt template layer
- Context summarization engine
- Review dashboard integration
- AI-assisted rewrite mode

Out of scope for this PRD.

