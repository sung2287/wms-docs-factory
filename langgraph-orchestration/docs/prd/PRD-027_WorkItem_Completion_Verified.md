# PRD-027 — WorkItem Completion & VERIFIED Engine
상태: DRAFT (Design 예정)

## 0. Scope
포함:
- WorkItem v1 엔티티(테이블 + 상태머신) 도입
- completion_policy evaluator(도메인팩 외부화)
- VERIFIED 전이 Enforcer 규칙
- Atlas stale adapter 경로 확정

제외:
- Retrieval 전략 개선(PRD-023)
- Atlas 인덱스 갱신(PRD-026)
- Decision Commit Gate(PRD-025)

## 1. Key LOCKs (요약)
- WorkItem.decision_id는 decisions.id(DecisionVersion UUID)에 바인딩(root_id 금지)
- transition log append-only
- completion_policy는 평가만, 전이는 Enforcer만
- stale=true면 auto-verify 금지

### 🔒 Structural Locks

- WorkItem은 DecisionVersion UUID에 바인딩 (root 바인딩 금지)
- transition log는 append-only
- completion_policy는 평가만 수행하며 상태 전이는 Enforcer만 수행
- Atlas stale=true일 경우 auto VERIFIED 금지
- Completion 결과는 PlanHash에 포함되지 않음
- BudgetExceededError는 FailFast이며 Completion 흐름과 혼합 금지

## 2. Exit Criteria (v1)
| # | 종료 조건 | 비고 |
|:--|:--|:--|
| 1 | WorkItem v1 테이블 + FK/인덱스 추가 | work_items / work_item_transitions |
| 2 | 상태 전이 엔진 구현 | 임의 점프 불가 + 전이 로그 기록 |
| 3 | completion_policy evaluator 동작 | Domain Pack 기반 |
| 4 | VERIFIED 전이 강제 | IMPLEMENTED → VERIFIED → CLOSED |
| 5 | stale 처리 정책 적용 | stale 시 auto-verify 금지 |
