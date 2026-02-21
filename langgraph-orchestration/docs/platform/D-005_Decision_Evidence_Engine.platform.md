# D-005: Decision / Evidence Engine Platform

## 1. SQLite Schema Definition

```sql
-- Decision Table (Versioned Chain)
CREATE TABLE decisions (
    id TEXT PRIMARY KEY,
    root_id TEXT NOT NULL,
    version INTEGER NOT NULL,
    previous_version_id TEXT,
    text TEXT NOT NULL,
    strength TEXT CHECK(strength IN ('axis', 'lock', 'normal')) NOT NULL,
    scope TEXT NOT NULL,
    is_active INTEGER DEFAULT 1, -- 1: true, 0: false
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(root_id, version)
);

-- Evidence Table (NOT NULL Constraint)
CREATE TABLE evidences (
    id TEXT PRIMARY KEY,
    content TEXT NOT NULL,
    decision_ref TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(decision_ref) REFERENCES decisions(id)
);

-- Anchor Table
CREATE TABLE anchors (
    id TEXT PRIMARY KEY,
    hint TEXT NOT NULL,
    target_ref TEXT NOT NULL,
    type TEXT CHECK(type IN ('evidence_link', 'decision_link')) NOT NULL
);
```

### Scope Validation Policy (Application Level)

- scope 값은 DB 레벨 CHECK 제약 대신, 애플리케이션 레벨에서 허용 도메인 목록과 대조하여 검증한다.
- 허용되지 않은 scope 값은 Fail-Fast 처리한다.

## 2. Indexing Strategy
- **Versioning 최적화**: `CREATE INDEX idx_decisions_root_version ON decisions(root_id, version);`
- **Retrieval 최적화**: `CREATE INDEX idx_decisions_scope_strength_active ON decisions(scope, strength, is_active);`

## 3. Retrieval Query Logic (Hierarchical Loading)

런타임은 다음 쿼리를 계층적으로 실행하여 결과를 수집한다.

```sql
-- Step 1: Global Axis
SELECT * FROM decisions WHERE is_active = 1 AND scope = 'global' AND strength = 'axis';

-- Step 2: Domain Axis
SELECT * FROM decisions WHERE is_active = 1 AND scope = ? AND strength = 'axis';

-- Step 3: Domain Lock
SELECT * FROM decisions WHERE is_active = 1 AND scope = ? AND strength = 'lock';

-- Step 4: Domain Normal
SELECT * FROM decisions WHERE is_active = 1 AND scope = ? AND strength = 'normal';
```

## 4. Anchor Integrity Guide (Non-FK, LOCK)

- Anchor는 `type`에 따라 `target_ref`의 의미가 결정된다.
  - type='decision_link'  → target_ref는 decisions.id
  - type='evidence_link'  → target_ref는 evidences.id
- SQLite 레벨에서 FK로 강제하지 않으며, 애플리케이션 레벨 검증으로 무결성을 보장한다.
- 저장 시 type과 target_ref의 대상 테이블이 불일치하면 Fail-Fast 한다.
- Anchor는 Decision의 특정 version을 가리킨다.
- 신규 version 생성 시 기존 Anchor를 자동 업데이트하지 않는다.
- 이는 역사적 맥락 보존을 위한 설계 원칙이다.

## 5. Write Implementation Rules
- **Decision Chain Update**: 기존 버전 비활성화와 신규 버전 삽입은 단일 트랜잭션으로 원자성을 보장한다.
- **Immediate Commit**: WAL 모드를 활용하며 `SAVE_DECISION` 처리 직후 즉시 `COMMIT`을 실행한다.
