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

## 2.1 Terminology Separation

- **DocBundle**:
  모드 진입 시 주입되는 문서 단위 (Phase 2)
- **Workflow Bundle**:
  Builder에서 Runtime으로 승격되는 실행 스펙 단위 (Phase 5.5)

두 개념은 물리적/개념적으로 분리된다.

---

## 2.2 Architectural Elevation – Builder / Runtime Separation (NEW)

본 프로젝트는 단일 런타임 구현을 넘어,
**Builder(Control Plane) ↔ Runtime(Data Plane)** 분리 아키텍처로 확장된다.

- Builder: R&D 설계 앱 (Workflow Bundle 생성)
- Runtime: 배포된 Bundle을 실행하는 엔진
- Promotion Pipeline: Builder에서 검증된 Bundle을 Runtime으로 승격

LOCK 원칙:
- [LOCK] 승격 대상은 Workflow Bundle(컨텍스트 스펙)뿐이다.
- [LOCK] 유저 데이터(Decision/Evidence/Session)는 절대 승격 대상이 아니다.
- [LOCK] Judge Policy의 판단 기준은 Bundle에 포함되지만, Fallback Contract는 Runtime Core가 강제한다.

---

# 3. Phase 구분 (의미 중심)

## Phase 0 – 철학 고정 (Philosophy Foundation)

의미:
- Runtime 비차단 원칙 확립 (단, Bundle Integrity는 Governance 예외 조항으로 Fail-fast 허용)
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
- ✅ **완료** (PRD-001, 004, 007, 008, 009 기반)

체크리스트:
- [x] Domain-neutral GraphState 정의
- [x] Session state 캐시 저장소 (`session_state.json`)
- [x] Step Contract v1.1 LOCK 구현 및 활성화
- [x] Version gate + ordering + duplicate guard 강제 적용
- [x] PolicyInterpreter와 Executor 계약 동기화 완료
- [x] `persistAnchor`를 포함한 엄격한 interface 노출
- [x] 기본 Mode 전환 로직

### Session Evolution Clarification (Post PRD-018)
- Session = execution state + pinned bundle metadata + plan hash context
- 이는 Governance 강화에 따른 확장이며, 초기 세션 철학(단순 상태 저장)을 침해하지 않는다.

---

## Phase 2 – DocBundle-first 문서 주입 (Mode Injection Unit)

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
- [x] 계층적 Retrieval 구현 (Global → Domain → Strength)
- [x] `SAVE_DECISION` 호출 시 즉시 영구 저장 (Persistence)
- [x] SQLite v1 Passive Boundary 강제 (비즈니스 로직 분리)
- [x] WAL + 외래 키(FK) + 원자적 버전 업데이트 검증 완료
- [x] Anchor linking 작동 확인 (수동 단계 연동 완료)
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

## Phase 4 – Reserved (Deferred)

의미:
- 현재는 계획 보류(Deferred) 상태이다.
- 관련 기능은 Phase 7(Anchor)의 장기 기억 항해 로직과 연계되어 추후 적정 시점에 재개될 예정이다.

---

## Phase 5.5 – Runtime Governance Layer (Workflow Bundle Control)

의미:
Builder에서 생성된 **Workflow Bundle (Promotion Unit)**을 코드 수정 없이 Runtime에 배포(Promote)하기 위한 메타 팩토리의 핵심 연결 엔진을 구현한다. **PRD-018: Bundle Promotion Pipeline**은 런타임 거버넌스의 SSOT로서 번들의 물리적 격리와 결정론적 무결성을 보장하며, **"결정론적 런타임 거버넌스 확립"**의 핵심 기반이 된다.

**계층 구조 (Hierarchy):**
Core는 정책/번들의 물리적 위치를 알지 못하며, Bundle Governance 계층이 Core 외부(Adapter Layer)에서 무결성을 검증하고 주입한다.
```
Core Runtime (src/core)
  ↑ (Context Injection)
Bundle Governance (Adapter Layer - Phase 5.5)
  ↓
UX / CLI Layer (Phase 6)
```

범위:
- Manifest Loader (Runtime Core 외부 Adapter 구현)
- Active Bundle Switching (Symlink 기반 원자적 교체)
- Profile Switch (rd / prod)
- **Core-enforced Fallback Contract (LOCK-4)**

