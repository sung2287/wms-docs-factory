# **🚀 PROJECT ROADMAP (04)**

본 문서는 Phase 0에서 시작하여 Phase 12까지의 의미적 진화 경로를 서술하며, 각 단계에서 무엇을 구축했고 무엇이 남았는지를 명확히 기록한다. 또한, 본 문서는 LangGraph 오케스트레이션 시스템의 **현 위치에서 [01 Master Blueprint](./01_Master_Blueprint.md) 완성 상태까지 가는 경로 지도**이다. 단순한 구현 목록이 아닌, 철학적 청사진을 현실화하기 위한 의미적 진화 단계를 정의한다.

> **📌 2026-02-26 전략 컨텍스트 추가**
> 본 시스템의 출발점은 **AI 코딩 병목 해결**이다. 비전공자가 코드를 직접 읽지 않고 AI와 협업할 때, 매 PRD마다 레포 전체 스캔 → 충돌 포인트 파악 → 컨텍스트 재설명의 반복이 핵심 병목이다. 이 시스템은 그 병목을 Decision SSOT + Atlas 구조로 제거하기 위해 설계되었다. 시스템이 완성되면 코딩 번들로 자기 자신을 검증하고, 이후 번들 마켓 → B2B → 소비자 순서로 확장한다.

---

## **I. Current Baseline (현 위치)**

시스템의 기초 인프라와 거버넌스가 확립되었으며, 1차 사용자 접점이 안정화된 상태이다.

### **I-1. Evolution History (Phase 0~6 Summary)**

#### Phase 0 – 철학 고정 ✅ 완료
- Doc-Bundle 철학 및 Agent Separation(조사-구현 분리) 원칙을 수립함.
- 시스템의 불변적 가치와 향후 확장 경로를 정의하여 아키텍처의 정체성을 확보함.

#### Phase 1 – Core Runtime Skeleton ✅ 완료
- 도메인 중립적(Domain-neutral) LangGraph 실행 엔진 및 Step Contract를 구현함.
- 세션 상태 구조를 정의하고 기본적인 워크플로우 제어 로직을 구축함.

#### Phase 2 – DocBundle Injection ✅ 완료
- `mode_docs.yaml` 기반의 문서 주입 및 Section Slice 구조를 도입함.
- LLM이 방대한 문서를 구조적으로 인식하고 필요한 맥락을 정확히 참조하도록 함.

#### Phase 3 – Decision/Evidence Engine ✅ 완료
- Versioned Decision Record 및 3층 메모리(Short/Long/Semantic) 모델을 확립함.
- 근거 기반 추론(Evidence Engine) 및 Hierarchical Retrieval을 통한 정합성을 확보함.

#### Phase 4 – (Reserved/Deferred) ☐ 계획 (Deferred to Phase 7)
- 복합 에이전트 라우팅 및 인지 레이어 통합을 위해 예약.
- Phase 7에서 Letta Anchor 연동을 통해 고도화된 형태로 구현 예정.

#### Phase 5.5 – Runtime Governance ✅ 완료
- Bundle Promotion 파이프라인 및 Deterministic Hash 기반의 무결성 검증을 도입함.
- 세션 고정(Pinning) 및 Core 수준의 Fail-fast 정책을 통해 시스템 신뢰도를 극대화함.

#### Phase 6 / 6A – UX Stabilization ✅ 완료
- Session Lifecycle 관리 및 Provider/Model Override UX를 React UI로 구현함.
- 실시간 스트리밍 렌더링 및 UI Observer를 통해 사용자 경험을 안정화함.

#### Phase 6.5 – Core Extensibility & Execution Hook Refactor ✅ 완료

**PRD-021: Core Extensibility Patch**

