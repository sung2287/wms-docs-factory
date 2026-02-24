# **🚀 SYSTEM RUNTIME (02)**

이 문서는 LangGraph 기반 실행 엔진의 **구조와 계약(Contract)**을 정의한다. 본 시스템은 정책 중립적인 Core와 도메인 팩(Domain Pack)의 분리를 통해 무색무취의 오케스트레이션을 구현한다.

---

## **1. Runtime 역할 정의 (Executor vs Governance)**

*   **Executor (실행기)**: GraphState, Mode Router, Session Store를 관리하며 LLM 호출 및 프롬프트 조립을 수행한다.
*   **Governance (수호자)**: 번들 무결성 검증, 런타임-스키마 호환성 게이트, 가디언 루프(Guardian Loop)를 통한 정합성 검토를 수행한다.
*   **Non-blocking Principle**: 업무 실행 로직은 기본적으로 비차단 방식으로 작동한다. (상세는 4번 섹션 참조)

---

## **2. Builder ↔ Runtime ↔ Promotion 구조**

*   **Builder (Control Plane)**: 아키텍트가 UI로 파이프라인 설계, HITL 테스트 수행, manifest.json 포함 **Workflow Bundle** 생성.
*   **Promotion Pipeline (Deployment)**: 빌더에서 검증된 번들을 런타임 활성 저장소로 밀어 넣는 승격 과정.
*   **Active Bundle Store**: 런타임이 참조하는 활성 번들 물리 위치 (`ops/runtime/bundles/active`).

---

## **3. Workflow Bundle 구조 (Technical Spec)**

단순 JSON이 아닌, 버저닝된 아티팩트의 뼈대이다.

*   **Identity**: bundle_id, bundle_version, bundle_hash (LOCK-11/17 Sorted Map Hash).
*   **Components**: prompts[] (.md), policies[] (.yaml), rubrics[] (.json).
*   **Runtime Scope**: routing (모드 규칙), steps (입출력 Contract).
*   **R&D vs Prod Switch**: rd(HITL 허용) vs prod(Judge AI 승인 주체화).

---

## **4. Runtime Safety Contracts (LOCK)**

실행 중 발생할 수 있는 정책의 오류나 무결성 침해로부터 시스템을 보호하는 하드코딩된 계약이다.

### **4.1 Core-enforced Fallback [LOCK-4]**
*   Judge AI의 판단 실패, 보류, 불확실성 발생 시, 시스템은 번들의 정책이 아닌 Runtime Core의 Fallback Contract(재시도/에스컬레이션/중단)를 강제로 따른다.

### **4.2 Hash Mismatch & Integrity Fail-fast**
*   **조건**: bundle_hash 무결성 불일치, 런타임-스키마 호환성 위반, pin 파일 위변조 감지.
*   **동작**: 시스템은 신규 번들 활성화를 중단(Abort)하고 직전 정상 Active Bundle을 유지하거나, 실행을 즉시 Fail-fast 한다. 이는 정책 판단과는 독립적이다.

### **4.3 Version Compatibility Gate [LOCK-15]**
*   `min_runtime_version`을 통해 번들과 런타임 엔진 간의 버전 호환성을 엄격히 검증한다.

※ 정책 정합성 위반(Guardian BLOCK)은 Safety Contract 위반으로 간주되지 않는다. 이는 실행 중단 사유가 아니라, 개입 요청 상태 전환 사유이다.

---

## **5. Session Pinning & Bundle Resolution**

*   **Session Pinning [LOCK-12]**: 세션은 시작 시점의 `bundle_version`에 고정(Pinned)되며 실행 중 변경되지 않는다.
*   **Bundle Resolver**: 어댑터 레이어에서 manifest를 읽어 Core에 필요한 컨텍스트를 주입한다.

---

## **6. Extension Points (Revised Structure)**

### **6.1 Retrieval Strategy Injection**
*   **DecisionContextProviderPort** 기반 전략 주입.
*   Hierarchical / Semantic / Hybrid 전략 교체 가능.
*   **Data Selection Layer**에 해당하며, Execution Flow를 변경하지 않는다.

### **6.2 Execution Hook (Guardian Layer)**
*   **ExecutionPlan** 수준에서 실행 전/후 Validator Hook 호출.
*   Core는 훅을 호출하고 결과(ALLOW/WARN/BLOCK)를 해석만 한다.
*   Guardian은 ALLOW / WARN / BLOCK 신호를 생성할 수 있다. 단, BLOCK은 자동 실행 차단을 의미하지 않는다.
*   BLOCK은 “Intervention Required(추가 확인 필요)” 상태를 의미하며, Core는 이를 Human-in-the-loop 또는 명시적 override 승인 흐름으로 전환한다.
*   실행을 기술적으로 차단(Fail-fast)할 수 있는 권한은 오직 **Runtime Safety Contract**(무결성, 해시, 버전 호환성 위반 등)에 한정된다.
*   Retrieval Strategy와 다른 계층이다 (**Execution Layer**).

Guardian Loop는 Execution Hook 계층이며 Retrieval Strategy와 구분된다. Retrieval은 데이터 선택 전략이고, Guardian은 실행 전/후 검증 훅이다. Guardian의 BLOCK은 정책적 정합성 경고 수준의 개입 신호이며, Runtime Safety Contract 위반이 아닌 한 자동 실행 차단을 발생시키지 않는다.

---
*Last Updated: 2026-02-24 (System Contract)*
