# **🚀 MEMORY MODEL (03)**

이 문서는 LangGraph의 장기 기억 체계인 **3층 메모리 모델**의 구현 규칙을 정의한다. 본 시스템은 Summary 기반이 아닌 **Decision / Evidence / Anchor** 중심 구조를 따른다.

---

## **1. Memory Entity Types**

*   **Decision (결정)**: 앞으로 계속 적용해야 하는 선택 또는 고정 규칙 (의미 SSOT).
*   **Evidence (근거)**: 재사용 가능한 지식 자산 (Content Asset), 원문 스냅샷.
*   **Anchor (네비게이션 힌트)**: 대화 압축 중 Letta 레이어에서 생성되는 이정표.

---

## **2. Decision Versioning & Persistence**

*   **Persistence [LOCK]**: SAVE_DECISION 선택 즉시 DB(SQLite v1)에 영구 저장된다. 세션 종료 시까지 대기하지 않는다.
*   **Version Chain [LOCK]**: 수정 시 overwrite가 아닌 새 version을 생성한다. `rootId`를 통해 변경 이력을 추적하며, 이전 버전은 `isActive=false` 처리된다.
*   **Version Atomicity**: 이전 버전 비활성화와 신규 버전 삽입은 원자적으로 수행되어야 하며, 실패 시 Fail-fast 한다.

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

---

## **5. Anchor Navigation Contract**

Anchor는 네비게이션 힌트일 뿐이며, 아래의 규칙을 준수해야 한다.

*   **Navigation Hint Only**: Anchor를 통한 탐색 결과는 반드시 상위 계층(`axis → lock → normal`)의 우선순위 로딩 규칙을 준수해야 하며, 이를 우회하여 우선순위를 변경할 수 없다.
*   **Original Source Access**: 상세 내용은 반드시 Evidence나 Decision 원문을 참조하도록 유도한다.
*   **Hierarchy Compliance**: Anchor는 하위 강도의 결정을 상위 강도의 결정보다 우선시할 수 없다.

---
*Last Updated: 2026-02-24 (Memory Contract)*