**구현:**
- ExecutionPlan에 `validators[]`, `postValidators[]` 확장 포인트 도입.
- Guardian을 Step Type 추가 없이 Execution Hook 계층으로 삽입 가능하도록 구조 개방.
- Retrieval Strategy를 `DecisionContextProviderPort` 기반 Strategy Injection 구조로 분리.
- Memory Provider 선택을 정책/번들 기반으로 확장 가능하도록 DI 구조 정비.

**의미:**
- Core가 "고정 토폴로지 엔진"에서 "확장 가능한 오케스트레이션 플랫폼"으로 진화 완료.
- 이후 Phase 7/8은 해당 확장 포인트를 실제로 사용하는 단계임.

---

## **II. Blueprint Gap Analysis (청사진 대비 부족 요소)**

- **Core Execution Hook 확장성 (PRD-021)**: ✅ 해결 완료.
- **Atlas Index Engine**: ✅ 설계 완료. PRD-026으로 등록. Phase 7 선행 조건으로 배치.
- **Decision Capture Layer**: ✅ 설계 완료 (2026-02-26). PRD-025로 등록. WorkItem/completion_policy 평가 포함.
- **Anchor 자동화 (Semantic Memory Automation)**: Letta 레이어 통합 미비. Phase 9에서 구현 예정.
- **Agent Separation (조사-구현 분리)**: 정책적으로만 존재. Phase 10에서 물리적 강제 구현 예정.
- **Multimodal 확장 (Schema Flexibility)**: 텍스트 중심 현재 엔진. Phase 11에서 추상화 레이어 도입 예정.
- **Domain Pack 확장 (Metafactory Expansion)**: 도메인 팩 라이브러리 부재. PRD-028 슬롯 예약, 코딩 번들 검증 후 확장 예정.
- **Platformization (SaaS Scale-up)**: 멀티 테넌트, Stable/Canary 채널 등 플랫폼 기능 미완성.

---

## **III. Path to Blueprint Completion (확장 단계)**

### **1. Phase 7 — Atlas Index Engine + Guardian Automation 🔵 계획**

#### PRD-026: Atlas Index Engine (Index Build/Update + Partial Scan Budget Enforcer) *(2026-02-26 신규 추가)*

> **배경**: PRD-022(Guardian), PRD-023(Retrieval), PRD-025(Capture Layer) 세 개가 모두 Atlas를 읽고 쓰는 구조인데, Atlas 자체를 생성·갱신·조회하는 엔진이 PRD로 존재하지 않았다. 이 PRD가 없으면 세 개의 상위 PRD가 "무엇을 어디서 읽을지"를 체계적으로 공유하지 못한다. Phase 7의 선행 조건이다.

- **목표**:
  - Atlas Index(Structure / Contract / ConflictPoints / DecisionIndex) 생성·갱신·조회 엔진 구현
  - 부분 스캔 예산(scan_budget) / 화이트리스트 / 포인터 규칙을 Domain Pack 기반으로 집행하는 Enforcer 구현
  - PRD-022/023/025의 공통 기반 레이어 확보

- **핵심 산출물**:
  - Atlas SSOT 스키마 (Structure / Contract / Decision / ConflictPoints Index)
  - Index Build 초기화 파이프라인 (레포 최초 온보딩 시 Atlas 생성)
  - Index Update 루프 (Cycle 종료 시 fingerprint 기반 갱신)
  - Partial Scan Budget Enforcer (Domain Pack의 max_files / max_bytes / max_hops 집행)
  - Atlas 조회 API (PRD-022/023/025가 공통 사용)

- **LOCK**:
  - Atlas는 SSOT 인덱스이며 원문 데이터를 저장하지 않는다 (pointer + fingerprint만)
  - Index 갱신은 Cycle 종료 시점에만 수행 (실행 흐름 중 Atlas 직접 수정 금지)
  - Scan Budget 집행 권한은 Enforcer(코드)에만 있음 (LLM이 예산을 직접 변경 불가)