LOCK 원칙 반영:
- **LOCK-1 SSOT Separation**: Bundle loading boundary는 Decision/Evidence 저장소와 물리적으로 완전히 격리된다.
- **LOCK-6 Hash-Coupled Bundle Version**: 번들 버전은 해시와 결합되어 변경 불가능한(Immutable) 성격을 갖는다.
- **LOCK-11/17 Deterministic Bundle Hash Rule**: Sorted Map Hash (path asc 정렬 + content hash) 기반의 결정론적 해시 계산 규칙을 강제한다.
- **LOCK-15 Runtime Version Compatibility Gate**: 실행 시점에 번들과 런타임 엔진 간의 버전 호환성을 엄격히 검증한다.
- **Session Pinning (LOCK-5, LOCK-12)**: 세션은 시작 시점의 bundle_version에 고정(Pinned)되며 실행 중 변경되지 않는다.

상태:
- ✅ **완료 (2026-02-23)**

구현 요약:
- [x] Workflow Bundle Active Store (`ops/runtime/bundles/active`)
- [x] LOCK-17 Sorted Map Hash (결정론적 해시)
- [x] BundleResolver (`runtime/bundle`) 구현 (Adapter Layer)
- [x] Session별 bundle pin 파일 (`storage/sessions/<session>.bundle_pin.json`)
- [x] Atomic pin 생성 및 rotate(.bak) 정책 적용
- [x] `--promote-bundle` 명시적 re-pin 경로 확보
- [x] `--fresh-session` 시 pin rotate(.bak) 동작 연동
- [x] bundle_hash를 policyRef에 주입하여 computeExecutionPlanHash 무결성 통합
- [x] Strict Fail-Fast (BUNDLE_HASH_MISMATCH / VERSION_MISMATCH)
- [x] Runtime Version Gate (LOCK-15) 구현

검증 결과:
- [x] npm run typecheck PASS
- [x] npm test PASS
- [x] `PROVIDER=openai npm run -s smoke:prd018` PASS (Fresh → Reuse → Drift Fail-fast 시나리오 검증 완료)

---

## Phase 6 – UI 계층 & UX (User Control)

의미:
Phase 6은 CLI 기반 UX 계약(세션/오버라이드 등)을 고정하며, Phase 6A는 Web Chat UI 안정화에 집중한다.

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

## Phase 6A — Chat-First UX Stabilization

의미:
- 워크플로우 자동화 확장 전, Web UI를 실제 사용 가능한 수준(ChatGPT-level)으로 안정화
- "Multi-provider Chat" 인터페이스로서의 정체성 확립
- 개발자 도구가 아닌 사용자 앱으로서의 최소 UX 확보

**Phase 6A는 Governance Layer 위에서 동작하며, 번들 무결성 및 세션 고정 규칙을 우회할 수 없다.**

상태:
- 🟡 **부분 완료 (PRD-013 ~ 016 완료)**
- 🔵 **PRD-017 진행 예정 (NEXT MAIN)**

### Phase 6A PRD Expansion (React-based Stabilization)

#### PRD-013: Minimal Web UI (CLI Escape) ✅ **DONE**
- REST + SSE 기반의 경량 웹 서버 및 Unified Runtime Entry 확보

#### PRD-014: Web UI Framework Introduction ✅ **DONE**
- React 기반 렌더링 레이어 도입 및 DTO Isolation 환경 구축 완료

#### PRD-015: Chat Timeline Rendering v2 ✅ **DONE**
- **Deterministic Fake Streaming**: 엄격한 리플레이 트리거를 통한 시각적 스트리밍 구현
- **SSOT Integrity**: 서버 이력을 최종 권위로 유지하며 클라이언트 측 임의 변조 차단
- **Drift Hard Stop**: 재생 중 스냅샷 업데이트 시 즉시 동기화 강제

#### PRD-016: Session Management Panel ✅ **DONE** (merge: 749832f)
- **Web Session Management Panel**: `web.*` 접두사를 가진 세션에 대한 목록화/전환/삭제 기능 추가
- **Namespace Authority**: `runtime/orchestrator/session_namespace.ts`를 통한 세션 발견 및 검증 권한 중앙화
- **Web-only Metadata Overlay**: `ops/runtime/web_session_meta.json`을 통한 비침습적 메타데이터 저장 (Atomic tmp+rename, Serialized write)
- **Safe Rotation**: `fs.unlink`를 금지하고 UTC 타임스탬프 기반의 이름 변경(Rename-only) 로테이션 정책 적용
- **Pre-engine Hook**: 사용자 메시지 전송 시 `runRuntimeOnce` 호출 전 메타데이터 선제적 갱신
- **Constraints Preserved**: Core-Zero-Mod 유지, `session_state` 스키마 보존, DTO 내 해시 필드 비노출

