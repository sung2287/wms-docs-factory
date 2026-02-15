# B-033_toc_import.contract.md

## 1. Introduction
This contract defines the lightweight Table of Contents (TOC) import process from YAML or TSV formats to create a new Workspace. This process is focused on structural initialization without content body.

## 2. Input Specification

### 2.1 YAML Format
- MUST be a list of node objects.
- Each object MUST contain `key` (string) and `title` (string).
- Objects MAY contain `children` (list of node objects).
- The `key` represents the `external_key`.

### 2.2 TSV Format
- MUST include a header row: `key`, `parent_key`, `title`.
- `key` (string) MUST be unique.
- `parent_key` MUST be empty for root nodes.
- Rows MAY appear in any order, but the system MUST process them deterministically.

## 3. Core Constraints & Validation Rules

### 3.1 Validation (Pre-Persistence)
The import MUST FAIL if:
1. **Duplicate Key:** Multiple nodes share the same `key`.
2. **Missing Parent:** A node specifies a `parent_key` that does not exist in the input.
3. **Depth Mismatch:** The dot-notation of `key` does not match the hierarchy (e.g., `key: 1.2.3` MUST have `parent_key: 1.2`).
4. **Root Restriction:** A root node (no dots in `key` or empty `parent_key`) has a parent specified.
5. **Cyclic Reference:** The hierarchy contains a cycle.
6. **Workspace Exists:** Attempting to import into an existing workspace (v1 only supports NEW workspace creation).

### 3.2 Deterministic Sorting Contract
- The system MUST pre-sort nodes before processing to ensure consistency.
- Sort Strategy:
    1. By Hierarchy Depth (Ascending: Roots first, then children).
    2. By Input Order (Nodes at the same level maintain their relative order from the input file).

### 3.3 external_key Rules
- The input `key` MUST be mapped to the node's `external_key`.
- `external_key` is a stable navigation attribute, NOT the internal identity (UUID).
- Rendering numbers are dynamic and MUST NOT be stored in the database.

## 4. Node & Snippet Initialization
- Every imported node MUST have a corresponding Snippet created.
- The Snippet `body` MUST be initialized as an empty string (`""`).

## 5. Atomicity & Snapshot
- Import MUST be atomic. Any validation or processing failure MUST result in zero persistence.
- Upon success:
    - A new Workspace is created.
    - Exactly ONE initial Snapshot is created.
    - `snapshot_count` is set to 1.
    - `head_snapshot_id` points to the new Snapshot.

## 6. Version Constraints
- v1 MUST NOT support updating or patching existing workspaces.
- v1 MUST NOT support incremental imports.
