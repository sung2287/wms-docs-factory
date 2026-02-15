# B-026: Workspace Backup / Restore v1 Contract

## 1. Scope
- Definition of the export/import protocol for a single Workspace.
- JSON-based backup file format.
- Rules for ID mapping and workspace regeneration during Restore.

## 2. Non-goals
- Bulk export of multiple workspaces.
- Compression or encryption of the backup file.
- Automatic Garbage Collection.

## 3. Export Contract
- **Unit**: Exactly one Workspace per backup file.
- **Format**: Single JSON file containing the workspace metadata and the full list of associated Snapshots.
- **Completeness**: All snapshots belonging to the workspace must be included in the order they were created.
- **Head Reference**: The `head_snapshot_id` must be correctly identified within the exported snapshot set.

## 4. Restore (Import) Contract
- **No Overwrite**: Restore must never overwrite an existing workspace. It must always create a **new** Workspace record.
- **ID Regeneration**:
    - A new Workspace ID must be generated.
    - All Snapshot IDs must be regenerated to prevent collisions with the current database.
- **Mapping Integrity**: The logical relationship (parent-child or head pointer) must be preserved using a mapping between the old IDs in the JSON and the new IDs in the database.
- **Validation**:
    - The `schema_version` of the backup must be verified against the system's compatibility list.
    - If `schema_version` is incompatible, the Restore operation must be rejected.
- **Atomicity**: Restore must be executed within a single transaction. Failure results in a complete rollback.

## 5. Acceptance Criteria
- Export results in a valid JSON file matching the specified structure.
- Import of the JSON file creates a new Workspace with the exact same number and sequence of Snapshots as the original.
- The new Workspace head points to the correct snapshot (logically equivalent to the original head).
- Import is blocked if the `schema_version` is not supported.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (026)
- [x] Export 단위 (Workspace 1개) 명시
- [x] JSON 단일 파일 규격 포함
- [x] Import 시 신규 ID 생성 및 매핑 요구사항 포함
- [x] Restore 원자성(트랜잭션) 명시