#### PRD-017: Provider / Model / Domain UI Control (NEXT)
- **UX-Only**: UX 레이어 전용 기능으로 구현하며, Core / Session schema / Bundle Governance 변경을 엄격히 금지한다.
- **Hash-Aware**: PRD-012A의 결정론적 플랜 해시 구조를 전제로 작동한다.
- **Session Restart**: 설정 오버라이드 시 자동 병합 대신 새 세션 유도 방식으로 처리한다.
- **Scope**: 상단 상태 스트립 UI, 도메인/모델 설정 컨트롤, PRD-017 전용 툴팁 포함.

#### PRD-019: Dev Mode Overlay & Debug Projection
... (rest of planned PRDs)

### 🔴 P0 — Critical (Immediate Usability)
1. **Chat-style Messaging**: ✅ 완료 (PRD-015)
2. **Configuration Error Banner**: ✅ 완료 (PRD-015 기반 마련)

### 🟡 P1 — Comfort Improvements
3. **Session Management UI**: ✅ 완료 (PRD-016)
4. **Tooltips**: 🚀 진행 예정 (PRD-017 범위 포함)

### 🟢 P2 — Self-Contained App Direction
5. **Direct Configuration**: 🚀 진행 예정 (PRD-017)
6. **State Visualization**: 🚀 진행 예정 (PRD-019)

**Phase 6A Governance Lock (Non-Goals):**
- UI 레이어로 비즈니스 로직 이관 금지
- 클라이언트 측 상태 권한(Authority) 부여 금지
- 프론트엔드 내 정책 해석(Policy Interpretation) 로직 구현 금지
- Phase 6A 내 Decision DB 직접 조회 도구 구현 금지
- Phase 6A 내 멀티 에이전트 오케스트레이션 UI 기능 구현 금지 (해당 기능 구현은 Phase 5 이후에만 허용)
- PRD-014 ~ PRD-017은 UX 안정화 범위 내에서만 수행되며, Agent Orchestration 기능 구현은 Phase 5 이후에만 허용된다.
- 워크플로우 그래프 시각화 확장 금지
- 정책(Policy) 시스템 재설계 금지
- Core Runtime 수정 금지
- 저장소(Storage) 레이어 구조 변경 금지
- **No runtime contract changes during UX stabilization**
- **No session state schema modification during this phase**
- **UX 레이어 개선에만 집중**

## Current Web Runtime Status
- `/` → Legacy UI (explicitly restored; 404 regression fixed)
- `/v2` → React UI (primary UX direction)
- **Parallel Serving Active**: Legacy and React co-exist during stabilization phase
- **REST/SSE Contracts**: Unchanged (GraphStateSnapshot projection-only)
- **Unified Entry**: CLI & Web share `runRuntimeOnce`
- **Session Query Enforcement**: All Web API calls include explicit `?session=` parameter
- **Core-Zero-Mod**: No changes to `src/core/**`
- **Build-Time Guard Active**: dependency-cruiser + CI enforcement
- **No Runtime Contract Changes During UX Stabilization**

---

## Phase 7 – Letta Anchor 연동 (Navigation Hint)

의미:
- 대화 중 Anchor(네비게이션 힌트) 감지 및 저장
- Retrieval 시 Anchor를 통한 상기 기능 구현
- Anchor 발견 시 원문(Evidence/Decision) 확인 강제 워크플로우 구현

상태:
- ☐ 계획

체크리스트:
- [ ] Anchor 자동 감지 트리거 (현재는 수동/명시적 persistAnchor 위주)
- [ ] Anchor → Evidence/Decision 이정표 연결 로직 고도화
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

#### PRD-020: Extensible Message Schema (Multimodal-Ready)
- 메시지 스키마 확장 가능 구조 준비
- text-only 가정 제거
- tool / image / event 타입 확장 대비
- Core 수정 없이 Adapter 레벨에서 확장

상태:
- ☐ 계획

---

# Current Mainline Baseline (2026-02-23)

