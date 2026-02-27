# D-022 — Guardian Enforcement Platform Spec

## 1. Guardian Validator 등록 방식 (DI)

### `runValidator` dep 주입 경로
- **`plan_executor_deps.ts`**: `executePlan` 실행 시점에 주입되는 `validators[]` 및 `postValidators[]` 배열에 Guardian 인스턴스를 포함시킨다.
- **주입 위치**: `src/core/plan/plan.executor.ts`에서 호출되는 `runValidators()` 내부에 Guardian이 등록되어 실행된다.

## 1-A. GraphState.validatorFindings 버킷

Guardian 실행 결과는 `GraphState`에 누적된다.
```ts
// GraphState 확장 (추가 필드)
validatorFindings?: readonly ValidatorFinding[];

// ValidatorFinding 타입
interface ValidatorFinding {
  readonly validator_id: string;
  readonly phase: "preflight" | "post";
  readonly class: HookClass;
  readonly status: "ALLOW" | "WARN" | "BLOCK";
  readonly reason: string;
  readonly evidenceRefs?: readonly string[];
  readonly logic_hash?: string;
}
```

운영 원칙:
- `runValidators`가 findings를 반환하고, `executePlan`이 state에 append한다.
- `applyPolicyIntervention`은 `intervention.reasons`(string[])만 유지한다.
  findings와 reasons는 별도로 관리된다.
- `validatorFindings`는 append-only이며 실행 중 개별 항목을 수정/삭제하지 않는다.
- Plan Hash 계산 대상이 아니다. (`ExecutionPlan` 구조만 해시 대상)
- `validatorFindings[].logic_hash`는 `ValidatorSignature.logic_hash` 값을
  복사하여 채운다. `ValidatorResult`로부터 유도 금지.
  (결정론 보장: signature 고정 → findings 고정 → Exit Criteria 3 만족)

## 2. validator_id 네이밍 레지스트리 (Standard IDs)
Guardian의 모든 규칙은 다음 중 하나로 정의되어야 한다.
- `"guardian.conflict_point"`: Atlas ConflictPoints Index 연동
- `"guardian.strong_decision"`: PRD-025 STRONG/LOCK 오염 감지.
  판정 입력은 `DecisionProposal.strength`와
  Atlas `DecisionIndexEntry.strength`(또는 기존 `DecisionVersion.strength`) 비교로만
  수행한다. 비구조 텍스트, LLM 출력, 금지 필드(`changeReason` 등)는
  판정 입력으로 사용 금지. (INV-1 Deterministic 준수)
- `"guardian.contract"`: Atlas Contract Index 연동
- `"guardian.evidence_integrity"`: Evidence 누락 검사

## 3. logic_hash 생성 규칙
- **검사 로직 소스**: Guardian의 각 검출 규칙 소스코드를 직렬화하여 해싱하거나, 해당 규칙의 설정(JSON)을 해싱하여 결정론적 알고리즘 상태를 보장한다.
- **연동**: `logic_hash`는 `ValidatorSignature` 필드로서, `computeExecutionPlanHash`
  계산 시 `validators[]` 배열의 일부로 자동 포함된다. 별도 연동 코드는 불필요하며,
  `ValidatorSignature`에 올바른 `logic_hash`를 채우는 것만으로 Plan Hash 무결성이
  보장된다. (PRD-012A)

## 4. Atlas 조회 연동
Guardian은 `AtlasQueryAPI`를 통해 다음 API를 호출한다.
- `queryConflictPoints(artifactRefs: string[]): Promise<ConflictPoint[]>`
- `queryContracts(artifactRefs: string[]): Promise<Contract[]>`
- `queryDecisionIndex(decisionRootId: string): Promise<DecisionIndexEntry>`

## 5. Evidence 저장 연동
- Guardian이 `BLOCK` 또는 `WARN`을 반환하면, 해당 `ValidatorResult`는
  즉시 DB에 저장되지 않는다. Guardian Report는 executePlan 루프 내에서
  `GraphState`에 누적되고, `PersistSession` 단계에서만 SQLite `EvidenceStore`에
  영속 저장된다. 실행 중(루프 내부) DB write는 금지된다.
  (PRD-026 Cycle-End SSOT 원칙 준수)
- **PRD-025 연동**: Guardian의 리포트는 `GraphState`에 누적된 후,
  PRD-025 Commit 시점에 `DecisionProposal.evidenceRefs`의 참조 후보로
  활용될 수 있다. Guardian이 직접 Proposal을 mutate하지 않는다.

`validatorFindings`는 PersistSession 이후 변경되지 않으며,
저장 후에도 세션 스냅샷과 동일해야 한다. (저장 이후 mutate 금지)

## 6. Phase Placement (Hook 배치 기준)
| Rule | Hook Placement | Reason |
| :--- | :--- | :--- |
| `conflict_point` | **preflight** | 실행 시작 전 미리 위험 지점 확인 |
| `strong_decision` | **preflight** | 의사결정 시도 전 오염 가능성 차단 |
| `contract` | **post** | Step 실행 후 계약 위반 결과 검사 |

## 7. Execution Flow Diagram
Guardian의 삽입 지점 및 흐름 제어를 명시한다.

```
executePlan (Main Loop)
  ↓
1. runValidators(preflight)
   ├─ Guardian("guardian.conflict_point"): class="POLICY"
   │  └─ result: "BLOCK" → applyPolicyIntervention() → InterventionRequired (실행 계속)
   └─ Guardian("guardian.strong_decision"): class="POLICY"
      └─ result: "BLOCK" → applyPolicyIntervention() → InterventionRequired (실행 계속)
  ↓
2. [Step 실행 루프]
  ↓
3. runValidators(post)
   └─ Guardian("guardian.contract"): class="POLICY"
      └─ result: "BLOCK" → applyPolicyIntervention() → InterventionRequired (실행 완료)
  ↓
4. PersistSession (Cycle End)
```

[state 누적 구조]
- intervention.reasons[]  ← POLICY WARN/BLOCK의 reason 문자열
- validatorFindings[]     ← 모든 validator의 전체 Finding 레코드 (append-only)
  (PersistSession에서 EvidenceStore로 저장)

---
*Platform Spec generated for PRD-022. Following ABCD spec.*
