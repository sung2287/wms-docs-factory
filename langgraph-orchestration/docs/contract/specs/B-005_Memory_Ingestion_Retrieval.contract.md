# B-005: Memory Ingestion + Retrieval Contract

## 1. Storage Invariant Rules (Prohibitions)

- **Raw Content Storage Prohibited**: `raw_content` 또는 LLM의 전체 응답(Full Response)을 메모리 저장소에 직접 저장하는 것을 엄격히 금지한다.
- **Storage Field Whitelist**: 아래 필드 외의 데이터 저장을 금지한다.
    - `id`, `sessionRef`, `timestamp`, `summary`, `keywords`
- **Internal Index Exposure Prohibited**: Retrieval 결과 반환 시 내부 인덱스 데이터인 `keywords` 배열을 외부로 노출하는 것을 금지한다.

- **Step-Driven Summary**: Summary 생성은 오직 `executionPlan`에 정의된 `SummarizeMemory` Step을 통해서만 수행되어야 한다. Core Engine이 스스로 요약 여부를 판단하거나 실행하는 것을 금지한다. `SummarizeMemory`는 저장을 수행하지 않는다.
- **Explicit Keyword Generation**: `keywords` 생성은 `executionPlan`에 정의된 명시적 Step(`SummarizeMemory`)을 통해서만 수행된다. `MemoryStore`는 키워드 생성 로직을 가지지 않으며, `RetrieveMemory`는 키워드를 수정하거나 자동 생성하지 않는다.
- **Stage Restriction**: `RetrieveMemory`는 반드시 `ContextSelect` 단계에서만 수행되어야 한다. `PromptAssemble` 단계에서 직접 검색을 수행하거나 저장소에 접근하는 것을 금지한다.
- **Explicit Metadata Only**: `TopK` 값은 반드시 `executionPlan`의 metadata를 통해 전달되어야 한다. `RetrieveMemory` 내부에 하드코딩된 기본값(Default)을 정의하는 것을 금지한다.

## 3. Data Flow & Output Contract

- **PersistMemory Restriction**: `MemoryStore.save()` 호출은 반드시 `PersistMemory` Step을 통해서만 수행되며, 전체 Execution Cycle이 성공적으로 종료된 이후에만 최종 반영된다.
- **Retrieval Output Restriction**: 검색 결과는 반드시 `summary`, `id`, `timestamp` 세 가지 필드만 포함하여 반환해야 한다.
- **Partial Result Prohibited**: `ContextSelect`는 `RetrieveMemory` Step이 완벽하게 성공하여 반환한 데이터 집합만을 수용한다. 데이터의 일부만 검색되거나 손상된 상태의 부분 성공(Partial Result) 수용을 금지한다.

## 4. Failure & Neutrality Rules

- **No Silent Fallback**: Retrieval 실행 중 오류가 발생할 경우, 이를 무시하고 빈 결과를 반환하는 식의 Silent Fallback을 엄격히 금지한다. 오류 발생 시 해당 `Execution Cycle`은 즉시 실패로 처리되어야 한다.
- **Fail-Fast Write**: 메모리 저장(Write) 실패 시 데이터 무결성 보호를 위해 즉시 실행을 중단(Fail-Fast)해야 한다.
- **Algorithmic Neutrality**: Core Engine은 검색 알고리즘이나 요약 알고리즘의 세부 구현을 알지 못해야 하며, `MemoryStore`는 정책(Policy)을 해석하거나 결정하지 않는 수동적 상태를 유지해야 한다.
- **Step Data Passing Rule**: `SummarizeMemory`의 출력은 `executionPlan`의 명시적인 Step Output 메커니즘을 통해서만 `PersistMemory`의 입력으로 전달되어야 한다.
- **Global Temp Storage Prohibited**: Core Engine 내부에 Step 간 데이터 전달을 위한 전역 임시 저장소(Global Temp Storage)를 두는 것을 엄격히 금지한다.
