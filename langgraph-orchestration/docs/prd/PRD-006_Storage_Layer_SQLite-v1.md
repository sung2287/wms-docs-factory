# PRD-006: Storage Layer (SQLite v1)

## Objective
Memory 및 Repository Snapshot 영속 데이터 관리를 위해 SQLite 기반의 단일 로컬 저장소 레이어를 구축한다.

## Background
- 파일 기반 저장(JSON)의 검색 한계를 보완하기 위해 SQLite를 사용함.
- Core 런타임의 추상화된 Storage 인터페이스를 제공하여 구현 세부 사항을 은닉함.

## Scope
- SQLite DB 파일 위치 정의: `ops/runtime/runtime.db`.
- `memories` 테이블 설계 및 구현 (PRD-005 데이터 구조 준수).
- `repository_snapshots` 메타 데이터 테이블 설계 및 구현.
- 단일 Connection 기반 CRUD 인터페이스 및 인덱스 생성.
- SQLite 라이브러리 import는 Storage Layer 내부에서만 허용.

## Non-Goals
- 자동 마이그레이션 로직 (버전 불일치 시 Fail-Fast).
- `memories` 테이블 내 `raw_content` 컬럼 저장.
- Repo 재스캔 여부 판단 (Repo Plugin 책임).

## Architecture
- **Storage Core**: SQLite 단일 연결 관리.
- **Migration Manager**: `schema_version` 테이블을 활용하되, 버전 불일치 시 자동 수정을 하지 않고 **Fail-Fast**함.
- **Initialization**: `runtime.db` 생성 전 디렉토리 쓰기 권한을 명시적으로 확인하며 실패 시 즉시 종료함.
- **Storage Interface Dependency**: Core 런타임은 Storage 인터페이스에만 의존함.
- **Neutrality Rule**: 모든 런타임 동작은 executionPlan에 정의된 Step을 통해서만 실행된다. Core Engine은 직접적인 기능 플래그(Boolean), 정책 파일, 저장 구현을 참조하지 않는다.

## Data Structures
### Schema Overview
1.  **schema_version**: 스키마 버전 관리 (`version`, `applied_at`).
2.  **memories**: PRD-005의 MemoryItem 저장.
    - `id` (PRIMARY KEY), `session_id`, `timestamp`, `summary`, `keywords` (JSON/TEXT).
3.  **repository_snapshots**: 리포지토리 스캔 메타데이터.
    - `version_id`, `repo_path`, `file_count`, `last_scanned_at`.

## Execution Rules
- **DB 초기화**: `ops/runtime/` 디렉토리 부재 시 생성 후 `runtime.db` 초기화.
- **Core Engine 독립성**: Core Engine은 저장 계층, 요약 알고리즘, 검색 알고리즘의 구현 세부사항을 알지 못한다. 모든 동작은 executionPlan에 정의된 Step을 통해 간접적으로 호출된다.
- **의존 관계**: 
  - PRD-004, PRD-005에 독립적.
  - 단, MemoryStore 구현 시 PRD-005의 데이터 구조를 따름.

## Failure Handling
- **Write 실패**: 즉시 Fail-Fast (데이터 무결성 보호).
- **Read 실패**: 상위 레이어로 에러 전파 (Silent Ignore 금지).
- **데이터 무결성**: 데이터 무결성에 영향을 주는 모든 실패는 Fail-Fast 원칙을 따른다. Best-Effort는 사용자 경험에만 적용되며, 저장 계층에서는 허용되지 않는다.

## Success Criteria
- SQLite 단일 연결을 통해 데이터 저장 및 조회가 정상 수행됨.
- 버전 불일치 또는 권한 부족 시 즉시 실행을 중단하여 안전을 보장함.
- Core 런타임이 인터페이스를 통해서만 Storage Layer에 접근함.
- 리포지토리 스캔 억제를 위해 Repo Plugin에 필요한 정확한 데이터를 제공함.
