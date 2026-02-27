# B-022 — Guardian Enforcement Layer Contract
Status: LOCKED
Depends On: PRD-026, PRD-025, PRD-024

## 1. Guardian Validator Interface Contract

### runValidator dep 함수 시그니처
실제 `plan.executor.ts`의 `deps.runValidator` 호출 인터페이스와 일치한다.
`DecisionContext` 타입은 존재하지 않으며 사용 금지.
```ts
type RunValidatorFn = (input: {
  phase: "preflight" | "post";
  signature: ValidatorSignature;
  state: Readonly<GraphState>;
  step?: Readonly<StepDefinition>;
  stepResultView?: unknown;
}) => Promise<ValidatorResult>;
```

### ValidatorSignature 필수 필드
- **`validator_id`**: `"guardian.<rule_name>"` (예: `"guardian.conflict_point"`)
- **`validator_version`**: `"v1"` 등 시맨틱 버전
- **`logic_hash`**: 검사 로직의 불변성을 보장하는 SHA-256 해시
- **`class`**: 반드시 `"POLICY"` (PRD-024 계약 준수)

### ValidatorResult 반환 계약
ValidatorResult는 Guardian Report의 원본 레코드이며 아래 필드를 포함한다.

- **`status`**: `"ALLOW" | "WARN" | "BLOCK"`
- **`reason`**: 위반 내용의 명확한 설명 (문자열)
- **`evidenceRefs`**: (Required for BLOCK/WARN) 위반 근거가 된 Atlas `conflict_id`
  또는 Decision `rootId` 목록
- **`validator_id`**: Guardian을 식별하는 ID (`"guardian.*"` 패턴)

LOCK:
- `phase`와 `class`는 `ValidatorFinding`에서만 관리되며,
  `ValidatorResult`에는 포함되지 않는다.
  `runValidators`가 `ValidatorSignature`로부터 채워
  `GraphState.validatorFindings` 항목으로 완성한다.
  (`ValidatorFinding` 타입 정의는 D-022 Section 1-A 참조)
- `validator_id`는 구현체가 반드시 채운다.

## 2. Guardian Report Schema (LOCK)

Guardian 리포트는 `evidenceRefs`와 함께 시스템에 영속 저장되며, `changeReason` 필드는 일체 사용하지 않는다 (PRD-025 제거 완료).

```ts
interface GuardianReport {
  readonly validator_id: string;        // "guardian.*" 패턴 준수
  readonly logic_hash: string;          // 결정론적 재현용 해시
  readonly status: "ALLOW" | "WARN" | "BLOCK";
  readonly reason: string;
  readonly evidenceRefs: readonly string[]; // Atlas/Decision ID 참조
  readonly detectedAt: "preflight" | "post";
  readonly affectedDecisionRootIds?: readonly string[];
  readonly riskLevel?: "low" | "medium" | "high";
}

NOTE:
`ValidatorResult`(runValidator 반환)와 `ValidatorFinding`(state 누적)은
현재 별도 타입으로 유지된다. Guardian 기능 확장 시점에 통합을 검토한다.
두 타입 간 의도적 필드 불일치는 금지하며, 필드 추가 시 양쪽을 동기화한다.
```

## 3. LOCK 목록
- **No Mutation**: Guardian은 `GraphState` 또는 `ExecutionPlan`을 직접 수정(mutate)해서는 안 된다.
- **No Side-Effects**: Guardian은 Atlas Write API, Decision Commit API, WorkItem 상태 전이 API를 직접 호출할 수 없다.
- **Intervention Restriction**: `POLICY BLOCK`은 실행 흐름을 물리적으로 중단하거나 강제 종료할 권한이 없다. 오직 `InterventionRequired` 상태 전이를 유발할 뿐이다.
- **Hash Integrity**: `logic_hash`는 검사 알고리즘이나 설정이 변경될 때 반드시
  갱신되어야 한다. `logic_hash`는 `ValidatorSignature` 필드로서 `validators[]`
  배열의 일부로 Plan Hash 계산에 자동 포함된다. (D-022 Section 3 일치)
- **Atlas Hash Isolation**: Guardian은 Atlas Snapshot Hash를 Plan Hash 계산에
  포함하지 않는다. `logic_hash`는 `ValidatorSignature` 필드로서
  `validators[]` 배열의 일부로만 Plan Hash에 포함되며,
  Atlas 관련 해시(snapshotHash, indexHash 등)는 일체 포함 금지이다.
  (PRD-026 LOCK-D 준수)
- **WARN Policy**: `POLICY` 클래스 validator의 `WARN`은 `BLOCK`과 동일하게
  `InterventionRequired` 상태 전이를 유발한다. 단, `SAFETY` 클래스는
  `BLOCK`만 즉시 중단이며 `WARN`은 해당 없다.
  `intervention.reasons`의 구분은 `validatorFindings[].status`로 수행한다.
  문자열 prefix(`WARN:` / `BLOCK:`) 방식은 금지한다.

## 4. Invariants (불변 조건)
- **INV-1**: (Deterministic) 동일한 입력(State, Context)과 동일한 `logic_hash`
  하에서는 반드시 동일한 `ValidatorResult`를 반환해야 한다.
  결정론 검증 대상은 `ValidatorResult` 단위가 아니라
  `state.validatorFindings` 배열 전체이다.
  동일 세션 재빌드 시 `validatorFindings`의 순서, 내용, `evidenceRefs`가
  동일해야 Exit Criteria 3번을 만족한다.
- **INV-2**: (Evidence Mandatory) `BLOCK` 또는 `WARN` 상태를 반환할 때, 반드시 하나 이상의 `evidenceRefs`를 포함해야 한다.
- **INV-3**: (Registry) 모든 Guardian의 `validator_id`는 반드시 `"guardian."` 접두어로 시작해야 하며, 시스템 네이밍 레지스트리에 등록되어야 한다.

---
*LOCK-A/B/C/D compliant. Generated for PRD-022.*
