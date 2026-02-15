# C-026: Workspace Backup / Restore v1 Intent Map

## 1. Scope
- Verification of the Export JSON structure.
- Validation of the Import process integrity.
- Confirmation of ID collision prevention and schema version checking.

## 2. Non-goals
- Testing large file performance (handled in Platform D).

## 3. Scenarios & Expectations

### Scenario 1: Successful Export
- **Given**: Workspace W1 with 5 Snapshots.
- **When**: Export is triggered.
- **Expectation**: A JSON file is generated containing W1 metadata and an array of 5 Snapshot objects.

### Scenario 2: Restore Integrity (Snapshot Count & Order)
- **Given**: A valid Export JSON from Workspace W1 with 5 Snapshots.
- **When**: Import is performed.
- **Expectation**:
    - A new Workspace W2 is created.
    - 5 new Snapshots are created and associated with W2.
    - The order of snapshots (created_at) is preserved.
    - `head_snapshot_id` of W2 points to the logical equivalent of W1's head.

### Scenario 3: ID Collision Prevention
- **Given**: An Export JSON containing Snapshot ID "S-100".
- **When**: Import is performed.
- **Expectation**: The new database record has a different UUID, not "S-100", but the content remains identical.

### Scenario 4: Incompatible Schema Version
- **Given**: A Backup JSON with `schema_version: "v999"` (unsupported).
- **When**: Import is attempted.
- **Expectation**: The system rejects the file with a "Unsupported Schema Version" error. No data is written to the DB.

### Scenario 5: Transactional Rollback on Import Failure
- **Given**: A valid Backup JSON.
- **When**: Import fails halfway (e.g., DB connection loss).
- **Expectation**: No partial Workspace or orphaned Snapshots remain in the database.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (026)
- [x] Export -> Import 후 Snapshot 개수 및 상태 검증 포함
- [x] ID 충돌 방지(신규 생성) 확인 포함
- [x] schema_version 불일치 거부 확인 포함
