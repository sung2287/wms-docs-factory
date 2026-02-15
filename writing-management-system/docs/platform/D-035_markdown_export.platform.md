# D-035_markdown_export.platform.md

## 1. Execution Environment
- The export tool MUST run in a **Sandbox** to prevent unauthorized file system access outside the target directory.
- It operates as a **Read-Only Adapter** that queries the Snapshot Layer.

## 2. Application Flow

### Step 1: Workspace Loader
- Loads the Workspace metadata for the given `workspace_id`.
- Retrieves the `head_snapshot_id` or the specifically requested `snapshot_id`.
- Validates the existence and accessibility of the snapshot.

### Step 2: Node Filter
- Queries the `NodeTree` associated with the snapshot.
- Filters out the Root node and all nodes where `external_key == null`.
- Collects the remaining nodes as the export set.

### Step 3: Natural Sorter
- Applies the **Natural Numeric Sort** algorithm to the export set.
- Segments keys by `.` and compares as integers.
- Ensures a stable, deterministic output sequence.

### Step 4: Temp Dir Writer
- Creates a uniquely named temporary directory within the destination parent path.
- For each filtered node:
    - Retrieves the corresponding `Snippet` body.
    - Writes the body to a file named `external_key` + `.md`.
- Verifies that all files were written correctly.

### Step 5: Atomic Rename
- Renames the temporary directory to the user-specified target directory name.
- If the target directory already exists, handle based on configuration (Overwrite or Abort).
- In case of failure, performs a clean deletion of the temporary directory.

## 3. Layer Boundaries
- **Adapter Layer:** FS Write orchestration, Temp directory management, CLI/API feedback.
- **Core Domain:** Natural sorting logic, Key-to-filename mapping, Snapshot view filtering.
- **Infrastructure Layer:** Snapshot retrieval, Snippet data access (Read-Only).

## 4. Error Handling
- Errors MUST be reported using the **Core Error Model**.
- Codes: `EXPORT_WORKSPACE_NOT_FOUND`, `EXPORT_SNAPSHOT_NOT_FOUND`, `EXPORT_FS_PERMISSION_DENIED`.
- All errors MUST trigger the deletion of the temporary export directory.
