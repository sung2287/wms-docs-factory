# B-006: Storage Layer (SQLite v1) Contract

## 1. Functional Scope & Prohibition Rules

- **Pure Data Storage**: Storage Layer는 오직 데이터의 보관 및 조회 책임만을 진다. 정책 판단, 리포지토리 재스캔 여부 결정, 검색 알고리즘 선택 등 어떠한 "판단 로직"을 수행하는 것을 엄격히 금지한다.
- **Decision Responsibility**: 리포지토리 재스캔 여부에 대한 결정은 오직 `Repo Plugin`의 책임이며, Storage는 판단을 위한 기초 데이터만을 제공해야 한다.
- **Step Neutrality**: Storage Layer는 `executionPlan`을 해석하거나 특정 Step의 실행 여부를 스스로 판단하지 않는다.

## 2. Schema & Data Invariants

- **Whitelisted Tables Only**: 아래 테이블 외의 추가 테이블 생성을 금지한다.
    - `schema_version`, `memories`, `repository_snapshots`
- **Restricted Columns**: `memories` 테이블에 `raw_content` 또는 LLM 응답 원문을 저장하는 컬럼 추가를 금지한다.
- **No Temporary Tables**: 분석 결과의 임시 저장을 위한 테이블이나 정책 관련 메타데이터 저장을 금지한다.

## 3. Connection & Migration Rules

- **Single Connection Only**: 단일 SQLite Connection만을 허용하며, Connection Pool 또는 외부 데이터베이스 연결(PostgreSQL 등)을 금지한다.
- **Manual Migration Only**: 데이터 무결성을 위해 자동 마이그레이션(Auto-migration/Silent schema patch)을 엄격히 금지한다.
- **Version Integrity**: `schema_version` 불일치 감지 시 시스템은 즉시 실행을 중단(Fail-Fast)해야 한다.

## 4. Failure Handling & Neutrality

- **Write Fail-Fast**: 데이터 쓰기(Insert/Update/Delete) 실패 시 무결성 보호를 위해 런타임을 즉시 중단(Fail-Fast)해야 한다.
- **Read Error Propagation**: 데이터 읽기(Select) 실패 시 이를 Silent Ignore 처리하지 않고, 반드시 상위 레이어로 에러를 전파해야 한다.
- **Implementation Hiding**: Core Engine은 SQLite 구현 세부 사항(SQL 문법, 라이브러리 의존성 등)을 알지 못해야 하며, 오직 추상화된 Storage 인터페이스에만 의존해야 한다.
