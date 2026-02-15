# D-026: Workspace Backup / Restore v1 Platform

## 1. Scope
- JSON structure for Export/Import.
- Step-by-step Import procedure.
- ID mapping logic implementation concept.

## 2. Non-goals
- File system storage management (S3, local disk, etc.).

## 3. Export JSON Structure
```json
{
  "schema_version": "1.0",
  "exported_at": "2023-10-27T10:00:00Z",
  "workspace": {
    "original_id": "uuid-w1",
    "title": "My Project",
    "created_at": "2023-10-01T00:00:00Z"
  },
  "snapshots": [
    {
      "original_id": "uuid-s1",
      "created_at": "2023-10-01T00:05:00Z",
      "payload_json": { "tree": [], "snippets": [] },
      "schema_version": "1.0"
    }
  ],
  "head_original_id": "uuid-s1"
}
```

## 4. Import Procedure (Flow)

1. **Validation**: Parse JSON and check `schema_version` against the compatibility registry.
2. **Transaction Start**: Begin DB transaction.
3. **Workspace Initialization**: 
   - Generate `new_workspace_id`.
   - Create entry in Workspace table (title from JSON).
4. **Snapshot Restoration**:
   - Initialize `id_map = {}`.
   - For each snapshot in JSON (ordered by `created_at`):
     - Generate `new_snapshot_id`.
     - `id_map[original_id] = new_snapshot_id`.
     - INSERT into Snapshot table with `new_workspace_id`.
5. **Pointer Update**:
   - Set Workspace `head_snapshot_id` = `id_map[head_original_id]`.
6. **Transaction Commit**: Finalize all records.

## 5. ID Mapping Logic
- Since v1 forces new IDs, the mapping table (`id_map`) is critical for resolving the `head_snapshot_id`.

## 6. Safety Considerations
- **No Partial Import**: Ensure the loop in step 4 is within the same transaction as step 3 and 5.
- **Large Files**: Consider stream-based JSON parsing to handle large snapshot arrays.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (026)
- [x] Export JSON 구조 명시
- [x] Import 절차 순서(1~6) 명시
- [x] ID 매핑 로직 포함
- [x] Partial import 금지 및 롤백 명시
