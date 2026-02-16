# PRD-032: Create-only Seed Import

## 1. Objective

Provide a one-time migration tool that converts the existing Excel-based TOC design document and Markdown body files into a fully initialized Workspace.

This PRD defines a migration-only flow.

The Excel file will NOT remain as a long-term SSOT.
After migration, Workspace becomes the single source of truth.

---

## 2. Scope

### Input

1. One or more Excel TOC design files (per volume)
2. Markdown folders organized by volume:
   - `1권/`, `2권/`, `3권/` … (each containing that volume’s `*.md` files)

### Output

- A newly created Workspace
- Tree fully constructed
- SnippetPool populated from Markdown files
- Exactly one initial Snapshot created

---

## 3. Design Principles

1. Migration is one-time and atomic.
2. Excel structure is trusted as structural authority for this migration only.
3. Markdown provides snippet body content.
4. Internal node_id and snippet_id are UUID.
5. external_key (dot notation) is generated during migration.
6. No partial state persistence on failure.
7. Volume (권) identity is derived from the Excel filename (e.g., `*_1권.xlsx`, `*_2권.xlsx`). The migration MUST abort if volume index cannot be parsed or if duplicate volume indices are provided.

---

## 4. Tree Construction Logic

### 4.1 Multi-Volume Series Model (Single Workspace)

This migration MUST be able to build a single “series workspace” from multiple volumes.

- A single Workspace is created for the whole series.
- Each volume is represented as a top-level node under the workspace root.

Logical levels:
- Root (implicit)
- Volume (권)  ← top-level nodes
- Part
- Chapter
- Section (minimum writing unit)

Leaf nodes correspond to Markdown files.

### 4.2 Hierarchy Source

Tree structure for each volume must be derived strictly from its Excel hierarchy.

### 4.3 Node Creation Rules

For each structural unit:

```
{
  node_id: UUID,
  external_key: string,        // dot notation, e.g., "2.1.3.4" (volume-prefixed)
  parent_id: UUID | null,
  title: string,
  order_int: determined by Excel ordering
}
```

- Parent-child relationships must be computed from Excel structure.
- order_int must follow the physical ordering defined in Excel.
- `external_key` MUST be unique across the entire workspace.

### 4.4 external_key Generation (Deterministic)

- The first segment of `external_key` is the Volume order (권): `1`, `2`, `3`, …
- Remaining segments are derived from the Excel hierarchy numbers (Part/Chapter/Section indices) and/or the leaf chapter reference converted to dot notation.
- Example (leaf): Volume 1 + design_chapter `1-1-1-1` → external_key `1.1.1.1.1`
  - (Volume prefix `1`) + (design_chapter hyphens converted to dots `1.1.1.1`)

This key is a migration artifact for stable navigation; internal identity remains UUID.

### 4.2 Node Creation Rules

For each structural unit:

```
{
  node_id: UUID,
  external_key: generated dot notation (1.1.1.1),
  parent_id: UUID | null,
  title: string,
  order_int: determined by Excel ordering
}
```

- Parent-child relationships must be computed from Excel structure.
- order_int must follow the physical ordering defined in Excel.

---

## 5. Markdown Mapping Logic

### 5.1 Mapping Key (Migration-only)

Markdown files must include a chapter reference field:

Example:

```
@design_chapter: 1-1-1-1
```

Migration must match within each volume package:

Excel row reference ↔ Markdown @design_chapter ↔ filename

Notes:
- `@design_chapter` is used ONLY for migration mapping.
- Post-migration SSOT is the workspace (UUID node_id + external_key).

### 5.2 Snippet Policy (Consistent with Node 1:1 ↔ Snippet)

- Every node MUST have exactly one snippet linked 1:1.
- Leaf nodes: snippet.body = full Markdown content.
- Non-leaf nodes: snippet.body = "" (empty).

This ensures the editor can enter editing immediately after migration without special-casing node types.

### 5.2 Snippet Creation

For each leaf node:

```
{
  snippet_id: UUID,
  node_id: UUID,
  body: full Markdown content
}
```

Non-leaf nodes may generate empty snippets or none depending on implementation policy (must be consistent).

---

## 6. Validation Rules

Migration MUST fail if:

1. Duplicate chapter references exist in Excel within a volume
2. Duplicate Markdown mapping keys exist within a volume
3. Excel chapter exists but no Markdown file found (within that volume)
4. Markdown file exists but not referenced in Excel (within that volume)
5. The mapping is not 1:1 (missing or duplicate matches)
6. Hierarchy inconsistency detected
7. Any structural cycle detected
8. Generated `external_key` collisions occur across volumes (must be globally unique)

Validation must complete before Workspace creation.

Migration must be atomic. Any validation failure results in full abort with no partial state persisted.

Validation must complete before Workspace creation.

---

## 7. Snapshot Initialization

Upon successful migration:

1. One Workspace is created for the series
2. All volumes’ trees and SnippetPools are persisted
3. Exactly one Snapshot is created
4. snapshot_count = 1
5. head_snapshot_id = created snapshot

Migration must be atomic.

---

## 8. Non-Goals

- Incremental append into an existing workspace (no multi-run accumulation)
- Updating existing workspace
- Conflict resolution
- Excel as long-term editing tool
- Import UI (CLI-only acceptable)

---

## 9. Success Criteria

Given valid Excel+Markdown packages for multiple volumes:

- A single workspace is created
- Each volume appears as a top-level node
- Tree structures match each Excel
- Snippets populated correctly
- Snapshot count = 1

Given invalid input:

- Migration aborts
- No workspace created
- Clear validation error returned

