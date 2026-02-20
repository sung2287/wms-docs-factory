# PRD-005: Memory Ingestion + Retrieval (Keyword v1)

## Objective
대화 턴 요약을 저장하고 키워드 기반으로 과거 정보를 검색(Retrieval)하여 컨텍스트 선택 단계에 제공한다.

## Background
- 장기 기억(Long-term Memory)은 AI의 연속적인 문맥 파악에 필수적임.
- 단순 키워드 기반의 기억 검색 기능을 구현하여 MVP를 완성하고자 함.

## Scope
- 매 대화 턴 완료 시 Summary 생성 및 저장.
- MemoryItem 기반의 구조화된 데이터 관리.
- 단순 키워드 기반의 TopK 검색 기능 (v1).
- **ContextSelect** 단계에서 검색된 Memory 제공 (PromptAssemble은 조립만 수행).

## Non-Goals
- 벡터 기반 검색 및 임베딩 처리.
- Core 내부에서 직접 검색 활성화 여부 판단.
- `memories` 테이블 외 추가 데이터 저장.

## Architecture
- **Summary Generation**: Core Engine 외부의 `SummarizeMemory` Step으로 정의하며, `executionPlan`에 해당 Step이 명시적으로 포함되어야 함. 포함되지 않을 경우 수행되지 않으며 Core Engine은 생성 여부를 판단하지 않음.
- **Retriever**: `ContextSelect` 단계에서 실행되며, 검색 결과는 `summary + id + timestamp`로 제한됨 (내부 키워드 노출 금지).
- **Policy Dependency**: `TopK`는 `executionPlan` metadata에서 전달되며 Retriever는 고정된 기본값을 가지지 않음.
- **Session Scope**: Memory는 `sessionRef` 단위로만 저장 및 검색된다. 세션 간 메모리 공유(Cross-session retrieval)는 MVP 범위에 포함되지 않는다. `SessionState`의 `memoryRef`는 `MemoryStore` 내부 구조를 의미하지 않으며, `SessionStore`와 `MemoryStore`는 직접 참조하거나 결합되지 않는다.
- **Retrieval Algorithm**: 키워드 매칭 알고리즘은 `MemoryStore` 구현체 내부에 위치한다. Core Engine은 검색 알고리즘의 세부 구현을 알지 못하며, `search(query, topK)` 인터페이스만 호출한다.
- **Neutrality Rule**: 모든 런타임 동작은 executionPlan에 정의된 Step을 통해서만 실행된다. Core Engine은 직접적인 기능 플래그(Boolean), 정책 파일, 저장 구현을 참조하지 않는다.

## Data Structures
### MemoryItem (Internal Only)
```json
{
  "id": "uuid-v4",
  "timestamp": "ISO-8601-timestamp",
  "summary": "요약 텍스트",
  "keywords": ["tag1", "tag2"],
  "sessionRef": "session-id"
}
```

## Execution Rules
- **키워드 매칭 규칙**:
  - Case-insensitive 처리 및 단어 경계 기준 매칭 우선.
  - 정렬 기준: 매칭 키워드 수 → 최신순 (Recency).
- **PersistMemory 타이밍**: `PersistMemory`는 `executionPlan`에 정의된 Step을 통해 호출된다. `LLMCall` 직후 즉시 저장되지 않으며, `MemoryStore.save()`는 전체 Execution Cycle이 성공적으로 종료된 이후에만 최종 반영된다. Cycle 실패 시 저장은 취소되며, 부분 성공 상태에서의 저장은 금지된다.
- **Step 간 데이터 전달**: `SummarizeMemory` Step은 생성된 `summary` 및 `keywords`를 `executionPlan` 내부의 Step Output 영역에 기록한다. `PersistMemory` Step은 해당 Output을 입력으로 받아 `MemoryStore.save()`를 호출한다.
- **Core Engine 중립성**:
  Core Engine은 `summary`/`keywords`의 구조를 해석하지 않으며,
  저장 계층·요약 알고리즘·검색 알고리즘의 세부 구현을 알지 못한다.
  모든 동작은 executionPlan에 정의된 Step을 통해 수행된다.
  Core 내부에 전역 임시 저장소를 두는 것은 금지한다.
- **ContextSelect 책임**: `RetrieveMemory` Step이 성공적으로 반환한 데이터만을 전달하며, 부분 성공(Partial Result)은 허용되지 않음.
- **의존 관계**: 
  - PRD-004(SessionRef 존재)에 의존.
  - PRD-006(Storage 구현)에 선택적 의존.

## Failure Handling
- **데이터 무결성**: 데이터 무결성에 영향을 주는 모든 실패는 Fail-Fast 원칙을 따른다. Best-Effort는 사용자 경험에만 적용되며, 저장 계층에서는 허용되지 않는다.
- **Retrieval 실패**: 실행 중 오류 발생 시 해당 Execution Cycle은 실패로 간주하며, 오류는 상위 레이어로 전파됨. **Silent Fallback은 허용되지 않음**.
- **Hash Boundary**: `RetrieveMemory` Step의 metadata(TopK 포함) 및 `executionPlan` JSON은 PRD-004의 `lastExecutionPlanHash` 계산 대상에 포함된다. 검색 정책 변경은 플랜 변경을 통해 해시 불일치를 유발하며, Resume 시 해시 불일치가 발생하면 Fail-Fast가 적용된다.

## Success Criteria
- `ContextSelect` 단계에서 적절한 과거 메모리가 선택되어 프롬프트 조립 단계로 전달됨.
- 키워드 매칭 시 대소문자 구분 없이 정확한 단어 경계를 인식함.
- `executionPlan`에 정의된 Step에 따라 요약 및 검색이 수행됨.