- **Acceptance Criteria**:
  - 레포 최초 온보딩 시 Atlas 4개 인덱스 정상 생성 확인
  - fingerprint 변경된 Artifact만 REVALIDATION_REQUIRED로 표시 확인
  - Domain Pack scan_budget 초과 요청 시 Enforcer가 차단 확인
  - PRD-022/023/025가 Atlas 조회 API를 통해 정상 동작 확인

---

#### PRD-022: Guardian 실제 구현 검수 로봇 가동
- **목표**: Execution Hook을 실제로 사용하여 정책 위반/충돌/위험을 자동 검수하고 `InterventionRequired`를 발생시키는 Guardian 실행기 도입.
- **핵심 산출물**:
  - Guardian Validator 구현체 (signature-based validator)
  - 검수 리포트 포맷 + Evidence 저장소 연동
  - Intervention UX 트리거 (StepResult 불변 유지)
- **LOCK**:
  - StepResult mutation 금지 (PRD-007)
  - Guardian BLOCK은 자동 실행 차단 아님 (InterventionRequired로만 전환)
  - Plan Hash/Bundle Pin 무결성 유지 (PRD-012A/PRD-018)
- **Acceptance Criteria**:
  - 동일 입력에서 Guardian 결과 결정론적 재현 가능
  - BLOCK 발생 시 InterventionRequired 전환 및 Resume 경로 정상 작동
  - 기존 PRD-001~018 회귀 테스트 통과

---

### **2. Phase 7.5 — Decision Capture Layer + WorkItem Manager 🔵 계획** *(2026-02-26 신규 추가)*

#### PRD-025: Decision Capture Layer + WorkItem & Completion Policy Evaluator

> **배경**: 오늘 대화에서 설계 확정. AI 코딩 병목의 핵심 해결책으로, 대화에서 자연스럽게 나온 수정 지시/규칙을 자동 감지하여 오염 없이 DecisionVersion으로 안전하게 반영하는 레이어.

- **목표**:
  - 전문가가 "이거 왜 이렇게 했어?" → AI 근거 설명 → "그건 틀렸어, 이렇게 해" 흐름만으로 자동으로 규칙이 구조화되고 저장되는 구조 구현.
  - 별도 규칙 설정 UI 없이 대화 자체가 번들 생성 인터페이스가 되도록 함.
  - 코딩 번들 온보딩의 핵심 UX 기반.

- **레이어 삽입 위치 (기존 루프 무손상)**:
  ```
  Conversation Turn
    → Decision Capture Layer   ← (신규)
    → Change Context (풍부해짐)
    → Atlas Query
    → ... (기존 루프 그대로)
  ```

- **핵심 산출물**:
  - Candidate → Proposed → Committed 3단계 오염 방지 필터
  - DecisionProposalV1 스키마 (LLM 산출물 표준)
  - conversationTurnRef 포맷 (`conversation:<conversationId>:<turnId>`)
  - 저장 정책 옵션 B (Auto-detect + Ask-to-commit) MVP 구현
  - Enforcer 강제 규칙 (evidenceRefs/changeReason 없으면 저장 거부)
  - **WorkItem 엔티티 및 상태 전이 엔진** (PROPOSED → ANALYZING → DESIGN_CONFIRMED → IMPLEMENTING → IMPLEMENTED → VERIFIED → CLOSED)
  - **completion_policy 평가기** (Domain Pack 기반 완료 판정 — 테스트 Evidence, Conflict 클리어, Contract Lock 위반 없음 등)

- **저장 정책 롤아웃**:
  - MVP: **옵션 B만** (자동 감지 + 저장 제안)
  - 데이터 축적 후: **옵션 B + C** (조건부 자동 저장)

- **LOCK**:
  - 감지는 LLM(Planner), 집행/저장은 코드(Enforcer) — Planner/Enforcer 분리 원칙 유지
  - STRONG/lock/axis 충돌 가능성 있으면 자동 확정 금지
  - Core 수정 없이 Atlas 루프 앞단 삽입으로만 구현
  - DecisionVersion은 반드시 새 version 생성 + active 포인터 이동

