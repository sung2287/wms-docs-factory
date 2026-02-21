# D-006: Storage Layer (SQLite v1) Platform

## 1. Directory Structure

SQLite 데이터베이스 파일은 프로젝트 루트의 아래 경로에서 관리된다:
```bash
ops/runtime/
    └── runtime.db
```

## 2. Initialization Flow (Runtime Boot)

런타임 시작 시 저장소 계층은 아래 단계를 거쳐 준비된다.

1. **Directory Check**: `ops/runtime/` 디렉토리가 존재하는지 확인.
2. **Permission Check**: 해당 디렉토리에 대한 읽기 및 쓰기 권한이 있는지 명시적으로 검증.
3. **Database Creation**: `runtime.db` 파일이 없으면 새로 생성하고 초기 스키마를 주입함.
4. **Schema Version Verification**: `schema_version` 테이블을 조회하여 애플리케이션 요구 버전과 일치하는지 확인.
5. **Fail-Fast**: 버전 불일치 또는 권한 부족 시 즉시 실행을 중단함.

## 3. Interface Structure

시스템은 추상화된 인터페이스를 통해 영속화 계층에 접근한다.

- **Storage (Interface)**: `connect()`, `disconnect()`, `execute()`, `query()` 등의 표준 명세 제공.
- **SQLiteStorage (Implementation)**: 실제 `sqlite3` 라이브러리를 사용하여 로컬 파일에 접근하는 구현체.
- **MemoryStore & SnapshotStore**: `Storage` 인터페이스 위에서 동작하며, 각 도메인별 데이터 접근 로직(DAO)을 제공함.

## 4. Data Flow Overview

영속화 작업은 `executionPlan`에 정의된 Step에 의해 유도된다.

### **Save Flow**
```bash
SummarizeMemory Step (Execution Cycle 종료 전)
    ↓
MemoryStore.save() (MemoryItem 객체 수신)
    ↓
SQLiteStorage.insert() (SQL Query 실행)
```

### **Search Flow**
```bash
RetrieveMemory Step (ContextSelect 단계)
    ↓
MemoryStore.search() (검색 조건 전달)
    ↓
SQLiteStorage.query() (SQL Result 반환)
```

## 5. Error Flow

- **Write Failure**: 메모리 저장 또는 스냅샷 업데이트 실패 시 즉시 종료 (**Fail-Fast**).
- **Database Connection Error**: DB 파일 오픈 또는 잠금 해제 실패 시 즉시 종료 (**Fail-Fast**).
- **Schema Mismatch**: 지원하지 않는 스키마 버전 감지 시 즉시 종료 (**Fail-Fast**).
- **Read Error**: 쿼리 실행 중 문법 오류나 파일 손상 발생 시 상위 레이어로 에러 전파.
