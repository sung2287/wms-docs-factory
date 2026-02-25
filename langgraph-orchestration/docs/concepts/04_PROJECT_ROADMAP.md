# **🚀 PROJECT ROADMAP (04)**

본 문서는 Phase 0에서 시작하여 Phase 9까지의 의미적 진화 경로를 서술하며, 각 단계에서 무엇을 구축했고 무엇이 남았는지를 명확히 기록한다. 또한, 본 문서는 LangGraph 오케스트레이션 시스템의 **현 위치에서 [01 Master Blueprint](./01_Master_Blueprint.md) 완성 상태까지 가는 경로 지도**이다. 단순한 구현 목록이 아닌, 철학적 청사진을 현실화하기 위한 의미적 진화 단계를 정의한다.

---

## **I. Current Baseline (현 위치)**

시스템의 기초 인프라와 거버넌스가 확립되었으며, 1차 사용자 접점이 안정화된 상태이다.

### **I-1. Evolution History (Phase 0~6 Summary)**

#### Phase 0 – 철학 고정
- Doc-Bundle 철학 및 Agent Separation(조사-구현 분리) 원칙을 수립함.
- 시스템의 불변적 가치와 향후 확장 경로를 정의하여 아키텍처의 정체성을 확보함.
- 상태: ✅ 완료

#### Phase 1 – Core Runtime Skeleton
- 도메인 중립적(Domain-neutral) LangGraph 실행 엔진 및 Step Contract를 구현함.
- 세션 상태 구조를 정의하고 기본적인 워크플로우 제어 로직을 구축함.
- 상태: ✅ 완료

#### Phase 2 – DocBundle Injection
- `mode_docs.yaml` 기반의 문서 주입 및 Section Slice 구조를 도입함.
- LLM이 방대한 문서를 구조적으로 인식하고 필요한 맥락을 정확히 참조하도록 함.
- 상태: ✅ 완료

#### Phase 3 – Decision/Evidence Engine
- Versioned Decision Record 및 3층 메모리(Short/Long/Semantic) 모델을 확립함.
- 근거 기반 추론(Evidence Engine) 및 Hierarchical Retrieval을 통한 정합성을 확보함.
- 상태: ✅ 완료

#### Phase 4 – (Reserved/Deferred 상태 명확화)
- 복합 에이전트 라우팅 및 인지 레이어 통합을 위해 예약되었으나, Phase 7과의 연계성을 위해 전략적으로 비워둠.
- Phase 7에서 Letta Anchor 연동을 통해 더 고도화된 형태로 구현될 예정임.
- 상태: ☐ 계획 (Deferred to Phase 7)

#### Phase 5.5 – Runtime Governance
- Bundle Promotion 파이프라인 및 Deterministic Hash 기반의 무결성 검증을 도입함.
- 세션 고정(Pinning) 및 Core 수준의 Fail-fast 정책을 통해 시스템 신뢰도를 극대화함.
- 상태: ✅ 완료

#### Phase 6 / 6A – UX Stabilization
- Session Lifecycle 관리 및 Provider/Model Override UX를 React UI로 구현함.
- 실시간 스트리밍 렌더링 및 UI Observer를 통해 사용자 경험을 안정화함.
- 상태: ✅ 완료

#### Phase 6.5 – Core Extensibility & Execution Hook Refactor ✅ 완료

- **PRD-021: Core Extensibility Patch**

**구현:**
- ExecutionPlan에 `validators[]`, `postValidators[]` 확장 포인트 도입.
- Guardian을 Step Type 추가 없이 Execution Hook 계층으로 삽입 가능하도록 구조 개방.
- Retrieval Strategy를 `DecisionContextProviderPort` 기반 Strategy Injection 구조로 분리.
- Memory Provider 선택을 정책/번들 기반으로 확장 가능하도록 DI(Dependency Injection) 구조 정비.

