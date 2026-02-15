# D-025: Snapshot Strategy Freeze (Append-Only) Platform

## 1. Scope
- Database schema requirements for Workspace and Snapshot entities.
- Transactional implementation guide for the Save operation.
- Strategy for preventing orphan snapshots via transaction management.

## 2. Non-goals
- Garbage Collection (GC) implementation.

## 3. Minimal Schema Example

### Workspace Table
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID / String | Primary Key |
| `title` | String | Workspace name |
| `head_snapshot_id` | UUID / String | Foreign Key (NOT NULL) to Snapshots.id |
| `updated_at` | Timestamp | Last modified time |

### Snapshot Table
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID / String | Primary Key |
| `workspace_id` | UUID / String | Foreign Key to Workspace.id |
| `payload_json` | JSON / Text | Serialized workspace state |
| `schema_version` | String | Data structure version |
| `created_at` | Timestamp | Creation time |

## 4. Transaction Structure
The Save operation must follow this specific order within a single transaction:

1. **Serialize**: Convert current memory state (tree, snippets) into `payload_json`.
2. **INSERT Snapshot**:
   - Generate new `snapshot_id`.
   - Insert into `snapshots` table with `workspace_id`, `payload_json`, and current `schema_version`.
3. **UPDATE Workspace**:
   - Set `head_snapshot_id` = `new_snapshot_id`.
   - Update `updated_at` = current time.
4. **COMMIT**: Finalize changes.

## 5. Orphan Prevention
- Since GC is not yet defined, "orphan" prevention is strictly handled by the transaction itself. 
- If the `UPDATE Workspace` step fails, the `INSERT Snapshot` must be rolled back to avoid having a snapshot record that is not pointed to by any workspace head.

## 6. Implementation Notes
- Use database-level constraints (Foreign Keys) to ensure `head_snapshot_id` always points to an existing snapshot.
- Indexes should be placed on `workspace_id` in the snapshots table to allow fast history retrieval.

## 7. Workspace Initialization (B Model)

- When a new Workspace is created, an initial Snapshot must be created within the same database transaction.
- `head_snapshot_id` must be set during Workspace creation.
- `head_snapshot_id` must NOT be nullable.
- Every Workspace must always contain at least one Snapshot record.
- The initial Snapshot must contain:
  - an empty but valid serialized `payload_json`
  - a valid `schema_version`
  - a `created_at` timestamp.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (025)
- [x] DB 트랜잭션 구조 명시 (Insert -> Update)
- [x] Orphan 방지 전략 (트랜잭션) 포함
- [x] 최소 스키마 예시 포함
