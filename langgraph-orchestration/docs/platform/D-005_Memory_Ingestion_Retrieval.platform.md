# D-005: Memory Ingestion + Retrieval Platform

## 1. Lifecycle Connection

메모리 관리 작업은 런타임의 `Execution Cycle` 내에서 특정 지점에 연결되어 실행된다.

### **PersistMemory (Save)**
- `PersistMemory`는 `executionPlan`에 정의된 Step을 통해 호출된다. `LLMCall` 이후 자동으로 수행되지 않는다.
- `SummarizeMemory` Step의 Output(`summary`, `keywords`)을 입력으로 받아 `MemoryStore.save()`를 호출한다.
- Step 간 데이터 전달은 Core Engine의 개입 없이 `executionPlan`의 I/O 정의에 의해 수행된다.
- Execution Cycle이 성공적으로 종료된 이후에만 `MemoryStore.save()`가 반영된다.
- 부분 성공 상태에서의 저장은 금지된다.

### **RetrieveMemory (Load)**
1. `ContextSelect` 단계 시작 시점에 트리거됨.
2. `executionPlan`에 `RetrieveMemory` Step이 존재하는지 확인.
3. 존재 시, `metadata`에서 `TopK` 값을 읽어 `MemoryStore`의 `search()` 메서드 호출.
4. 검색 결과를 `ContextSelect`로 반환.

## 2. Interface Definition

시스템은 추상화된 인터페이스를 통해 메모리 저장소에 접근하며, MVP에서는 SQLite 기반의 구현체를 사용한다.

- **MemoryStore (Interface)**: `save()`, `search()`, `getById()` 등의 표준 명세 제공.
- **SQLiteMemoryStore (Implementation)**: `ops/runtime/runtime.db`의 `memories` 테이블을 직접 다루는 구현체.

## 3. Data Flow Overview

```bash
User Input
    ↓
ContextSelect (필수 컨텍스트 수집 단계)
    ↑
Retrieval (선택적, executionPlan Step 기반 실행)
    ↓
PromptAssemble (수집된 컨텍스트 조립 단계)
```

## 4. Error Flow

메모리 관련 작업의 실패는 데이터 무결성과 답변 정합성을 위해 엄격하게 처리된다.

- **SummarizeMemory Failure**: 요약 생성 중 오류 발생 시 해당 `Execution Cycle`은 즉시 실패로 처리된다.
- **RetrieveMemory Failure**: 검색 실행 중 오류 발생 시 해당 `Execution Cycle`은 즉시 실패로 처리된다.
- **Storage Write Failure (`PersistMemory`)**: `MemoryStore` 저장 실패 시 **Fail-Fast** 원칙에 따라 런타임을 즉시 중단한다.