### 완료 내용 요약
- Execution Hook (`validators[]`, `postValidators[]`) 구조 도입
- Validator Signature 기반 Deterministic Plan Hash 통합 (PRD-012A 정합 유지)
- Strategy Port (`DecisionContextProviderPort`) 도입
- BundlePinV1에 `strategy_provider_id`, `memory_provider_id` 고정
- Memory Loading Order(Core Merge Logic) 불변 유지 (PRD-005 보호)
- Step Contract LOCK(PRD-007) 침해 없음
- 기존 PRD-001~018 전면 회귀 테스트 통과

**의미:**
- Core가 "고정 토폴로지 엔진"에서 "확장 가능한 오케스트레이션 플랫폼"으로 진화 완료.
- 이후 Phase 7/8은 해당 확장 포인트를 실제로 사용하는 단계임.

---

## **II. Blueprint Gap Analysis (청사진 대비 부족 요소)**

[01 Master Blueprint](./01_Master_Blueprint.md)에서 정의한 최종 상태와 현재 구현 사이의 주요 간극(Gap)을 정리한다.

*   **Core Execution Hook 확장성 (PRD-021)**: ✅ 해결 완료.
    - Execution Hook 구조 도입 및 Strategy Port 분리 완료.
    - Guardian 및 Retrieval 확장 준비 상태 확보.
    - 실제 기능 구현은 Phase 7/8에서 진행.
*   **Anchor 자동화 (Semantic Memory Automation)**: 현재 Anchor는 수동 트리거 중심이며, 대화 중 자동으로 이정표를 감지하고 상기시키는 Letta 레이어의 통합이 미비함. (01 섹션 III-3 참조)
*   **Agent Separation (조사-구현 분리)**: 아키텍처적으로 분리는 되어 있으나, 런타임에서 "근거 수집 전 구현 금지"와 같은 물리적 역할 강제가 아직 정책적으로만 존재함. (01 섹션 III-1 참조)
*   **Multimodal 확장 (Schema Flexibility)**: 현재 엔진은 텍스트 중심이며, 이미지/오디오 등 다양한 입력과 출력 아티팩트를 처리할 수 있는 추상화 레이어가 필요함.
*   **Domain Pack 확장 (Metafactory Expansion)**: 코딩/저술 외 다양한 도메인 번들을 즉시 교체하여 배포할 수 있는 배포 거버넌스와 도메인 팩 라이브러리 부재.
*   **Platformization (SaaS Scale-up)**: 멀티 테넌트 번들 격리, Stable/Canary 채널 분리 배포, A/B 테스트 라우팅 등 플랫폼 수준의 운영 기능 미완성. (01 섹션 V-2 참조)

---

## **III. Path to Blueprint Completion (확장 단계)**

### **1. Phase 7 — Governance Enforcement & Guardian Automation (통제권 확보) 🔵 계획**

#### PRD-022: Guardian 실제 구현 검수 로봇 가동 (통제권 확보)
- **목표**: 
  - PRD-021로 열린 Execution Hook을 실제로 사용하여, “정책 위반/충돌/위험”을 자동 검수하고 `InterventionRequired`를 일으키는 Guardian 실행기를 도입한다.
  - Core가 아닌 Domain Pack/Policy Layer에서 “검수 권한”을 행사하게 하여 시스템 통제권을 확보한다.
- **핵심 산출물**: 
  - Guardian Validator 구현체 (Execution Hook에 꽂히는 signature-based validator)
  - 검수 리포트 포맷 (근거/라인/권고/차단여부) + Evidence 저장소 연동
  - Intervention UX 트리거 (단, StepResult 불변 유지)
- **LOCK (불변 조건)**: 
  - StepResult mutation 금지 (PRD-007)
  - Guardian BLOCK은 자동 실행 차단 아님 (InterventionRequired로만 전환)
  - Plan Hash/Bundle Pin 무결성 유지 (PRD-012A/PRD-018)
- **Acceptance Criteria**: 
  - 동일 입력에서 Guardian 결과가 결정론적으로 재현 가능 (validator signature/logic_hash 포함)
  - BLOCK 발생 시 InterventionRequired로 전환되고 Resume 경로 정상 작동 확인
  - 기존 PRD-001~018 실행 경로에 대한 회귀 테스트 통과

### **2. Phase 8 — Retrieval Intelligence Upgrade (지능 강화) 🔵 계획**

