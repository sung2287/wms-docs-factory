# PRD-022 — Guardian Enforcement Layer
Status: PLANNED
Created: 2026-02-27
Depends On: PRD-026 (Atlas), PRD-025 (Decision), PRD-021 (Extensibility), PRD-024 (Safety Seal)

## 0. 배경 및 목적
AI 코딩 협업 및 오케스트레이션에서 핵심 병목은 '충돌 파악'과 '문맥 오염'이다. PRD-022 Guardian은 PRD-026 Atlas Index Engine이 제공하는 충돌 지점(ConflictPoints) 및 계약(Contract) 데이터를 근거로 실행 중 정책 위반이나 설계 충돌을 자동 감지한다. 특히 PRD-025 Decision Capture Layer에서 발생하는 STRONG/LOCK 수준의 의사결정 오염을 방지하여 시스템의 안전성과 무결성을 수호한다.

## 1. 핵심 원칙 (LOCK)
- **Class Isolation**: Guardian은 반드시 `HookClass: "POLICY"` validator로 동작한다. `SAFETY` Hook(실행 즉시 차단)이 아니며, 정책적 개입을 담당한다.
- **Intervention-Only**: 위반 감지 시(`BLOCK`) 실행을 물리적으로 강제 종료하지 않고 `InterventionRequired` 상태로 전환하여 사용자 확인을 요청한다.
- **Mutation Forbidden**: Guardian은 `StepResult` 또는 `GraphState`를 직접 수정(Mutation)할 수 없다. (PRD-007 준수)
- **Registration Policy**: `runValidator` 종속성 주입(DI)으로만 구현한다. `executePlan` 메인 루프의 제어 구조를 수정해서는 안 된다. (Core-Zero-Mod)
- **Atlas Read-Only**: Guardian은 Atlas Index Engine(PRD-026)의 조회 API만 사용 가능하며, Atlas를 직접 갱신하거나 Decision/WorkItem 상태를 직접 변경할 수 없다. (단방향 의존성)

## 2. Guardian Validator 구조
- **Naming**: `validator_id`는 반드시 `"guardian.<rule_name>"` 패턴을 따른다.
- **Versioning**: `validator_version`과 `logic_hash`를 포함하여 검사 로직의 결정론적 재현을 보장한다.
- **Logic Hash**: 검사 알고리즘 소스코드 또는 설정 데이터의 해시값을 사용하여 로직 변경 시 재현성 드리프트를 방지한다.

## 3. 검사 항목 (Detection Rules)
- **ConflictPoint Collision**: 실행 중 수정하려는 Artifact가 Atlas의 `ConflictPoints`에 등록된 위험 지점인지 확인.
- **STRONG/LOCK Decision Contamination**: PRD-025를 통해 Commit하려는 Decision이 기존의 STRONG/LOCK 충돌 강도를 가진 결정과 상충되는지 감지.
- **Contract Integrity**: Atlas의 `Contract` 인덱스를 조회하여 입출력 또는 구조적 제약 조건 위반 여부 검사.

## 4. 리포트 포맷 (Guardian Report)
- **evidenceRefs**: 위반 근거가 되는 Atlas ConflictPoint ID 또는 Decision rootId를 포함한다.
- **Report Body**: 근거 데이터, 위반 라인/지점, 권장 조치(Recommendation), 차단 여부(`is_blocking`)를 포함하는 표준화된 포맷을 제공한다.

## 5. 결정론적 재현 계약
- `logic_hash` + `validator_id` + `Plan Hash`(PRD-012A)를 연동하여 동일 세션 재빌드 시 동일한 Guardian 결과를 산출함을 보장한다.

## 6. PRD-026 Atlas 연동
- **Access Path**: `AtlasQueryAPI`를 통해서만 데이터에 접근한다.
- **Query Types**: `queryConflictPoints()`, `queryContracts()` 등 조회용 API만 호출하며 Write 권한은 배제된다.

## 7. PRD-025 경계
- Guardian은 PRD-025의 `DecisionProposal` 단계에서 개입한다. 
- Atlas DecisionIndex 조회 결과 기존 DecisionIndexEntry.strength가
  `STRONG` 또는 `LOCK`인 Decision과 충돌 가능성이 있을 경우, Guardian은 이를 감지하여
  `BLOCK` 결과를 반환함으로써 자동 Commit을 방지하고 중재(Intervention)를 유도한다.

## 8. 타 PRD 의존관계
| PRD | 역할 | 관계 |
| :--- | :--- | :--- |
| PRD-026 | Atlas Index Engine | 위반 감지용 SSOT 데이터 제공 (Conflict/Contract) |
| PRD-025 | Decision Capture Layer | STRONG/LOCK 충돌 감지 및 중재 대상 제공 |
| PRD-021 | Core Extensibility | Validator 삽입 지점(Execution Hook) 제공 |
| PRD-024 | Structural Safety Seal | HookClass("POLICY") 및 Intervention 전이 경로 제공 |
| PRD-012A | Plan Hash | Guardian 로직 무결성 검증용 해시 연동 |

## 9. Exit Criteria
| # | 조건 | 검증 방법 |
|:--|:--|:--|
| 1 | Execution Hook으로 Guardian 정상 삽입 확인 | `plan_executor_deps.ts` 주입 테스트 |
| 2 | 위반 감지 시 InterventionRequired 생성 확인 | `GraphState.status` 전이 테스트 (Mutation 없음 확인) |
| 3 | Guardian 결과 결정론적 재현 가능 | 동일 `logic_hash` 기반 결과 일치 확인 |
| 4 | Guardian 리포트 Evidence 저장 연동 확인 | SQLite EvidenceStore 기록 대조 |
| 5 | 기존 PRD-001~021 회귀 테스트 통과 | 전체 테스트 스위트 실행 |
| 6 | Guardian 결과와 Plan Hash 연동 기록 확인 | 세션 기록 내 해시 정합성 검증 |

## 10. Out of Scope
- Guardian 로직을 통한 자동 코드 수정 (Mutation 금지 원칙)
- Atlas Index 직접 갱신 (PRD-026 전담)
- WorkItem 상태 전이 직접 트리거 (PRD-025 단방향 의존)
- 실시간 사용자 대화 중재 UX (UI 레이어 영역)
