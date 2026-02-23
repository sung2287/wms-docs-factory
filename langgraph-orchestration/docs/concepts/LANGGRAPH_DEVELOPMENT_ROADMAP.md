# LangGraph 개발 로드맵 (Development Roadmap)

# 1. 문서 목적

- 이 로드맵은 단순한 구현 순서를 나열하는 것이 아니라, 고정된 철학 문서를 실제 코드로 옮기는 **의미적 단계**를 정의한다.
- 각 Phase는 "어떤 핵심 가치와 기능을 구현하는가"에 초점을 맞춘다.
- 시스템의 확장성과 철학적 정합성을 유지하기 위한 이정표 역할을 한다.

**본 로드맵은 Summary 기반 장기 기억 시스템을 채택하지 않는다. LangGraph의 장기 의미 저장은 Decision / Evidence 중심 구조를 따른다.**

"LangGraph는 단순 Runtime이 아니라, Policy-Driven Runtime Platform으로 진화하며, Builder에서 생성된 Workflow Bundle을 승격(Promote)하는 구조를 갖는다."

---

# 2. 참조 고정 문서 (Mandatory References)

구현 과정에서 다음 문서를 반드시 참조하여 설계 의도를 유지한다:

- [AI Orchestration Runtime – MVP 설계 문서 v2](./ai_orchestration_runtime_design_v_2.md)
- [Idea Preservation Framework v1](./idea_preservation_framework_v_0_집필중심.md)
- [LangGraph × Letta Anchor Memory Idea](./lang_graph_letta_anchor_memory_idea.md)
- [LangGraph Orchestration Architecture](./langgraph_orchestration_architecture.md)
- [PRD_INDEX](./PRD_INDEX.md)

---

## 🔷 Architectural Elevation – Builder / Runtime Separation (NEW)

본 프로젝트는 단일 런타임 구현을 넘어,
**Builder(Control Plane) ↔ Runtime(Data Plane)** 분리 아키텍처로 확장된다.

- Builder: R&D 설계 앱 (Workflow Bundle 생성)
- Runtime: 배포된 Bundle을 실행하는 엔진
- Promotion Pipeline: Builder에서 검증된 Bundle을 Runtime으로 승격

LOCK 원칙:

- 승격 대상은 Workflow Bundle(컨텍스트 스펙)뿐이다.
- 유저 데이터(Decision/Evidence/Session)는 절대 승격 대상이 아니다.
- Judge Policy의 판단 기준은 Bundle에 포함되지만,
  실패 처리(Fallback Contract)는 Runtime Core가 강제한다.

---

# 3. Phase 구분 (의미 중심)

## Phase 0 – 철학 고정 (Philosophy Foundation)

의미:
- Runtime 차단 금지 원칙 확립
- Decision Versioned 구조 설계
- Memory 타입 3종(Decision/Evidence/Anchor) 고정
- Git/DB(의미/결과) 저장소 분리 원칙 확정
- Mode 자동 판단 + 수동 UI 제어 전략 수립

상태:
- ✅ **완료**

참조:
- [ai_orchestration_runtime_design_v_2.md](./ai_orchestration_runtime_design_v_2.md)
- [idea_preservation_framework_v_1.md](./idea_preservation_framework_v_1.md)

---

## Phase 1 – Core Runtime Skeleton

의미:
- 도메인 중립(Domain-Neutral) 실행 엔진 구축
- 키워드 기반 Mode Router 구현
- Ephemeral Session State 구조 및 복구 로직 구현
- Core Engine과 Domain Pack의 물리적/논리적 분리

상태:
- ✅ **완료** (PRD-001, 004, 007 기반)

체크리스트:
- [x] Domain-neutral GraphState 정의
- [x] Session state 캐시 저장소 (`session_state.json`)
- [x] Step Contract Lock 구현
- [x] 기본 Mode 전환 로직

---

## Phase 2 – Bundle-first 문서 주입 (Context Injection)

의미:
- `mode_docs.yaml` 기반의 DocBundle Loader 구현
- 모드 진입 시 필수 규칙 문서 누락 방지
- 문서 전체가 아닌 섹션 슬라이스(Section Slice) 주입 구조 확보

상태:
- ✅ **완료** (PRD-002, 003 기반)

체크리스트:
- [x] `mode_docs.yaml` 해석기
- [x] DocBundle Loader 프레임워크
- [x] 레포지토리 컨텍스트 플러그인 연동

---

## Phase 3 – Decision / Evidence Engine

의미:
- `SAVE_DECISION` 트리거 기반 즉시 영구 저장 구조 구현
- Decision 수정 시 versioned(isActive) 처리 구조 구현
- Scope(Global + Domain) 및 Strength(Axis > Lock > Normal) 우선순위 Retrieval 구현
- Evidence 저장 구조 구현 (원문 스냅샷 기반)