#### PRD-023: Retrieval Strategy 검색 품질 고도화 (지능 강화)
- **목표**: 
  - PRD-021의 Strategy Port를 실제 활용하여, Decision/Evidence 검색의 품질을 단계적으로 강화한다.
  - 단, PRD-005의 계층 순서(Policy→Structural→Semantic)와 Core Merge Logic을 절대 훼손하지 않는다.
- **핵심 산출물**: 
  - Semantic/Hybrid Strategy 구현 (Storage Access 교체 및 최적화)
  - 품질 평가 루브릭/벤치마크 (Precision/Recall/Latency) 및 회귀 테스트 셋
  - 전략 선택이 Bundle/Pin에 고정되는 운영 경로 확립 (PRD-018 일관성 유지)
- **LOCK (불변 조건)**: 
  - Memory Loading Order 유지 (PRD-005: Policy → Structural → Semantic)
  - Merge Logic은 Core 유지 (전략은 Storage Access만 담당)
  - Strategy/Provider 선택은 Bundle/Pin에 고정 (PRD-018 무결성)
- **Acceptance Criteria**: 
  - Default(기존 SQL) 대비 검색 품질 지표(RAG Precision 등) 개선 근거 제시
  - 전략 교체 시 Core 수정 불필요 확인 (Port 기반 Injection 검증)
  - Pin/Hash 재현성 유지 및 모든 기존 테스트 케이스 통과

### **3. Phase 9 – 인지 지능 고도화 (Letta Anchor 연동) 🔵 계획**
*   **목표**: 대화 압축 중 Anchor 자동 감지 및 Retrieval 시 원문 확인 강제 워크플로우 구현.
*   **의미**: "기억하는 수석 아키텍트"로서의 인지 뼈대 완성. (상세는 [03 MEMORY MODEL](./03_MEMORY_MODEL.md) 참조)

### **4. Phase 10 – 에이전틱 거버넌스 확립 (Agent Separation) 🔵 계획**
*   **목표**: Research(Gemini)와 Implementation(Codex)의 물리적 역할 분리 및 근거 기반 승인 루프 강제.
*   **의미**: 추측에 의한 구현을 차단하고 설계 정합성을 수호하는 시스템 신뢰도 확보.

### **5. Phase 11 – 멀티모달 및 범용 인터페이스 🔵 계획**
*   **목표**: `InputEvent` 및 `Output Artifact` 추상화, 멀티모달 지원 메시지 스키마 도입.
*   **의미**: 도메인 중립성을 넘어 인터페이스 중립성을 확보하여 범용 오케스트레이터로 진화.

### **6. Phase 12 – Infrastructure Forward-Slot Preparation 🔵 계획**

이 단계는 기능 구현 단계가 아니다.
확장 불가능성을 제거하기 위한 구조 정비 단계이다.

---

## ✅ Phase 12-A — Structural Safety Seal (Completed)

**상태:** ✅ Completed (2026-02-25)

**핵심 결과:**
- Seal-A/B/C/D 구조적 경계 봉인 확정
- Guardian Sync/Async Split 구현 완료
- Policy BLOCK → Non-blocking + Core-driven intervention
- HookClass 기반 분기 체계 도입
- 실행 흐름 제어 권한은 Safety Hook에만 허용

**구조적 의미:**
Runtime Core는 이제 Governance Signal과 Execution Flow를 명확히 분리하며, 정책 위반은 실행 중단이 아닌 개입 신호로 처리된다. 이는 Non-blocking 원칙을 코드 레벨에서 완전히 고정한 상태이다.

### 1. ExecutionReceipt Canonical Schema 확정 ✅
- Core Fields 고정
- Extension Block 구조 유지
- Flow Control 권한 없음 명시

### 2. Bundle Pinning + Version Chain 안정화 ✅
- Bundle Version 고정 원칙 유지
- Decision Version overwrite 금지 원칙 유지
- Semantic Versioning 운영 선언

### 3. Guardian Layer Isolation 완전 명문화 ✅
- Retrieval 개입 금지
- GraphState mutation 금지
- Sync/Async 분리 유지

