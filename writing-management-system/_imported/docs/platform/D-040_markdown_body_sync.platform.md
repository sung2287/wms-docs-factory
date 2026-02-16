# [D-040] Platform: Markdown Body Sync Execution Flow

## 1. Layering

- **Core**:
  - `CanonicalNormalizer`
  - `BodyEqualityChecker`
  - `SyncPlanner` (detect changed files)

- **Adapter**:
  - `MarkdownScanner`
  - `FileReader`
  - `WorkspaceRepository`

- **App**:
  - `MarkdownBodySyncService` (transaction orchestrator)

## 2. Execution Flow

1. **Scan**:
   - Scan directory for markdown files.
   - Extract external_key from filename.
   - Sort using natural numeric sort.

2. **Match**:
   - For each file:
       - Find node by exact external_key match (case-sensitive).
       - If no match → fail-fast.

3. **Normalize**:
   - Apply canonical normalization:
       * LF normalization
       * Trailing whitespace removal
       * UTF-8 enforcement

4. **Compare**:
   - Compare normalized content with stored snippet.body.
   - If identical → skip.
   - If different → mark for update.

5. **Transaction Phase**:
   - If no updates → terminate (NO SNAPSHOT).
   - If updates exist:
       - Overwrite snippet.body only.
       - **Do NOT modify**:
            * external_key
            * parent_id
            * design_spec
            * review_required
            * lineage_id
       - Create exactly one Snapshot.
       - Snapshot message: "Markdown Body Sync"

6. **Commit**:
   - Atomic commit.
   - Return list of updated external_keys.

## 3. Determinism Requirements

- File scan sorted via natural numeric sort.
- Normalization identical to PRD-038 comparison.
- Given identical inputs, update set must be identical.

## 4. Forbidden Operations

- No structural mutation.
- No design_spec mutation.
- No review_required mutation.
- No partial transaction commit.
