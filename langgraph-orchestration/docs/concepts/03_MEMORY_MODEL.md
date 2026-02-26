# **🚀 MEMORY MODEL (03)**

이 문서는 LangGraph의 장기 기억 체계인 **3층 메모리 모델**의 구현 규칙을 정의한다. 본 시스템은 Summary 기반이 아닌 **Decision / Evidence / Anchor** 중심 구조를 따른다.

---

## **1. Memory Entity Types**

*   **Decision (결정)**: 앞으로 계속 적용해야 하는 선택 또는 고정 규칙 (의미 SSOT).
*   **Evidence (근거)**: 재사용 가능한 지식 자산 (Content Asset), 원문 스냅샷.
*   **Anchor (네비게이션 힌트)**: 대화 압축 중 Letta 레이어에서 생성되는 이정표.

---

### DecisionProposal Status Declaration

DecisionProposal은 Memory Entity가 아니다.

- DecisionProposal은 영구 저장 대상이 아니다.
- Commit 이전의 Proposal은 Runtime 레벨의 임시 객체로 간주된다.
- Version Chain은 Commit 시점에만 생성된다.
- Proposal은 overwrite 또는 Memory SSOT를 우회할 수 없다.

LOCK:
Proposal 단계는 Decision SSOT를 대체할 수 없다.

---

## **2. Decision Versioning & Persistence**

*   **Persistence [LOCK]**: SAVE_DECISION 선택 즉시 DB(SQLite v1)에 영구 저장된다. 세션 종료 시까지 대기하지 않는다.
*   **Version Chain [LOCK]**: 수정 시 overwrite가 아닌 새 version을 생성한다. `rootId`를 통해 변경 이력을 추적하며, 이전 버전은 `isActive=false` 처리된다.
*   **Version Atomicity**: 이전 버전 비활성화와 신규 버전 삽입은 원자적으로 수행되어야 하며, 실패 시 Fail-fast 한다.

### **Backward Compatibility & Upgrade Principle (Memory SSOT Safe)**

Decision은 Version Chain을 통해 변경 이력을 보존하며,
과거 데이터(세션/증거/결정)를 "강제 변환"하여 덮어쓰지 않는다.

- 업그레이드/변경은 overwrite가 아니라 새 version 추가로 표현된다.
- 과거 기록은 참조 가능한 상태로 유지되어야 한다.
- 호환성 문제는 Core Memory SSOT를 훼손하지 않는 별도 호환/마이그레이션 계층에서 다룬다.

(이 원칙은 SSOT 무결성과 장기 감사 가능성을 유지하기 위한 운영 규범이다.)

### **High-Volume Decision Scalability Principle**

Decision 저장 수가 대규모(예: 100,000+)로 증가하더라도,
기본 실행 경로는 "활성 버전(Active Version)"만을 기본 조회 대상으로 한다.

- 과거 Version Chain은 기본 실행 경로에서 자동 로딩되지 않는다.
- 이력 탐색은 별도 요청 또는 감사 경로로 제한된다.
- 기본 Retrieval은 Domain/Scope 경계 내에서 수행된다.

LOCK:
대규모 데이터 증가를 이유로 Loading Order [LOCK]를 우회할 수 없다.

---

## **3. Strength Hierarchy & Scope**

의미 구조의 강도와 적용 범위를 제어한다.

### **3.1 Strength Hierarchy [LOCK]**
*   **axis**: 설계 축 / 철학 수준의 방향 고정 (최우선).
*   **lock**: 쉽게 바꾸지 않는 고정 규칙.
*   **normal**: 일반 결정.

### **3.2 Domain Scope [LOCK]**
*   **global**: 모든 도메인에 적용.
*   **domain (runtime, coding, wms, ui 등)**: 특정 영역에만 적용되는 Decision `scope` 필드와 매핑.

### **3.3 Structural Layer (Impact Analysis) [LOCK]**
*   **Relationship Graph**: 단순 Scope 필터링이 아니라, Decision 간 명시적 관계(예: DEPENDS_ON, CONSTRAINS, VALIDATES 등)를 그래프 구조로 표현하여 영향 범위(Blast Radius)를 계산한다.
*   **Guardian Integration**: 이 계층은 Guardian Layer의 영향 분석(Impact Analysis)에 사용되며, 텍스트 유사도가 아닌 관계 기반 검증을 담당한다.

Structural Layer의 관계 그래프는 단순 검색 최적화를 넘어,
Decision Trace의 영향 범위(Blast Radius)를 설명 가능하게 만드는 기반이다.
이는 장기적으로 Audit/Evidence 인프라(Decision Infrastructure) 확장 시
"왜 이 결정이 필요했고 무엇을 깨뜨리는지"를 재현하는 구조적 근거가 된다.