### 4. Structural Graph Boundary 확정 ✅
- Impact Analysis 범위 제한
- Cycle Safety 원칙 유지

#### PRD-024: Structural Safety Seal (Contract Hardening Only) ✅

본 PRD는 기능 구현을 추가하지 않는다. Core 구조를 봉인(Seal)하기 위한 계약 문서이다.

**구현 내용:**
- Seal-C Sync/Async Split 구현 완료
- HookClass 기반 분기 도입 (SAFETY / POLICY)
- POLICY BLOCK은 Non-blocking + Core-driven intervention 방식으로 확정
- execution_plan_hash에 HookClass 포함 → 결정론 유지
- state_delta 승격 완료

목표:
Core를 절대 수정하지 않고도 Phase 3 인프라 확장이 “가능한 상태”를 확보 완료.

---

## 🟡 Phase 12-B — Deferred (Post Product-Market Fit)

다음 항목은 제품 안정화 및 생태계 형성 이후 진행한다.

- Provenance / Policy Snapshot / Computed Risk 슬롯 예약 유지
- Export Hook 인터페이스 계약 명시 (비동기 처리 전제)
- Physical AI 확장 필드 예약 (device_id, sensor refs 등)
- Semantic Versioning 운영 원칙 선언 (Bundle/Decision 계층)

---

## **Appendix**

### **A. PRD 상태 매핑 (Full History)**

| 번호 | 제목 | 상태 | 해당 Phase |
|:---|:---|:---|:---|
| PRD-001 | Core Orchestration Engine Base | COMPLETED | Phase 1 |
| PRD-002 | Domain Router & Mode Config | COMPLETED | Phase 1 |
| PRD-003 | Basic Session State Structure | COMPLETED | Phase 1 |
| PRD-004 | Session Persistence | COMPLETED | Phase 1 |
| PRD-005 | Decision Evidence Engine | COMPLETED | Phase 3 |
| PRD-006 | Storage Layer SQLite v1 | COMPLETED | Phase 1 |
| PRD-007 | Step Contract Lock | COMPLETED | Phase 1 |
| PRD-008 | PolicyInterpreter Contract | COMPLETED | Phase 1 |
| PRD-009 | LLM Provider Routing | COMPLETED | Phase 6 |
| PRD-010 | Session Lifecycle UX | COMPLETED | Phase 6 |
| PRD-011 | Secret Injection UX | COMPLETED | Phase 6 |
| PRD-012 | Provider Model Override UX | COMPLETED | Phase 6 |
| PRD-012A | Deterministic Plan Hash | COMPLETED | Phase 5.5 |
| PRD-013 | Minimal Web UI Observer | COMPLETED | Phase 6 |
| PRD-014 | Web UI Framework Introduction | COMPLETED | Phase 6 |
| PRD-015 | Chat Timeline Rendering v2 | COMPLETED | Phase 6 |
| PRD-016 | Session Management Panel | COMPLETED | Phase 6 |
| PRD-017 | Provider/Model/Domain UI Control | COMPLETED | Phase 6A |
| PRD-018 | Bundle Promotion Pipeline | COMPLETED | Phase 5.5 |
| PRD-019 | Dev Mode Overlay | PLANNED | Phase 6A |
| PRD-020 | Extensible Message Schema | PLANNED | Phase 11 |
| PRD-021 | Core Extensibility Patch (Execution Hook & Strategy Port) | COMPLETED | Phase 6.5 |
| PRD-022 | Guardian Enforcement Robot | PLANNED | Phase 7 |
| PRD-023 | Retrieval Intelligence Upgrade | PLANNED | Phase 8 |
| PRD-024 | Phase 12-A Structural Safety Seal | COMPLETED | Phase 12-A |

### **B. Definition of Done (DoD)**
모든 단계는 [01 Master Blueprint](./01_Master_Blueprint.md)의 철학을 준수해야 하며, Core 수정 없이 번들/정책 수준에서 확장이 가능해야 함.

---
*Last Updated: 2026-02-25 (PRD-024 Structural Safety Seal Added)*
