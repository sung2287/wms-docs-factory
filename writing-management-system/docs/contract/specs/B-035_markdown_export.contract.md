# B-035_markdown_export.contract.md

## 1. Introduction
This contract defines the deterministic export of a Workspace to a flat folder of Markdown files. This is a read-only operation that guarantees round-trip compatibility with the Mode A import process.

## 2. Input Specification
- **Workspace ID:** UUID of the target workspace.
- **Snapshot ID:** (Optional) Defaults to the current `head_snapshot_id`.
- **Target Path:** The destination directory for the exported files.

## 3. Core Constraints & Validation Rules

### 3.1 Validation (Pre-Export)
The export MUST FAIL if:
1. **Workspace Missing:** The specified `workspace_id` does not exist.
2. **Snapshot Missing:** The specified or head snapshot cannot be retrieved.
3. **Key Collision:** Duplicate `external_key` values are detected in the snapshot view (Internal invariant check).
4. **Filesystem Error:** The target path is not writable or is restricted.

### 3.2 Read-Only Integrity
- The export process MUST NOT mutate any Workspace state.
- It MUST NOT create snapshots or modify metadata.
- It MUST NOT trigger any retention policy or cleanup.

### 3.3 Node Filtering
- The export MUST ONLY include nodes where `external_key` is NOT NULL.
- It MUST EXCLUDE:
    - The implicit Root node.
    - Folder grouping nodes (where `external_key` is NULL).
    - Any temporary or system-generated nodes without a stable key.

### 3.4 Filename Generation
- Filename MUST be exactly `external_key` + `.md`.
- Dot-notation MUST be preserved verbatim.

## 4. Determinism & Ordering
- Files MUST be generated using **Natural Numeric Sort** of the `external_key`.
- **Natural Sort Algorithm:**
    1. Split `external_key` by `.` into segments.
    2. Compare segments numerically as integers.
    3. If all shared segments are equal, the shorter key sorts first (e.g., `1.2` < `1.2.1`).

## 5. Persistence Strategy
- **Atomic Write:** The system MUST write files to a temporary directory (e.g., `.<target>.tmp-<uuid>`) first.
- **Rename/Move:** Only after all files are successfully written, the temp directory MUST be renamed to the target directory.
- **Cleanup:** On failure, the temporary directory MUST be deleted to prevent partial or corrupted exports.

## 6. Content Specification
- The exported file content MUST be the raw `snippet.body`.
- No metadata, headers, or structural markers MUST be injected or modified.

## 7. Round-Trip Guarantee
- Exported files MUST be compatible with **PRD-034 Mode A Import**.
- Re-importing the exported folder MUST reconstruct an identical `external_key` structure and snippet content.