### **Impact Analysis Boundary Principle (Graph Expansion Control)**

Structural Layer의 영향 분석(Impact Analysis)은
명시적으로 정의된 Relationship Graph 범위 내에서만 수행된다.

- 암묵적 추론 또는 무제한 전파 탐색을 수행하지 않는다.
- 텍스트 유사도 기반 확장 탐색은 Structural Layer의 책임이 아니다.
- Blast Radius 계산은 명시적 관계(DEPENDS_ON, CONSTRAINS, VALIDATES 등)로 연결된 노드 집합으로 제한된다.

LOCK:
Impact Analysis는 Semantic Layer 탐색으로 확장될 수 없으며,
Loading Order [LOCK]를 우회하는 근거가 될 수 없다.

### **Cycle Safety Principle (Structural Graph Stability)**

Relationship Graph는 순환 관계(Cycle)를 포함할 수 있으나,
Impact Analysis는 무한 반복 탐색을 수행하지 않는다.

- 동일 노드의 재방문은 탐색 종료 조건으로 처리된다.
- Blast Radius 계산은 유한한 명시적 관계 집합으로 제한된다.
- Structural Layer는 그래프 이론적 완전 탐색을 수행하지 않는다.

LOCK:
순환 관계 존재는 Loading Order [LOCK] 또는
Semantic Layer 확장의 근거가 될 수 없다.

### **Structural Subgraph Boundary Principle**

Structural Layer의 영향 분석은
현재 실행 컨텍스트와 직접적으로 연결된 관계 Subgraph 내에서만 수행된다.

- 전체 Graph의 전량 탐색을 수행하지 않는다.
- 명시적 관계로 연결된 유한 노드 집합을 대상으로 한다.
- Subgraph 경계는 Semantic 확장의 근거가 될 수 없다.

LOCK:
Structural 분석은 Semantic Layer 탐색을 암묵적으로 트리거할 수 없다.

---

## **4. Retrieval Architecture**

### **4.1 Loading Order [LOCK]**
1.  **Policy Layer** 로드 (시스템 기본 원칙)
2.  **Structural Layer** 로드 (명시적 관계 및 영향 분석)
3.  `global + axis` 로드 (전역 최우선)
4.  `currentDomain + axis` 로드
5.  `currentDomain + lock` 로드
6.  `currentDomain + normal` 로드
7.  Anchor → Evidence/Decision 탐색

Structural Layer는 Semantic Layer를 우회할 수 없으며, Structural 분석 결과는 Semantic 유사도 검색보다 우선된다.

### **4.2 Domain vs Phase Separation [LOCK]**
*   **Phase (Execution Stage)**: 워크플로우 라우팅 제어 (design, implement 등).
*   **Domain (Semantic Scope)**: Decision 검색 필터링 기준. Phase와 독립적으로 명시적 유지되어야 한다.

### **Retrieval Cost Control Principle (Non-blocking Compatible)**

Retrieval은 Execution Flow를 변경하지 않는 Data Selection Layer이며,
Non-blocking 원칙과 충돌하지 않도록 비용 제어 원칙을 가진다:

- 상위 계층(Policy/Structural)의 결과가 우선이며, 불필요한 Semantic 확장을 최소화한다.
- Guardian 영향 분석(Structural Layer)은 관계 기반으로 수행하며 텍스트 유사도 비용에 종속되지 않는다.
- 비용이 큰 탐색(Anchor→Evidence 심층 탐색 등)은 필요 시 비동기/사후 분석으로 분리될 수 있다.

LOCK:
비용 제어는 "로딩 순서(LOCK)"를 위반하거나 우회하는 근거가 될 수 없다.

---

## **5. Anchor Navigation Contract**

Anchor는 네비게이션 힌트일 뿐이며, 아래의 규칙을 준수해야 한다.

*   **Navigation Hint Only**: Anchor를 통한 탐색 결과는 반드시 상위 계층(`axis → lock → normal`)의 우선순위 로딩 규칙을 준수해야 하며, 이를 우회하여 우선순위를 변경할 수 없다.
*   **Original Source Access**: 상세 내용은 반드시 Evidence나 Decision 원문을 참조하도록 유도한다.
*   **Hierarchy Compliance**: Anchor는 하위 강도의 결정을 상위 강도의 결정보다 우선시할 수 없다.

---
*Last Updated: 2026-02-25 (Scalability & Subgraph Hardening)*
