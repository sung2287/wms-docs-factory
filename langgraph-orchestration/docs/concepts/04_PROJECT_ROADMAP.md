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

#### Phase 6.5 – Core Extensibility & Execution Hook Refactor 🔵 계획

- **PRD-021: Core Extensibility Patch**

**목표:**
- ExecutionPlan에 `validators[]` 또는 `preflightHooks[]` 확장 포인트 도입.
- Guardian을 Step Type 추가 없이 Execution Hook 계층으로 삽입 가능하도록 구조 개방.
- Retrieval Strategy를 `DecisionContextProviderPort` 기반 Strategy Injection 구조로 분리.
- Memory Provider 선택을 정책/번들 기반으로 확장 가능하도록 DI(Dependency Injection) 구조 정비.

**의미:**
- Execution Layer(Guardian Hook)와 Data Layer(Retrieval Strategy)를 명확히 분리한다.
- Core 수정 없이 도메인 팩 수준에서 Memory Strategy 및 정합성 검증 로직을 확장 가능하게 만든다.
- 시스템을 “고정 토폴로지 엔진”에서 “확장 가능한 오케스트레이션 플랫폼”으로 진화시킨다.

- 상태: ☐ 계획

---

## **II. Blueprint Gap Analysis (청사진 대비 부족 요소)**

[01 Master Blueprint](./01_Master_Blueprint.md)에서 정의한 최종 상태와 현재 구현 사이의 주요 간극(Gap)을 정리한다.

*   **Core Execution Hook 확장성 (PRD-021)**: Guardian 및 Validator를 ExecutionPlan 수준에서 삽입할 수 있는 구조 확장 필요. 현재 토폴로지는 단일 실행 노드 기반이며, Hook 기반 확장으로 전환해야 한다.
*   **Anchor 자동화 (Semantic Memory Automation)**: 현재 Anchor는 수동 트리거 중심이며, 대화 중 자동으로 이정표를 감지하고 상기시키는 Letta 레이어의 통합이 미비함. (01 섹션 III-3 참조)
*   **Agent Separation (조사-구현 분리)**: 아키텍처적으로 분리는 되어 있으나, 런타임에서 "근거 수집 전 구현 금지"와 같은 물리적 역할 강제가 아직 정책적으로만 존재함. (01 섹션 III-1 참조)
*   **Multimodal 확장 (Schema Flexibility)**: 현재 엔진은 텍스트 중심이며, 이미지/오디오 등 다양한 입력과 출력 아티팩트를 처리할 수 있는 추상화 레이어가 필요함.
*   **Domain Pack 확장 (Metafactory Expansion)**: 코딩/저술 외 다양한 도메인 번들을 즉시 교체하여 배포할 수 있는 배포 거버넌스와 도메인 팩 라이브러리 부재.
*   **Platformization (SaaS Scale-up)**: 멀티 테넌트 번들 격리, Stable/Canary 채널 분리 배포, A/B 테스트 라우팅 등 플랫폼 수준의 운영 기능 미완성. (01 섹션 V-2 참조)

---

## **III. Path to Blueprint Completion (확장 단계)**

### **1. Phase 7 – 인지 지능 고도화 (Letta Anchor 연동) 🔵 계획**
*   **목표**: 대화 압축 중 Anchor 자동 감지 및 Retrieval 시 원문 확인 강제 워크플로우 구현.
*   **의미**: "기억하는 수석 아키텍트"로서의 인지 뼈대 완성. (상세는 [03 MEMORY MODEL](./03_MEMORY_MODEL.md) 참조)

### **2. Phase 8 – 에이전틱 거버넌스 확립 (Agent Separation) 🔵 계획**
*   **목표**: Research(Gemini)와 Implementation(Codex)의 물리적 역할 분리 및 근거 기반 승인 루프 강제.
*   **의미**: 추측에 의한 구현을 차단하고 설계 정합성을 수호하는 시스템 신뢰도 확보.

### **3. Phase 9 – 멀티모달 및 범용 인터페이스 🔵 계획**
*   **목표**: `InputEvent` 및 `Output Artifact` 추상화, 멀티모달 지원 메시지 스키마 도입.
*   **의미**: 도메인 중립성을 넘어 인터페이스 중립성을 확보하여 범용 오케스트레이터로 진화.

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
| PRD-020 | Extensible Message Schema | PLANNED | Phase 9 |
| PRD-021 | Core Extensibility Patch (Execution Hook & Strategy Port) | PLANNED | Phase 6.5 |

### **B. Definition of Done (DoD)**
모든 단계는 [01 Master Blueprint](./01_Master_Blueprint.md)의 철학을 준수해야 하며, Core 수정 없이 번들/정책 수준에서 확장이 가능해야 함.

---
*Last Updated: 2026-02-24 (Evolutionary Path Roadmap)*
