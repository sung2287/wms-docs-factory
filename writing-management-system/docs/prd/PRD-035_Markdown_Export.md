# PRD-035: Markdown Export v1

## 1. Objective

Provide a deterministic Markdown export capability for an existing Workspace.

The export must:
- Reconstruct a folder + Markdown file structure
- Preserve structural determinism
- Guarantee round-trip compatibility with PRD-034 (Mode A)
- Not mutate Workspace state

This PRD defines a read-only export operation.

---

## 2. Scope

### Input

- Existing Workspace (identified by workspace_id)
- Current head snapshot

### Output

- Folder structure
- Markdown files (*.md)
- Deterministic filename generation

Export MUST NOT modify:
- Snapshot history
- Workspace metadata
- Retention state

---

## 3. Design Principles

1. Export is pure and side-effect free (no Workspace mutation).
2. Workspace remains SSOT.
3. Exported structure must be deterministic.
4. Exported files must be re-importable via PRD-034 Mode A.
5. No implicit content transformation (raw snippet body only).
6. Export must be safe on failure: partial output must be avoided as much as possible via atomic filesystem strategy.

---


## 4. Export Model

### 4.1 Export Strategy (v1)

v1 supports **Key-Based Export Only**.

Rules:
- Nodes with non-null `external_key` become Markdown files.
- Filename = external_key + ".md"
- Dot notation preserved (no hyphen conversion).

Example:

external_key = "1.2.3"
→ file: `1.2.3.md`

---

#### 4.2 Folder Structure

v1 default: **Flat export (no folder grouping)**.

All files are exported into a single target directory.

Filesystem strategy (recommended for v1):
- Write into a temporary directory under the same parent (e.g., `.<target>.tmp-<uuid>`)
- After all files are written successfully, rename/move temp → target (atomic on most POSIX filesystems)
- On failure, delete the temp directory

Future versions may support folder grouping by:
- Depth
- Volume
- Custom strategy

Out of scope for v1.

---


#### 4.3 Node Filtering Rules

Export MUST include:
- All nodes with non-null `external_key`

Export MUST exclude:
- Implicit root
- Any node with `external_key = null` (e.g., folder/grouping/temporary nodes)

Rationale:
- external_key-bearing nodes represent stable, key-addressable content.
- Filtering reduces export noise and strengthens round-trip compatibility with PRD-034 Mode A.

---


## 5. Content Rules

For each exported file:

```
file content = snippet.body
```

No:
- Auto-generated heading insertion
- Structural markers
- Metadata injection

Export is a raw body dump.

---

## 6. Deterministic Ordering

File generation order MUST follow:

1. Natural numeric sort of `external_key`
2. Stable across environments

Example ordering:
- 1.2
- 1.10
- 2

Natural sort rule (fixed):
- Split by `.` into numeric segments
- Compare segment-by-segment as integers
- If all shared segments equal, shorter key sorts first (e.g., `1.2` < `1.2.1`)

Key normalization policy (v1):
- Export preserves dot notation.
- If the system ever stores `external_key` with leading zeros, sorting compares as integers (so `01` == `1` for ordering). Export filename uses stored `external_key` verbatim.

---


## 7. Validation Rules

Export MUST fail if:

1. Workspace does not exist
2. Head snapshot missing
3. Duplicate `external_key` detected (should be impossible)
4. Filesystem write error occurs

Failure handling:
- Failure MUST NOT mutate Workspace.
- If using the recommended temp-dir strategy, exporter MUST cleanup temp output on failure.

---


## 8. Snapshot Behavior

Export does NOT:
- Create snapshot
- Modify snapshot
- Increment counters

It is read-only.

---

## 9. Round-Trip Guarantee

If a Workspace was created via PRD-034 Mode A, then:

Export → Re-import → New Workspace

MUST produce:
- Identical `external_key` structure
- Identical snippet bodies
- Deterministic ordering

Notes:
- UUID identities may differ (expected).
- Export reads from the **head snapshot view** (consistent with Snapshot/Time Travel model) but does not export historical snapshots in v1.

---


## 10. Non-Goals

- Export of Time Travel views
- Export of historical snapshots
- Export formatting normalization
- Markdown linting
- Metadata embedding

---

## 11. Success Criteria

Given a valid Workspace:

- Files are generated deterministically
- Re-import via PRD-034 succeeds
- No state mutation occurs

Given invalid state:

- Export fails safely
- Workspace unchanged

---

## 12. Future Extensions

Potential v2 features:

- Folder grouping export
- Volume-based partitioning
- Metadata header injection
- Historical snapshot export
- Diff-based export

These are explicitly out of scope for v1.

