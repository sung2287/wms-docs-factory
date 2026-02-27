# C-022 — Guardian Enforcement Layer Intent Map

| Intent ID | Intent Name | Description | Outcome |
|:---|:---|:---|:---|
| `INT-G01` | Detect ConflictPoint Violation | Atlas ConflictPoints Index 기반 충돌 감지 | `WARN` 또는 `BLOCK` + InterventionRequired |
| `INT-G02` | Detect STRONG Decision Contamination | PRD-025 Commit 전 STRONG/LOCK 오염 가능성 감지 | `BLOCK` + InterventionRequired |
| `INT-G03` | Detect Contract Violation | Atlas Contract Index 기반 계약 위반 감지 | `WARN` 또는 `BLOCK` |
| `INT-G04` | Generate Guardian Report | 감지 결과를 Evidence로 저장 가능한 리포트 생성 | Report 객체 생성 + evidenceRefs 포함 |
| `INT-G05` | Resume after Intervention | InterventionRequired 후 사용자 승인으로 재개 | 실행 재개 또는 Abort |

## INT-G01: Detect ConflictPoint Violation
- **Success Criteria**: `executePlan` 루프의 `runValidators` 실행 시, 현재 계획에 포함된 Artifact가 Atlas의 `ConflictPoints`와 충돌하는지 확인하고 해당 `conflict_id`를 `evidenceRefs`에 포함하여 `BLOCK` 결과 반환.
- **Rejection / Block Conditions**: Atlas 조회 API 실패 시 `Stale` 상태 허용(PRD-026), 단 `BLOCK` 판정은 불가(`WARN`으로 downgrade).
- **Signal Specification**: `InterventionRequired` payload에 `{ type: "CONFLICT", evidenceRefs: string[] }` 포함.

## INT-G02: Detect STRONG Decision Contamination
- **Success Criteria**: Atlas `DecisionIndex`에서 조회한 기존 `DecisionIndexEntry.strength`가
  `STRONG` 또는 `LOCK`인 Decision과 충돌 가능성이 있을 경우,
  Guardian은 이를 감지하여 `BLOCK` 결과를 반환함으로써 자동 Commit을 방지하고
  중재(Intervention)를 유도한다.
- **Rejection / Block Conditions**: `strength`가 `NORMAL`일 경우 개입하지 않음(`ALLOW`).
- **Signal Specification**: `InterventionRequired` payload에 `{ type: "DECISION_CONTAMINATION", affectedDecisionRootIds: string[] }` 포함.

## INT-G03: Detect Contract Violation
- **Success Criteria**: Atlas `Contract` 인덱스에 명시된 구조적 제약 조건을 어기는 경우 `WARN` 또는 `BLOCK` 결과 반환.
- **Rejection / Block Conditions**: `changeReason` 필드 존재 여부 확인 불가(사용 금지).
- **Signal Specification**: `ValidatorResult` 객체 반환.

## INT-G04: Generate Guardian Report
- **Success Criteria**: 감지된 위반 사항을 B-022 스키마에 맞춰 생성하고, `evidenceRefs`에 유효한 Atlas/Decision 참조 포함.
- **Rejection / Block Conditions**: `evidenceRefs`가 없는 `BLOCK` 리포트 생성 거부.
- **Signal Specification**: `ValidatorResult` 객체 내 `evidenceRefs` 필드 채움.

## INT-G05: Resume after Intervention
- **Success Criteria**: 사용자가 `InterventionRequired` 상태에서 명시적으로 `ALLOW` 승인 시, 해당 Guardian 위반을 무시하고 실행 루프 재개.
- **Rejection / Block Conditions**: 사용자 승인 없이 실행 재개 불가.
- **Signal Specification**: `GraphState.status`가 `RUNNING`으로 복구됨.

---
*Intent Map generated for PRD-022. Following ABCD spec.*