- **Architecture Stable**: PRD-001부터 PRD-013까지 모든 설계 및 구현 동기화 완료.
- **Contract Enforcement**: Executor와 Interpreter 간의 Step Contract v1.1 LOCK 및 결정론적 해시 검증 적용.
- **Storage Integrity**: SQLite v1 기반의 Decision/Evidence 저장소가 안정적으로 작동하며 WAL 모드 적용됨.
- **Verification**: 모든 단위 테스트 및 통합 스모크 테스트 통과.
- **PRD-018 Verified**: CLI smoke test (Fresh → Reuse → Drift Fail-fast) 검증 완료.
- **Bundle Governance (DONE)**: PRD-018 구현 완료. 결정론적 해시 무결성(LOCK-17) 및 세션 고정(Pinning) 엔진 활성화. CLI/Web 공통 거버넌스 SSOT 확립.
- **Governance Isolation**: Bundle Governance Adapter Layer is fully isolated from Core (Strict LOCK-7/17).
- **Web Runtime Functional**: Chat loop (init → input → state → stream) validated via API-level smoke testing.
- **React Mount Stability**: Temporal Dead Zone crash resolved in App.tsx
- **Legacy Route Regression Fixed**: Root path `/` restored after /v2 integration
- **UI Smoke Verified**: init → input → state → stream validated with session defaulting
- **Data Safety**: 세션 상태의 JSON 직렬화 및 `extensions` 가독성/순환 참조 안전성 확보.
- **Web Isolation**: Web DTO Isolation 및 Core Literal Dependency Prohibition 규칙 준수.

---

# 4. PRD 상태 연동 현황

| PRD | 제목 | 상태 | 해당 Phase | 비고 |
|:---|:---|:---|:---|:---|
| PRD-001 | Core Runtime Skeleton | COMPLETED | Phase 1 | 정책 중립 엔진 완료 |
| PRD-002 | Policy Injection Layer | COMPLETED | Phase 2 | 도메인 정책 주입 완료 |
| PRD-003 | Repository Context Plugin | COMPLETED | Phase 2 | 레포 스캔 및 번들링 완료 |
| PRD-004 | Session Persistence | COMPLETED | Phase 1 | 세션 상태 복구 완료 |
| PRD-005 | Decision / Evidence Engine | COMPLETED | Phase 3 | 결정/근거 SSOT 엔진 완료 |
| PRD-006 | Storage Layer (SQLite v1) | COMPLETED | Phase 3 | SQLite 영구 저장소 연동 완료 |
| PRD-007 | Step Contract Lock | COMPLETED | Phase 1 | v1.1 Contract LOCK 적용 완료 |
| PRD-008 | PolicyInterpreter Contract | COMPLETED | Phase 1 | 정책 해석기 계약 완료 |
| PRD-009 | LLM Provider Routing | COMPLETED | Phase 1 | 프로바이더 라우팅 기초 완료 |
| PRD-010 | Session Lifecycle UX | COMPLETED | Phase 6 | 세션 리셋 및 네임스페이스 지원 |
| PRD-011 | Secret Injection UX | COMPLETED | Phase 6 | 시크릿 로컬 저장 및 주입 완료 |
| PRD-012A | Deterministic Plan Hash | COMPLETED | Phase 6 | 결정론적/도메인 인지 해시 도입 |
| PRD-012 | Provider/Model Override UX | COMPLETED | Phase 6 | 실행 시점 모델 오버라이드 |
| PRD-013 | Minimal Web UI | COMPLETED | Phase 6 | 관찰자 모드 Web UI 완료 |
| PRD-014 | Web UI Framework Introduction | COMPLETED | Phase 6A | React UI (/v2) active |
| PRD-015 | Chat Timeline Rendering v2 | COMPLETED | Phase 6A | Deterministic Fake Streaming |
| PRD-016 | Session Management Panel | COMPLETED | Phase 6A | 세션 UX |
| PRD-017 | Provider/Model/Domain UI Control | PLANNED | Phase 6A | 설정 UI |
| PRD-018 | Bundle Promotion Pipeline | COMPLETED | Phase 5.5 | 결정론적 런타임 거버넌스 확립 |
| PRD-019 | Dev Mode Overlay | PLANNED | Phase 6A | 디버그 분리 |
| PRD-020 | Extensible Message Schema | PLANNED | Phase 9 | 멀티모달 준비 |

---

# 5. 완료 정의 기준 (Definition of Done)

각 Phase는 다음 조건을 모두 만족해야 완료로 간주한다:

1. **PRD 충족**: 관련 PRD의 기능적/기술적 요구사항 구현 완료.
2. **테스트 통과**: 단위 테스트 및 시나리오 테스트 통과.
3. **철학 정합성**: [ai_orchestration_runtime_design_v_2.md](./ai_orchestration_runtime_design_v_2.md)의 원칙과 충돌이 없음.
4. **Core 중립성**: Core Engine 내부에 특정 도메인 문자열이나 로직이 하드코딩되지 않음.
5. **검증 완료**: 런타임 빌드 시 오류가 없으며 타입 안정성이 확보됨.

