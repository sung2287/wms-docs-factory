# C-027: Schema Version / Migration Freeze Intent Map

## 1. Scope
- Validation of version-based rejection and approval flows.
- Verification of the append-only migration process.
- Confirmation of traceability and rollback on failure.

## 2. Non-goals
- Testing specific transformation logic details.

## 3. Scenarios & Expectations

### Scenario 1: Rejection of Version-less Data
- **Given**: A backup file or snapshot data without a `schema_version`.
- **When**: System attempts to load or import the data.
- **Expectation**: Operation is rejected with an error.

### Scenario 2: Migration Approval Flow
- **Given**: A backup file with an older `schema_version`.
- **When**: User attempts Restore.
- **Expectation**:
    - System detects the version gap.
    - System requests user approval for migration.
    - No migration starts until approval is granted.

### Scenario 3: Successful Sequential Migration
- **Given**: Source Snapshot S1 (v1).
- **When**: Migration to v2 is triggered.
- **Expectation**:
    - New Snapshot S2 (v2) is created.
    - S2.migrated_from_snapshot_id == S1.id.
    - S1 remains unchanged in the database.

### Scenario 4: Migration Rollback on Failure
- **Given**: A migration chain.
- **When**: A step in the chain fails.
- **Expectation**:
    - No new snapshots are persisted (Transaction rollback).
    - Workspace head remains at the original version.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (027)
- [x] 구버전 감지 시 승인 요청 확인 포함
- [x] Migration 성공 시 신규 Snapshot 생성 확인 포함
- [x] migrated_from_snapshot_id 기록 확인 포함
- [x] 실패 시 롤백 확인 포함
