# B-027: Schema Version / Migration Freeze Contract

## 1. Scope
- Mandatory schema versioning for all snapshots.
- Rules for explicit, sequential migrations.
- Immutability of source snapshots during transformation.

## 2. Non-goals
- UI/UX design for migration consent (handled in UX PRD).
- Background "Silent" migrations.

## 3. Definitions
- **schema_version**: A mandatory identifier denoting the data structure of a snapshot.
- **Migration**: The process of transforming a snapshot from version N to version N+1.
- **Sequential Migration**: A policy where moving from v1 to v3 requires a v1->v2 step followed by a v2->v3 step.

## 4. Contract Rules
- **Mandatory Versioning**: Any Snapshot record without a `schema_version` is considered invalid. Backup files must also include a top-level `schema_version`.
- **Append-only Migration**: Migration must NEVER modify an existing Snapshot. It must result in a **new** Snapshot record.
- **Traceability**: Migrated snapshots must include a `migrated_from_snapshot_id` field in their metadata to point to the source snapshot.
- **Explicit User Consent**: Automatically performing migrations without user awareness (Silent Migration) is strictly prohibited.
- **Sequential Constraint**: Version jumps are prohibited. Migrations must follow the defined version chain.
- **Atomicity**: A migration operation must be wrapped in a single transaction.

## 5. Acceptance Criteria
- Every saved Snapshot contains a valid `schema_version`.
- Migration results in the creation of a new Snapshot record with the target version.
- The original Snapshot remains unchanged after migration.
- `migrated_from_snapshot_id` correctly points to the source snapshot.
- If a migration step fails, the entire chain is rolled back.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (027)
- [x] schema_version 필수성 명시
- [x] Silent Migration 금지 명시
- [x] Append-only(신규 생성) Migration 명시
- [x] 순차 적용(Sequential) 원칙 포함