### Phase 5.5 – Runtime Governance Layer DoD:
- Runtime이 Active Bundle을 읽어 초기화 가능
- 호환되지 않는 Bundle은 활성화되지 않으며, Runtime은 기존 정상 Active Bundle을 유지한다.
- Prod Profile에서 Judge 실패 시 Core Fallback 동작 확인
- 기존 Session은 기존 bundle_version 유지
- Bundle switching applies only at session start; in-flight sessions remain pinned to their starting bundle_version. (번들 교체는 세션 시작 시점에만 적용되며, 실행 중인 세션은 시작 시점의 번들 버전에 고정된다.)

---

# 6. 변경 불가 원칙

- **철학 우선**: 철학 문서와 충돌하는 어떠한 구현도 허용되지 않는다. 구현이 철학과 충돌할 경우 구현을 수정하거나 철학 문서를 공식적으로 갱신(Decision Log)해야 한다.
- **구조적 중립성**: Phase의 순서는 효율성에 따라 조정될 수 있으나, Core와 Domain의 분리 구조는 변경될 수 없다.
- **비차단 원칙**: Runtime은 일반 실행 흐름에서 차단을 수행하지 않으며, 제어는 상위 거버넌스 층에서 수행한다.

### Governance Exception Clause – Bundle Integrity Fail-fast
Runtime은 일반 실행 흐름을 차단하지 않는다. 단, Bundle 무결성 실패는 Core 보호를 위한 예외적 Fail-fast이며, 다음 조건에 한하여 시스템 보호를 위한 즉시 차단을 허용한다:

1) **bundle_hash 무결성 불일치**
2) **runtime_version < manifest.min_runtime_version**
3) **pin 파일 불일치 또는 위변조 감지**

여기서 '즉시 차단'은 신규 Bundle 활성화 절차의 중단(Abort)을 의미하며, Runtime 프로세스 자체 종료를 의미하지 않는다. 이 Fail-fast는 사용자 로직 차단이 아니라 Runtime Core 보호를 위한 무결성 수호 장치다. Bundle rejection은 Runtime 실행 중단이 아니라, 직전 정상 Active Bundle 유지로 정의된다.

---

# Appendix A — Changelog (Patch History)

### v1.5 – Runtime Governance Activation (2026-02-23)
- PRD-018 Bundle Promotion Pipeline 전면 구현 및 검증 완료.
- Sorted Map Hash (LOCK-17) 기반 무결성 검증 엔진 활성화.
- Session-specific bundle pinning (storage/sessions) 및 rotate 정책 적용.
- Adapter Layer 기반의 Core-neutral Governance 구조 확립.

### v1.4 – Governance Alignment
- Bundle Integrity Fail-fast exception codified
- Phase 5.5 Governance Layer elevated above UX
- Session redefined as pinned execution context
- DocBundle vs Workflow Bundle terminology separated

### v1.3 – Bundle Governance Finalization
- LOCK-1 physical boundary enforced
- Deterministic bundle_hash rule codified
- Session pinning principle documented

### SSOT Consolidation – PRD-018 Lock
- PRD-018 확정 (Bundle Promotion Pipeline)
- PRD-020 재번호 지정
- LOCK-1/4/5/6/11/12/15 명시
- Phase 5.5 정식 승격 및 계층화 완료

---

# Next Execution Focus (Refinement Phase)

현재 시스템은 **"Chat-First UX Stabilization (Phase 6A)"**의 핵심 기능을 성공적으로 완료하고 **"Phase 6A 확장 단계"**로 진입한다.

**Primary Focus:**
- **PRD-017: Provider / Model / Domain UI Control (NEXT MAIN)**
  - 상단 상태 스트립 UI (Provider/Model/Domain)
  - 요청 단위 오버라이드 및 새 세션 유도 (PRD-012A 해시 인지)
  - "unset" 도메인 처리 및 서버 SSOT 권한 유지

**Environment Note:**
- `run:web` manual smoke can fail in some sandbox environments due to EPERM port binding; tests/typecheck/ui:build passed.

**Secondary (Deferred):**
- **Phase 7: Letta Anchor 연동**
  - 장기 기억 항해를 위한 앵커 감지 로직 설계 (UX 고도화 완료 후 재개)

---
*Last Updated: 2026-02-23 (Post PRD-018 Governance Lock + Phase 6A Alignment)*

NOTE:
policy/profiles/**/*.yaml 내 legacy step 명칭(recall, memory_write 등)은
현재 runtime normalizePolicyStep을 통해 v1 StepDefinition으로 변환됨.
정책 레이어 정리는 별도 Policy PRD에서 처리 예정.
