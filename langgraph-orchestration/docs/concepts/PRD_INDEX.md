[ DONE ]
PRD-002: Policy Injection Layer
PRD-001: Core Runtime Skeleton (Policy-Neutral Engine)
PRD-003: Repository Context Plugin (Optional Tool)
PRD-004: Session Persistence

[ IN-PROGRESS / MAIN ]

[ PLANNED / MAIN ]
PRD-007: Step Contract lock
PRD-005: Decision / Evidence Engine
PRD-006: Storage Layer (SQLite v1)
PRD-008: PolicyInterpreter Contract

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