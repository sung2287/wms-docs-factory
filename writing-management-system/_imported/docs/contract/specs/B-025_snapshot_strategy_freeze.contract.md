# B-025: Snapshot Strategy Freeze (Append-Only) Contract

## 1. Scope
- Definition of the append-only snapshot storage model.
- Rules for Workspace and Snapshot record immutability.
- Atomic execution requirements for save operations.

## 2. Non-goals
- Garbage Collection (GC) policies for old snapshots.
- Specific backup file formats (defined in B-026).
- Schema migration logic (defined in B-027).

## 3. Definitions
- **Workspace**: A container entity that tracks metadata and points to the current active state via `head_snapshot_id`.
- **Snapshot**: An immutable record containing the full workspace state (`payload_json`) at a specific point in time.
- **Append-only**: A strategy where new data is always added as new records, and existing records are never modified.

## 4. Contract Rules
- **Immutability**: Once a Snapshot is created, any UPDATE or DELETE operation on its record is strictly prohibited.
- **Workspace Initialization Policy**:
    - When a new Workspace is created, an initial Snapshot must be automatically created.
    - `head_snapshot_id` must never be NULL.
    - Every Workspace must always contain at least one Snapshot record.
    - The initial Snapshot must contain a valid `payload_json` and `schema_version`.
- **Save Operation**: Every "Save" action must be implemented as:
    1. **INSERT** a new Snapshot record.
    2. **UPDATE** the Workspace `head_snapshot_id` to the new Snapshot ID.
- **Atomicity**: The Save operation must be executed within a single database transaction. If any part fails, the entire operation must be rolled back.
- **Pointer Validity**: `head_snapshot_id` must always point to a valid and existing Snapshot record belonging to that Workspace.
- **Payload Integrity**: The `payload_json` in a Snapshot must contain the complete serialized state of the workspace (tree structure, snippets, and metadata).

## 5. Acceptance Criteria
- Executing a Save operation must increase the total count of Snapshot records by exactly one.
- No existing Snapshot records are altered during or after a Save operation.
- The Workspace's `head_snapshot_id` is updated to the newly created Snapshot's ID upon success.
- If the transaction fails, the `head_snapshot_id` remains at its previous value and no new Snapshot is persisted.

## 6. Constraints
- Manual editing of Snapshot records is prohibited.
- Overwriting existing Snapshot rows is a structural violation.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (025)
- [x] Snapshot Immutability 명시
- [x] Save = INSERT + head update 정의
- [x] 원자성(트랜잭션) 요구사항 포함
- [x] UPDATE/DELETE 금지 명시
