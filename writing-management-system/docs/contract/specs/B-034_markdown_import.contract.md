# B-034_markdown_import.contract.md

## 1. Introduction
This contract defines the one-time bulk import process from a folder of Markdown files to a new Series Workspace. This operation uses filename-based keying (Mode A) to establish the initial structure and content.

## 2. Input Specification

### 2.1 File System Source
- MUST be a single folder path containing `*.md` files.
- Files MAY be located in subfolders (recursive scan enabled).

### 2.2 Filename-Based Keys (Mode A)
- Filenames (excluding extension) MUST be interpreted as structural keys.
- Supported separators: Dot (`.`) and Hyphen (`-`).
- Hyphen-based keys MUST be normalized to dot-notation (e.g., `1-2-3` -> `1.2.3`).
- All key segments MUST be numeric strings.
- Empty segments (e.g., `1..2`) MUST NOT be allowed.

## 3. Core Constraints & Validation Rules

### 3.1 Validation (Pre-Persistence)
The system MUST perform full validation before any data is persisted. Import MUST FAIL if:
1. **Invalid Key Format:** Any filename contains non-numeric segments or invalid separators.
2. **Key Collision:** Multiple files map to the same normalized `external_key`.
3. **Duplicate Key:** Duplicate `external_key` values are detected across the input set.
4. **Style Mismatch:** Mixed key styles (e.g., both `1.2.md` and `1-2.md`) exist for the same logical node.
5. **Structural Integrity:** Any circular relationship or structural inconsistency is detected.

### 3.2 Deterministic Parent Auto-Creation
- Missing parent keys in the hierarchy MUST NOT result in failure.
- The system MUST auto-generate all missing ancestor nodes deterministically.
- Auto-created nodes MUST:
    - Have `external_key` set to the missing parent key.
    - Have `title` set to the `external_key` string.
    - Have an empty snippet body (`""`).

### 3.3 Folder Grouping
- Each folder in a recursive scan MUST generate a grouping node.
- Folder grouping nodes MUST:
    - Have `external_key = null`.
    - Have an empty snippet body (`""`).
    - Maintain hierarchy based on the folder structure.

### 3.4 Node & Snippet Mapping
- Every node (file-based, auto-created, or folder-grouping) MUST have exactly one linked Snippet (1:1).
- File-based nodes MUST contain the full Markdown content of the source file.
- Auto-created and folder-grouping nodes MUST contain an empty string (`""`).

## 4. Determinism & Ordering
- Sibling nodes MUST be ordered using **Natural Numeric Sort**.
- Comparison MUST be segment-by-segment as integers (e.g., `1.2` < `1.10`).
- For folder grouping nodes, ordering MUST be deterministic based on the folder name.

## 5. Atomicity & Snapshot
- Import MUST be atomic. Failure at any point MUST result in zero persistence.
- Upon success, exactly ONE initial Snapshot MUST be created.
- `snapshot_count` MUST be 1, and `head_snapshot_id` MUST point to this Snapshot.
- Post-import, the Workspace MUST become the Single Source of Truth (SSOT).

## 6. Persistence
- Internal identities (`node_id`, `snippet_id`) MUST be UUIDs.
- `external_key` MUST be stored as a stable navigation attribute.
