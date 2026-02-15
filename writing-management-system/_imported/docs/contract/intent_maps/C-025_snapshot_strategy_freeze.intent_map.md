# C-025: Snapshot Strategy Freeze (Append-Only) Intent Map

## 1. Scope
- Verification of the append-only behavior during workspace save.
- Validation of pointer (head_snapshot_id) movement.
- Confirmation of record immutability and transactional integrity.

## 2. Non-goals
- Testing storage capacity limits or performance.

## 3. Scenarios & Expectations

### Scenario 0: Workspace Initialization
- **Given**: A new Workspace is created.
- **Expectation**:
    - Exactly one Snapshot record is created.
    - `head_snapshot_id` is not NULL.
    - The initial Snapshot contains a valid serialized empty state.

### Scenario 1: Successful Workspace Save
- **Given**: A Workspace with `head_snapshot_id` = S1 and total snapshot count = N.
- **When**: A Save operation is triggered.
- **Expectation**:
    - A new Snapshot S2 is created (INSERT).
    - Total snapshot count becomes N + 1.
    - Workspace `head_snapshot_id` becomes S2.
    - S1 remains identical to its state prior to the save.

### Scenario 2: Immutability Verification
- **Given**: A previously saved Snapshot S1.
- **When**: Any system process or user attempts to modify the `payload_json` of S1.
- **Expectation**: The operation is rejected or fails at the database level (Structural constraint).

### Scenario 3: Save Transaction Failure (Rollback)
- **Given**: A Workspace with `head_snapshot_id` = S1.
- **When**: A Save operation is initiated but fails during the `head_snapshot_id` update.
- **Expectation**:
    - No new Snapshot record is left in the database (Rollback).
    - Workspace `head_snapshot_id` remains S1.

### Scenario 4: Snapshot Pointer Validity
- **Given**: A Workspace pointing to `head_snapshot_id` = S2.
- **When**: S2 is queried.
- **Expectation**: The record S2 exists and is associated with the correct `workspace_id`.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (025)
- [x] Save 시 Snapshot row 증가 검증 포함
- [x] 기존 Snapshot 불변 확인 시나리오 포함
- [x] head_snapshot_id 변경 확인 포함
- [x] 트랜잭션 실패 시 롤백 확인 포함
