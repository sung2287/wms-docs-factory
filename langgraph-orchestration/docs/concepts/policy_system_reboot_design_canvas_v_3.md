# Policy System Reboot Design Canvas (v1)

## 0. 목적
현재 정책 시스템은 다음 문제로 인해 실질적으로 작동하지 않는 상태이다:
- 정책 등록이 실행 플로우(step)에 종속되어 독립적으로 동작하지 않음
- Guardian 판정과 Engine 개입 루프가 하나의 사이클로 연결되어 있지 않음
- 정책 0개 상태에서 합법 상태 정의가 없어 크래시 발생
- UI가 흐름을 재개시키는 장치가 아니라 중단시키는 장치로 동작

목표는 다음과 같다:
1. 정책 등록을 독립 기능으로 분리
2. 자연어 기반 정책 UX 확립
3. Guardian–Engine–UI를 하나의 실행 루프로 연결
4. 즉시 적용 UX를 제공하되 시스템 안정성 유지

---

## 1. 전체 구조 개요

### 1.1 역할 분리 원칙 (레포 계층 구조에 맞춘 매핑)

Guardian (PRD-022/030 계열):
- 판정만 수행 (ValidatorFinding: ALLOW/WARN/BLOCK)
- 실행 흐름 제어/중단 권한 없음 (Policy Hook 범위)

Engine (레포 용어로는 단일체가 아님):
- Orchestrator → Graph(runGraph) → PlanExecutor(executePlan/plan.executor.ts) 계층이 합쳐서 "흐름 엔진" 역할을 수행
- Guardian 결과(ValidatorFinding[])를 해석하여 InterventionRequired 상태를 생성/유지
- 사용자 응답(interventionResponse)을 받아 다음 run에 반영 (next-session effect model)

UI:
- Engine이 발행한 상태(InterventionRequired + projection)를 표시
- 사용자 선택/입력만 전달
- 판단 로직 포함하지 않음

---

## 2. 정책 표현 계층 구조

정책은 항상 3계층 구조로 저장한다:

1. raw_text (사용자 자연어 원문)
2. compiled_rule (시스템 실행용 구조)
3. metadata (version, active, scope, timestamps 등)

실행 시 SSOT는 compiled_rule이다.
사용자에게는 raw_text만 노출한다.

---

## 3. 정책 등록 – 독립 기능 설계

### 3.1 정책 센터 (독립 진입점)

기능:
- 정책 목록 조회
- 새 정책 생성
- 정책 편집 (자연어 수정)
- 정책 활성/비활성
- 정책 테스트(선택적)

등록은 실행 실패의 부산물이 아니라 독립 기능이다.

### 3.2 등록 흐름

1. 사용자 자연어 입력
2. Parse → compiled_rule 생성
3. Guardian이 정책 자체 검증
   - 형식 유효성
   - 과도한 범위 여부
   - 기존 정책과 충돌/중복 여부
4. 통과 시 저장
5. 즉시 적용 (다음 입력부터)

---

## 4. 자연어 ↔ 시스템 언어 변환

### 4.1 목표
- 사용자에게는 자연어(raw_text)만 노출
- 시스템은 실행/판정에 사용할 compiled_rule(= 레포의 PolicyRegistrationRequest / NormalizedExecutionPlan 호환 구조)만 신뢰

### 4.2 결정성(Derterminism) 충돌 방지 원칙
- LLM 기반 자연어 파싱은 비결정론적일 수 있음
- 해결: 저장 시점에 생성된 compiled_rule을 그대로 영구 저장(SSOT)하고, 실행은 항상 저장된 compiled_rule만 사용
- 사용자가 자연어를 다시 편집/저장하면 "새 버전"으로 재컴파일하여 저장(이때만 compiled_rule이 변경됨)

### 4.3 UX 원칙(읽기 전용 + 일반 유저 비노출)
- compiled_rule은 UI에서 편집 불가(읽기 전용)
- 일반 유저에게는 raw_text만 보여줌
- 저장(Submit) 자체가 compiled_rule 확정 행위이며, 내부적으로는 요약/검증 결과(통과/거절 사유)만 사용자에게 설명

---

## 5. 실행 루프 통합 구조

실행 사이클(현재 레포의 next-session effect model과 정합되게 표현):

1. 사용자 입력
2. Engine(Orchestrator/Graph/PlanExecutor)이 실행 계획 생성(PolicyInterpreter → NormalizedExecutionPlan)
3. Guardian 정책 평가(runValidators)
4. Guardian 결과 반환(ValidatorFinding[]: ALLOW/WARN/BLOCK)
5. Engine이 결과 해석
   - OK: 계속 진행
   - BLOCK/WARN 중 "사용자 개입 필요" 조건 충족 시: InterventionRequired로 전환(Projection 포함)