- **Atlas/WorkItem 연동**:
  - Proposal → Atlas Query 입력(Change Context) 풍부화
  - WorkItem 존재 시 Proposal 링크 → DESIGN_CONFIRMED → VERIFIED 흐름 통합

- **Acceptance Criteria**:
  - 대화에서 수정 지시 발생 시 Proposal 자동 생성 확인
  - 옵션 B: 저장 제안 → YES 응답 → Committed 전환 정상 작동
  - evidenceRefs 없는 Proposal 저장 거부 확인
  - WorkItem 상태 전이 순서 강제 확인 (임의 점프 불가)
  - completion_policy 조건 충족 시 VERIFIED 자동 판정 확인 (auto_verify_allowed=true 케이스)
  - 기존 Atlas 루프 회귀 테스트 통과

---

### **3. Phase 8 — Retrieval Intelligence Upgrade 🔵 계획**

#### PRD-023: Retrieval Strategy 검색 품질 고도화
- **목표**: PRD-021의 Strategy Port를 실제 활용하여 Decision/Evidence 검색 품질을 단계적으로 강화. PRD-005의 계층 순서(Policy→Structural→Semantic)와 Core Merge Logic 절대 유지.
- **핵심 산출물**:
  - Semantic/Hybrid Strategy 구현
  - 품질 평가 루브릭/벤치마크 (Precision/Recall/Latency)
  - 전략 선택이 Bundle/Pin에 고정되는 운영 경로 확립
- **LOCK**:
  - Memory Loading Order 유지 (PRD-005)
  - Merge Logic은 Core 유지
  - Strategy/Provider 선택은 Bundle/Pin에 고정 (PRD-018)

---

### **4. Phase 9 – 인지 지능 고도화 (Letta Anchor 연동) 🔵 계획**
- **목표**: 대화 압축 중 Anchor 자동 감지 및 Retrieval 시 원문 확인 강제 워크플로우 구현.
- **의미**: "기억하는 수석 아키텍트"로서의 인지 뼈대 완성.

---

### **5. Phase 10 – 에이전틱 거버넌스 확립 (Agent Separation) 🔵 계획**
- **목표**: Research(Gemini)와 Implementation(Codex)의 물리적 역할 분리 및 근거 기반 승인 루프 강제.
- **의미**: 추측에 의한 구현을 차단하고 설계 정합성을 수호하는 시스템 신뢰도 확보.

---

### **6. Phase 11 – 멀티모달 및 범용 인터페이스 🔵 계획**
- **목표**: `InputEvent` 및 `Output Artifact` 추상화, 멀티모달 지원 메시지 스키마 도입.
- **의미**: 도메인 중립성을 넘어 인터페이스 중립성을 확보하여 범용 오케스트레이터로 진화.

---

### **7. Phase 12 – Infrastructure Forward-Slot Preparation 🔵 계획**

이 단계는 기능 구현 단계가 아니다. 확장 불가능성을 제거하기 위한 구조 정비 단계이다.

---

## ✅ Phase 12-A — Structural Safety Seal (Completed)

**상태:** ✅ Completed (2026-02-25)

**핵심 결과:**
- Seal-A/B/C/D 구조적 경계 봉인 확정
- Guardian Sync/Async Split 구현 완료
- Policy BLOCK → Non-blocking + Core-driven intervention
- HookClass 기반 분기 체계 도입
- 실행 흐름 제어 권한은 Safety Hook에만 허용

#### PRD-024: Structural Safety Seal ✅ 완료

---

## 🟡 Phase 12-B — Deferred (Post Product-Market Fit)

다음 항목은 제품 안정화 및 생태계 형성 이후 진행한다.