Decision은 SAVE_DECISION 확정 즉시 DB에 영구 저장되며, 저장된 Decision은 다음 턴부터 Retrieval 대상에 포함된다. 세션 종료 시점까지 대기하는 구조는 허용하지 않는다.

**명시적 원칙:**
- Runtime Summary 기반 Memory 시스템은 채택하지 않는다.
- 장기 기억은 Decision / Evidence / Anchor 3종 구조를 따른다.

상태:
- ✅ **완료**

체크리스트:
- [x] Decision DB 스키마 설계 (Versioned 포함)
- [x] Scope + Strength 필드 반영
- [x] Axis 우선 Retrieval 로직 구현
- [x] Evidence 저장 구조 구현
- [x] Anchor → Evidence 연결 로직 구현
- [x] 즉시 저장 후 다음 턴 Retrieval 반영 검증

### Phase 3 Architectural Summary

**PRD-005: Decision / Evidence Engine**
- Domain-explicit Decision/Evidence SSOT activated
- Hierarchical retrieval (global → domain strengths)
- Scope allowlist enforcement (application-level)
- Summary contamination guard (legacy memory disabled)
- Runtime wiring completed (SQLite + PlanExecutor deps)
- Integration tests passing

**PRD-006: Storage Layer (SQLite v1)**
- Passive storage boundary enforced
- Versioned Decision chain schema (rootId, atomic update)
- Evidence + Link tables (many-to-many)
- WAL + immediate commit policy
- No business validation inside storage layer

---

## Phase 6 – UI 계층 & UX (User Control)

의미:
- 현재 활성 Mode 상시 표시 UI
- 사용자의 수동 Mode 전환 인터페이스 구현
- Decision 저장 확인 모달 및 Evidence 저장 트리거 UI
- **Session Lifecycle UX (PRD-010)**

상태:
- ✅ **완료 (PRD-010)**

### PRD-010: Session Lifecycle UX
- Added: --fresh-session (explicit reset w/ rotation)
- Added: --session <name> (namespaced session_state.<name>.json)
- Strict: hash mismatch default abort preserved
- Rotation: ops/runtime/_bak/ + keep last 10 (FIFO), fail-fast on rotation errors
- Scope: runtime/cli + src/session store boundary only (no core changes)

- **Developer Ergonomics**: PRD-010 resolves session hash mismatch friction via explicit reset and namespacing.

---

## Phase 6.5 – Bundle Promotion Pipeline (NEW)

의미:
Builder에서 생성된 Workflow Bundle을
코드 수정 없이 Runtime에 배포(Promote)하기 위한
메타 팩토리의 핵심 연결 엔진을 구현한다.

범위:
- Manifest Loader (Runtime Core 내부)
- Active Bundle Switching (Symlink 기반 원자적 교체)
- Profile Switch (rd / prod)
- Core-enforced Fallback Contract

비범위 (Future Phase로 명시):
- Canary 배포
- A/B 테스트
- 원격 업로드
- 무중단 핫스왑

상태:
- ☐ 계획

체크리스트:
- [ ] manifest.json schema 정의
- [ ] schema_version / min_runtime_version 검증
- [ ] bundle_hash 무결성 검증 로직
- [ ] Deterministic bundle_hash calculation rule fixed (sorted file order + content hash)
- [ ] Bundle loading boundary strictly separated from Decision/Evidence storage layer (LOCK-1 physical boundary)
- [ ] Active Bundle symlink 교체 메커니즘
- [ ] Session 시작 시 bundle_version 고정
- [ ] Judge 실패 시 Core Fallback 강제
- [ ] Rollback 지원 (previous_bundle_ref)
- [ ] Session metadata에 bundle_version + bundle_hash 기록 (session pinning)

---

## Phase 7 – Letta Anchor 연동 (Navigation Hint)

의미:
- 대화 중 Anchor(네비게이션 힌트) 감지 및 저장
- Retrieval 시 Anchor를 통한 상기 기능 구현
- Anchor 발견 시 원문(Evidence/Decision) 확인 강제 워크플로우 구현

상태:
- ☐ 계획

체크리스트:
- [ ] Anchor 감지 트리거
- [ ] Anchor → Evidence/Decision 이정표 연결 로직
- [ ] 원문 확인 강제(Verification) 루프 구현

---

## Phase 8 – Agent Separation

의미:
- LangGraph ↔ Gemini CLI (Research / Meaning SSOT) 연동
- LangGraph ↔ Codex CLI (Implementation / Result SSOT) 연동
- 조사와 구현의 물리적 역할 분리 강제

상태:
- ☐ 계획

참조:
- [langgraph_orchestration_architecture.md](./langgraph_orchestration_architecture.md)