6. UI 모달/질문 표시
7. 사용자 선택/입력(interventionResponse)
8. Engine 재실행 시 반영
   - 정책 채택/등록/수정은 현재 설계상 "다음 run"부터 적용(next-session effect)

중요: v1에서는 CONFLICT/MISSING_POLICY/AMBIGUOUS 같은 새 결과 타입을 제안했으나,
레포 계약을 유지하기 위해 기본 타입은 ALLOW/WARN/BLOCK을 유지하고,
필요한 경우 BLOCK/WARN에 메타데이터(예: reasonCode, recommendedActions)를 부가하는 방식으로 확장한다.

---

## 6. 정책 0개 상태 정의

policyCount == 0 인 경우 가능한 합법 액션은:
- REGISTER (새 정책 생성)
- RUN_WITHOUT_POLICY (이번만 진행)

수정/확인(overwrite)은 노출하지 않는다.

이 상태는 오류가 아니라 정상 상태로 정의한다.

---

## 7. 즉시 적용 원칙

정책 저장 후:
- 다음 사용자 입력부터 새 정책 적용
- 현재 진행 중인 턴은 소급 변경하지 않음

각 실행은 정책 버전 스냅샷을 고정한다.

---

## 8. BLOCK 분류 원칙 (System Runtime Hook Class Split Contract 정합)

현재 계약에 맞춘 정리:

1) Safety/Integrity Hook (Core Safety Contract 영역)
- 구조 계약 위반/치명 인바리언트 위반
- 실행 중단(진짜 fail-fast) 권한 보유

2) Guardian/Policy Hook (ValidatorFinding 기반)
- ALLOW/WARN/BLOCK 중 BLOCK이라도 "실행 중단 권한"은 없음
- BLOCK은 InterventionRequired 전환의 근거(= 사용자 개입 필요 신호)로만 사용

따라서 "Non-overridable" 성격의 중단은 Guardian이 아니라 Safety Hook에서만 발생해야 한다.

---

## 9. 최소 단계 실행 계획

Phase 1:
- 정책 센터 UI 구축
- 자연어 → compiled_rule 변환
- 정책 자체 검증 루프 확립

Phase 2:
- ValidatorFinding에 reasonCode / recommendedActions 메타데이터 확장
- Policy Center ↔ Guardian 등록 시점 검증 연동
- (기존 Intervention 루프는 PRD-034/035에서 완료됨 — 재구현 불필요)

Phase 3:
- 트리거 안정화
- 정책 테스트 기능 추가

---

## 10. UX Soft-Denial Principle (Natural Guidance Model)

### 10.1 기본 원칙
- Hard denial("BLOCK. 끝.")은 UX에서 피한다.
- 시스템 계약(Core Invariants)을 직접 노출하지 않는다.
- 사용자 의도를 재프레이밍하여 가장 가까운 안전한 대안을 제안한다.

### 10.2 처리 계층

Layer 0 — Core Invariants (사용자 정책으로 수정 불가)
- 무결성, 해시, 저장 계약, 세션 정합성
- 위반 시 실행 중단이 아니라 "범위 재설정 + 대안 제시"로 전환

시스템 내부적으로는 Core Safety Contract 위반 시 FailFastError가 발생한다(변경 없음).
UX 레이어에서 이 에러를 사용자 친화적 재프레이밍 메시지로 변환하는 것이 본 원칙의 범위이다.

Layer 1 — Safety / Platform 가이드
- 직접 차단 대신 대체 행동 제안

Layer 2 — 사용자 정책 충돌
- 항상 선택형 개입 (무시 / 수정 / 등록 / 범위 축소)

### 10.3 UX 표현 방식
- 금지 표현 대신 재프레이밍 사용
  예: "이 요청은 시스템 무결성을 깨뜨릴 수 있습니다" 대신
      "이 기능은 재현 가능한 실행을 유지하기 위해 항상 활성화됩니다. 대신 속도를 높이려면 다음 옵션을 고려해볼 수 있어요."

- 항상 최소 1개의 실행 가능한 선택지를 제공한다.

---

## 11. 성공 기준

시스템이 다음을 만족하면 1단계 성공으로 간주:

1. 정책 0개 상태에서 오류 없이 등록 가능
2. 등록 직후 다음 입력에 정책 적용
3. 충돌 시 모달 표시 후 선택하면 실행 재개
4. 정책/가디언 위반이 있어도 Hard Stop 대신 안전한 분기 제안이 표시됨
5. Core Invariant 위반 시에도 UX는 중단이 아니라 재프레이밍 기반 안내로 전환됨

---

End of Canvas v1