- Provenance / Policy Snapshot / Computed Risk 슬롯 예약 유지
- Export Hook 인터페이스 계약 명시 (비동기 처리 전제)
- Physical AI 확장 필드 예약 (device_id, sensor refs 등)
- Semantic Versioning 운영 원칙 선언 (Bundle/Decision 계층)
- **PRD-028 슬롯 예약: Domain Pack Library + Pack Validation** (schema, allowlist, budget, versioning) — 코딩 번들 이후 두 번째 도메인 진입 시점에 독립 PRD로 분리

---

## **IV. 번들 전략 로드맵** *(2026-02-26 신규 추가)*

> 시스템 완성 이후 번들 경제로 확장하는 단계별 전략이다. 시스템 구현이 선행되어야 하며, 코딩 번들이 첫 번째 검증 케이스가 된다.

### **Step 1 — 코딩 번들 자기 검증**
- 본인의 코딩 워크플로우를 첫 번째 번들로 온보딩
- AI 코딩 병목(매 PRD마다 레포 전체 스캔 반복) 해소 여부 직접 검증
- "이거 없으면 불편하다"는 느낌이 오면 다음 단계 진행

### **Step 2 — 회사 직원 베타 테스트**
- 다양한 도메인(개발/기획/운영 등)으로 번들 구조화 패턴 수집
- 도메인별 온보딩 플레이북 초안 작성
- 실패 케이스 안전하게 수집 및 시스템 개선

### **Step 3 — 번들 마켓 공개 & 생태계 형성**
- 성공 케이스 기반으로 공개
- 전문가가 자신의 워크플로우를 번들로 올리고 수익화하는 구조 제공
- 사용량 임계점 도달한 번들에 대한 내부 플래그 시스템 운영

### **Step 4 — 번들 저작권 매입 & B2B 패키징**
- 검증된 번들의 로직 사용 권리 매입 (개인 데이터 제외)
- 현금 + 무료 이용권 조합으로 전문가 만족도 확보
- 도메인별 번들 합성 (예: 법률 전문가 N명의 Decision 큐레이션 → 법률 도메인 번들)
- 기업 대상 B2B 패키징 및 판매

### **Step 5 — 소비자 단순화**
- B2B에서 검증된 번들을 "딸깍" 수준으로 단순화
- 일반 소비자용 비서 엔진으로 이식

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
| PRD-019 | Dev Mode Overlay | COMPLETED | Phase 6A |
| PRD-020 | Extensible Message Schema | PLANNED | Phase 11 |
| PRD-021 | Core Extensibility Patch (Execution Hook & Strategy Port) | COMPLETED | Phase 6.5 |
| PRD-022 | Guardian Enforcement Robot | PLANNED | Phase 7 |
| PRD-023 | Retrieval Intelligence Upgrade | PLANNED | Phase 8 |
| PRD-024 | Phase 12-A Structural Safety Seal | COMPLETED | Phase 12-A |
| PRD-025 | Decision Capture Layer + WorkItem & Completion Policy Evaluator | PLANNED | Phase 7.5 |
| PRD-026 | Atlas Index Engine (Index Build/Update + Partial Scan Budget Enforcer) | PLANNED | Phase 7 (선행) |
| PRD-027 | (슬롯 예약) WorkItem 독립 분리 — PRD-025 범위 초과 시 | DEFERRED | Phase 7.5+ |
| PRD-028 | (슬롯 예약) Domain Pack Library + Pack Validation | DEFERRED | Phase 12-B |

### **B. Definition of Done (DoD)**
모든 단계는 [01 Master Blueprint](./01_Master_Blueprint.md)의 철학을 준수해야 하며, Core 수정 없이 번들/정책 수준에서 확장이 가능해야 함.

---
*Last Updated: 2026-02-26 (PRD-025~028 추가 / Atlas Index Engine PRD-026 Phase 7 선행 배치 / WorkItem 범위 PRD-025 통합 명시 / PRD-028 Deferred 슬롯 예약 / 번들 전략 로드맵 IV 섹션 추가 / 전략 컨텍스트 추가)*