---

## Phase 9 – 멀티모달 인터페이스 준비 (Future-Proof)

의미:
- `InputEvent` (Text/Image/Audio) 추상화 구조 확보
- `ModelRequest` 및 `Output Artifact` 추상화
- Core 수정 없이 멀티모달 확장 가능한 구조 검증

상태:
- ☐ 계획

---

# 4. PRD 상태 연동 현황

| PRD | 제목 | 상태 | 해당 Phase | 비고 |
|:---|:---|:---|:---|:---|
| PRD-001 | Core Runtime Skeleton | 완료 | Phase 1 | 정책 중립 엔진 |
| PRD-002 | Policy Injection Layer | 완료 | Phase 2 | 도메인 정책 주입 |
| PRD-003 | Repository Context Plugin | 완료 | Phase 2 | 레포 스캔 및 번들링 |
| PRD-004 | Session Persistence | 완료 | Phase 1 | 세션 상태 복구 |
| PRD-005 | Decision / Evidence Engine | COMPLETED | Phase 3 | Phase 3 기준 설계 및 연동 완료 |
| PRD-006 | Storage Layer (SQLite v1) | COMPLETED | Phase 3 | Decision/Evidence 스키마 반영 완료 |
| PRD-007 | Step Contract Lock | COMPLETED | Phase 1 | v1 Step Contract LOCK 완료, Executor validation, failure semantics 도입 |
| PRD-008 | PolicyInterpreter Contract | COMPLETED | Phase 1/2 | 정책 해석기 완료 |
| PRD-010 | Session Lifecycle UX | COMPLETED | Phase 6 | 세션 리셋 및 네임스페이스 지원 |
| PRD-011 | Secret Injection UX | PLANNED | Phase 6 | Secret 주입 및 검증 자동화 |
| PRD-012 | Provider/Model Override UX | PLANNED | Phase 6 | 실행 시점 모델 오버라이드 |

---

# 5. 완료 정의 기준 (Definition of Done)

각 Phase는 다음 조건을 모두 만족해야 완료로 간주한다:

1. **PRD 충족**: 관련 PRD의 기능적/기술적 요구사항 구현 완료.
2. **테스트 통과**: 단위 테스트 및 시나리오 테스트 통과.
3. **철학 정합성**: [ai_orchestration_runtime_design_v_2.md](./ai_orchestration_runtime_design_v_2.md)의 원칙과 충돌이 없음.
4. **Core 중립성**: Core Engine 내부에 특정 도메인 문자열이나 로직이 하드코딩되지 않음.
5. **검증 완료**: 런타임 빌드 시 오류가 없으며 타입 안정성이 확보됨.

### Phase 6.5 Specific DoD (Bundle Promotion):
- Runtime이 Active Bundle을 읽어 초기화 가능
- 호환되지 않는 Bundle은 활성화되지 않으며, Runtime은 기존 정상 Active Bundle을 유지한다.
- Prod Profile에서 Judge 실패 시 Core Fallback 동작 확인
- 기존 Session은 기존 bundle_version 유지
- Bundle switching applies only at session start; in-flight sessions remain pinned to their starting bundle_version.

---

# 6. 변경 불가 원칙

- **철학 우선**: 철학 문서와 충돌하는 어떠한 구현도 허용되지 않는다. 구현이 철학과 충돌할 경우 구현을 수정하거나 철학 문서를 공식적으로 갱신(Decision Log)해야 한다.
- **구조적 중립성**: Phase의 순서는 효율성에 따라 조정될 수 있으나, Core와 Domain의 분리 구조는 변경될 수 없다.
- **비차단 원칙**: Runtime은 어떤 상황에서도 실행을 차단하지 않으며, 제어는 상위 거버넌스 층에서 수행한다.
- Bundle rejection은 Runtime 실행 차단을 의미하지 않는다. 호환되지 않거나 검증 실패한 Bundle은 단순히 활성화되지 않으며, Runtime은 직전 정상 Active Bundle로 안전하게 복귀한다.

---
**Patch Applied Summary (v1.3 Bundle Governance Finalization)**

- Phase 6.5: LOCK-1 물리적 경계 강제 및 결정론적 bundle_hash 규칙 추가.
- DoD: 세션 bundle_version 고정(Pinning) 원칙 명문화.
- Governance: Bundle Reject는 실행 차단이 아닌 안전한 Active Bundle 유지로 정의.

---
*Last Updated: 2026-02-23 (v1.3 Bundle Governance Finalization)*

NOTE:
policy/profiles/**/*.yaml 내 legacy step 명칭(recall, memory_write 등)은
현재 runtime normalizePolicyStep을 통해 v1 StepDefinition으로 변환됨.
정책 레이어 정리는 별도 Policy PRD에서 처리 예정.
