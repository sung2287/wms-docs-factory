# PRD-033: Lightweight TOC Input Spec v1

## 1. Objective

Provide a lightweight, AI-friendly and human-editable TOC input specification that allows creating a NEW Workspace from external structured text.

This PRD defines input formats and validation rules only.

v1 supports:
- YAML input
- TSV input
- New Workspace creation only

v1 explicitly does NOT support updating existing workspaces.

---

## 2. Design Principles

1. Internal node identity (node_id) is UUID and never exposed to users.
2. External stability is ensured through `external_key` (dot notation, e.g., "1.1.1.1").
3. `external_key` is NOT used as primary identity in the system.
4. Rendering numbers are computed, not stored.
5. Import must be deterministic and validation-strict.

---

## 3. Internal Model (Post-Import)

Each imported node must produce:

```
{
  node_id: UUID,
  external_key: string,        // e.g., "1.1.1.1"
  parent_id: UUID | null,
  title: string,
  order_int: number
}
```

Each node must have a corresponding empty snippet:

```
{
  snippet_id: UUID,
  node_id: UUID,
  body: ""
}
```

After successful import:
- A new Workspace is created
- Initial Snapshot is created (append-only)

---

## 4. Supported Input Formats

### 4.1 YAML Format (AI-friendly)

Example:

```yaml
- key: 1
  title: 인공지능 철학
  children:
    - key: 1.1
      title: 인간과 기계
      children:
        - key: 1.1.1
          title: 의식이란 무엇인가
```

Rules:
- `key` is required
- `title` is required
- `children` is optional

---

### 4.2 TSV Format (Human-friendly)

Example:

```
key	parent_key	title
1		인공지능 철학
1.1	1	인간과 기계
1.1.1	1.1	의식이란 무엇인가
```

Rules:
- Header row required
- key required
- parent_key empty for root
- title required

---

## 5. Validation Rules (Strict)

Import MUST fail if:

1. Duplicate `key` exists
2. parent_key does not exist
3. Dot depth mismatch
   - Example: key = "1.2.3" → parent_key must be "1.2"
4. Root node has parent_key
5. Cyclic reference detected
6. Parent node appears after

Validation must occur before any workspace is created.

---

## 6. Order Handling

- order_int is assigned based on input order within the same parent.
- For TSV input, the system MUST internally pre-sort rows by parent depth (ascending) and then by input appearance order to guarantee deterministic tree construction.
- Parent nodes MUST be processed before child nodes regardless of physical row ordering.
- No manual order field required in v1.

---

## 7. Snapshot Behavior

Upon successful import:

1. New Workspace is created.
2. Tree and SnippetPool are initialized.
3. Exactly one snapshot is created.
4. snapshot_count = 1.
5. head_snapshot_id = created snapshot.

Import is atomic. Failure results in no workspace creation.

---

## 8. Explicit Non-Goals (v1)

- Updating existing workspace
- Merge or patch logic
- Key renaming
- Diff-based synchronization
- Partial import

These are deferred to a future PRD.

---

## 9. Future Extension (v2 Preview)

Future version may support:

- Updating existing workspace via external_key matching
- Structural diff detection
- Conflict reporting
- Incremental snapshot creation

This is explicitly out of scope for v1.

---

## 10. Success Criteria

Given valid YAML or TSV input:

- A new workspace is created
- Tree matches structure
- Snippets are created empty
- Snapshot count = 1
- No rendering number stored

Given invalid input:

- Import fails
- No workspace is created
- Clear validation error returned

