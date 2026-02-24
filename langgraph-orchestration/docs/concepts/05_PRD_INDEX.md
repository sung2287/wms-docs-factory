[ DONE ]
PRD-002: Policy Injection Layer
PRD-001: Core Runtime Skeleton (Policy-Neutral Engine)
PRD-003: Repository Context Plugin (Optional Tool)
PRD-004: Session Persistence
PRD-007: ExecutionPlan Step Contract (LOCK)
PRD-005: Decision / Evidence Engine
PRD-006: Storage Layer (SQLite v1)
PRD-009: LLM Provider Abstraction & Routing
PRD-008: PolicyInterpreter Contract
PRD-010: Session Lifecycle UX
PRD-011: Secret Injection UX
PRD-012A: Deterministic & Domain-Aware Hash
PRD-012: Provider/Model Override UX
PRD-013: Minimal Web UI(= CLI escape)
PRD-014: Web UI Framework Introduction
PRD-015: Chat Timeline Rendering v2
PRD-016: Session Management Panel
PRD-017: Provider / Model / Domain UI Control
PRD-018: Bundle Promotion Pipeline

[ IN-PROGRESS / MAIN ]

[ PLANNED / MAIN ]
PRD-019: Dev Mode Overlay & Debug Projection
- Plan metadata Dev 표시
PRD-020: Extensible Message Schema


### PRD-009 Deferred Note (Response Schema)

The standardized LLM response schema (usage, meta) described in PRD-009 §3.1
is intentionally deferred.

Current LLMClient interface returns `Promise<string>` to preserve Core neutrality
and avoid expanding the Core execution contract at this stage.

This is a deliberate v1 decision (minimal surface change).
Response schema expansion must be handled in a future PRD
that explicitly updates Core handlers and contracts.

---

- LangGraph는 의미(Decision/Evidence)의 SSOT다.
- 결과물(Artifacts) SSOT는 각 도메인 시스템(WMS/Git)에 있다.
- Runtime은 실행기이며 어떤 경우에도 차단하지 않는다.
- 모드 정의는 전략, 세션 중 모드 전환은 실행 판단이다.
- 현재 모드는 UI에 명확히 표시되어야 하며 수동 전환이 우선한다.
- Decision은 scope를 가진다.
- global axis는 모든 도메인에 적용된다.
- 도메인 Decision은 해당 영역에서만 적용된다.
- axis > lock > normal 우선순위를 따른다.
- Decision은 즉시 저장된다.
- Decision 수정은 versioned 방식이다.
- strength는 실행 차단과 무관하다.
- Decision은 global + domain scope를 가진다.

currentDomain을 누가 언제 세팅하는가
Anchor 저장 인터페이스를 어떻게 추상화할 것인가
이건 PRD-006/008 영역.