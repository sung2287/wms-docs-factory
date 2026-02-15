# PRD-034: Markdown Bulk Import v1 (Revised)

## 1. Objective

Enable creating a NEW Workspace from a folder of Markdown files without using Excel.

This PRD targets practical personal writing workflows:
- Drop a folder of `*.md`
- Import into the system
- Automatically build a Tree and SnippetPool
- Create exactly one initial Snapshot

v1 is deterministic, validation-strict, and supports **Mode A only**.
Mode B (Heading-Based Import) is explicitly deferred to a future PRD.

---

## 2. Scope

### Input

- A single folder containing `*.md` files (recursive allowed)

### Output

- A newly created Workspace
- Tree constructed from imported Markdown structure
- SnippetPool populated from Markdown content
- Exactly one initial Snapshot created (append-only)

---

## 3. Design Principles

1. Import is one-time and atomic (no partial persistence on failure).
2. Workspace becomes the SSOT post-import.
3. Internal identities are UUID (node_id, snippet_id).
4. External stability is provided via `external_key` (dot notation).
5. Rendering numbers are computed, not stored.
6. Missing parent keys are auto-generated deterministically (Mode A policy).

---

## 4. Import Mode (v1)

### Mode A — Filename Key Import (ONLY supported mode in v1)

- Each file name (without extension) is interpreted as a hierarchical key.
- Supported filename patterns:
  - Dot notation: `1.2.3.4.md`
  - Hyphen notation: `1-2-3-4.md` (converted to dot)

Example:
- `1-1-1-1.md` → external_key `1.1.1.1`

Mode B (Heading-Based Import) is not supported in v1.

---

## 5. Tree Construction Rules

### 5.1 Node Model

Each created node:

```
{
  node_id: UUID,
  external_key: string,
  parent_id: UUID | null,
  title: string,
  order_int: number
}
```

---

### 5.2 Key Normalization

- Hyphen (`-`) is converted to dot (`.`).
- All segments must be numeric.
- No empty segments allowed.

---

### 5.3 Deterministic Parent Auto-Creation (Updated Policy)

Parent key missing is NOT a failure in Mode A.

If a child key exists but its parent key does not:

- All missing ancestor keys MUST be auto-created.
- Auto-created nodes follow deterministic rules:

```
external_key = missing parent key
title        = external_key (string)
snippet.body = ""
```

Example:

Input:
- `1.2.3.md`

Resulting nodes:
- `1`
- `1.2`
- `1.2.3`

Only `1.2.3` contains Markdown content.
Parents contain empty snippets.

---

### 5.4 Ordering Rule

Sibling ordering MUST use natural numeric sort.

Example:
- `1.2` < `1.10`

Order determination:
- Numeric comparison per segment
- Deterministic across environments

---

### 5.5 Folder Grouping (Recursive Support)

If recursive folders are used:

- Each folder MUST generate a grouping node.
- Folder grouping nodes:
  - external_key = null
  - snippet.body = ""
  - Deterministic ordering based on folder name appearance

Folder hierarchy MUST be preserved.

---

## 6. Snippet Policy (Node 1:1 ↔ Snippet)

Every node MUST have exactly one snippet linked 1:1.

- File-based node:
  - snippet.body = full Markdown file content

- Auto-created parent nodes:
  - snippet.body = ""

- Folder grouping nodes:
  - snippet.body = ""

---

## 7. Validation Rules (Strict)

Import MUST fail if:

1. Filename keys are invalid (non-numeric segments, empty segments)
2. Duplicate keys exist
3. Mixed key styles cannot be normalized deterministically
4. Same key maps to multiple files
5. Structural cycle is detected (should be impossible but must be checked)
6. Folder grouping rule is violated when recursive mode is enabled

Parent key missing is NOT a failure.

Validation MUST complete before workspace creation.

Import MUST be atomic.

---

## 8. Snapshot Initialization

Upon successful import:

1. New Workspace is created.
2. Tree and SnippetPool are initialized.
3. Exactly one Snapshot is created.
4. snapshot_count = 1.
5. head_snapshot_id = created snapshot.

---

## 9. Non-Goals (v1)

- Updating existing workspace
- Merging multiple imports
- Conflict resolution
- Incremental append
- Heading-based structure derivation
- Markdown semantic parsing (tables/images)

---

## 10. Success Criteria

Given a folder of valid Markdown files:

- Workspace is created
- Tree matches deterministic key structure
- Auto-generated parents exist when needed
- Snippets contain correct bodies
- Snapshot count = 1

Given invalid input:

- Import fails
- No workspace is created
- Clear validation error is returned

---

## 11. Future Extension (Mode B)

Mode B (Heading-Based Import) will be introduced in a separate PRD.
It must:

- Use a strategy-based importer
- Preserve deterministic ordering
- Prevent cross-file heading collision

Mode B is explicitly out of scope for v1.

