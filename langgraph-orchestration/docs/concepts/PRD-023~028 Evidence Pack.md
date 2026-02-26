PRD-023~028 Evidence Pack (Repo 조사 기반 요약)
0) 공통 결론 3줄 (SSOT/삽입지점/해시)

Cycle End SSOT는 PersistSession Step: Atlas 갱신/스냅샷 커밋의 기준점은 여기로 고정.

Atlas 저장은 SQLite 신규 테이블이 안전 축: 파일 SSOT는 원자성 깨짐 위험이 큼.

Plan Hash(PRD-012A)와 Atlas Hash는 완전 분리: Atlas 해시를 plan hash 입력에 넣으면 철학/UX 충돌이 큼.

(Exit Criteria 상에서도 PRD-026은 Atlas 4대 인덱스 + cycle 종료 갱신 + budget enforcer + deterministic 재현을 요구함. 

EXIT_CRITERIA_PRD023-028

)

1) 레포 “핵심 코드 지형도” (PRD-023~028 공통으로 건드리게 될 구역)
A. 실행/라이프사이클 (Cycle 시작~종료)

src/core/plan/plan.types.ts : ExecutionPlanV1, GraphState(상태 SSOT) 정의

src/core/plan/plan.executor.ts : executePlan 메인 루프, validators/postValidators 흐름

runtime/orchestrator/run_request.ts : 진입점, 번들 핀 고정, 세션 해시 검증, runGraph 호출

runtime/graph/graph.ts : runGraph, executePlan 래핑

runtime/graph/plan_executor_deps.ts : executePlan에 주입되는 deps 구성

B. 상태 mutation/핵심 Step 실행부

src/core/plan/step.registry.ts : applyPatch 기반 불변 업데이트(상태 누적의 핵심)

src/core/plan/plan.handlers.ts : RepoScan/Retrieval 등 Step executor 구현

C. 해시/핀(결정론)

src/session/execution_plan_hash.ts : computeExecutionPlanHash (plan+policy+metadata → stable stringify → sha)

src/session/stable_stringify.ts : 해시 입력 직렬화 안정화

src/session/bundle_pin.store.ts : bundle pin 저장/로드

(telemetry 기록도 run_request에서 함께 수행되는 것으로 조사됨)

D. 스캔(예산 강제 삽입 후보)

src/plugin/repository/scanner.ts : scanRepository / walkDirectory (실제 FS 순회)

조사 결과: 현재 budget abort 로직은 없음(Abort NONE) → 여기 넣으면 Fail-fast 전파는 설계상 가능.

E. SQLite 저장/버전 체인

src/adapter/storage/sqlite/sqlite.storage.ts : 스키마/테이블 정의(Decision/Evidence 등)

src/adapter/storage/sqlite/sqlite.stores.ts : DecisionStore/EvidenceStore + createNextVersionAtomically(버전 체인 원자성)

조사 결과: root별 active 단일 보장(UNIQUE WHERE is_active=1), 트랜잭션(BEGIN/COMMIT), evidence link(M:N) 구조.

2) PRD별 “구현 시 필요한 근거” 요약
PRD-026 Atlas Index Engine (선행 기반)

Exit Criteria(핵심 6개):

온보딩 시 4대 인덱스 생성

cycle 종료 fingerprint 기반 update + REVALIDATION_REQUIRED 표시

budget enforcer 작동(max_files/max_bytes 차단)

조회 API가 PRD-022/025에서 사용 가능

실행 중 mutate 금지 테스트 보장

동일 레포 + 동일 pin에서 deterministic 해시 재현 

EXIT_CRITERIA_PRD023-028

삽입 지점/금지 지점(조사 결론):

금지: executePlan step loop 도중 / pre-flight validators / plan resolve 시점

후보: PersistSession 기준 post-cycle (가장 SSOT에 붙음), 또는 run_request의 runGraph 직후(단, StepContract 고려)

저장 위치(조사 결론):

repository_snapshots 테이블/메서드는 “정의는 있으나 실사용 흔적 없음(UNUSED/IDLE)”

그래서 Atlas는 신규 atlas_indices 테이블 분리 필요성 HIGH (기존 snapshot 테이블 확장보다 안전)

해시 결합 리스크(조사 결론):

Atlas Snapshot Hash를 plan hash에 포함하면 session hash mismatch가 잦아져 UX 충돌 위험 → 분리 유지가 정답
(문서의 LOCK-D가 이걸 해결하는 방향. 

PRD-026_Atlas_Index_Engine

)

Budget Enforcer 근거:

1순위 삽입: scanner.ts의 walkDirectory 내부(실시간 max_files/max_bytes 체크 후 throw)

상위 전파: executePlan은 에러를 FailFast/CycleFail로 전파 가능한 구조로 조사됨.

PRD-025 Decision Capture Layer + WorkItem + Completion Policy (후행)

(Exit Criteria 요약은 PRD-025 항목 참고: proposal 자동 생성, 옵션 B 저장정책, evidenceRefs/changeReason 없으면 commit 거부, 버전 체인/active 포인터 이동, WorkItem 상태 전이 강제, STRONG/LOCK 충돌 시 자동 commit 금지. 

EXIT_CRITERIA_PRD023-028

)

PRD-025 구현 시 필수로 연결될 레포 포인트

DecisionVersion 체인 생성/active 전환: sqlite.stores.ts의 원자적 버전 생성 로직

Evidence link(M:N): decision_evidence_links (FK 강제)

WorkItem 상태 전이 강제는 PRD-025 범위(향후 PRD-027로 VERIFIED 확장)

PRD-026과의 결합 근거

PRD-025의 commit은 결국 Decision DB를 변경함 → PRD-026의 Decision Index 동기화 입력이 됨.

단, “Decision 변경 → Atlas 갱신 → Atlas 기반 판단 → Decision 자동 변경” 같은 순환 트리거는 금지 (PRD-026 LOCK-C로 방지 방향. 

PRD-026_Atlas_Index_Engine

)

PRD-022 Guardian Enforcement Robot (PRD-026 기반 소비자)

(Exit Criteria 요약: Hook 삽입, 위반 시 InterventionRequired 생성(차단이 아니라 신호), deterministic 재현(logic_hash/signature), Evidence 저장 연동, 회귀 테스트, plan hash 연동 기록. 

EXIT_CRITERIA_PRD023-028

)

PRD-026이 Guardian에 주는 근거

Guardian은 ConflictPoints를 “어디서” 가져와야 함 → PRD-026 ConflictPoints Index 조회 API가 SSOT 제공.

Hook 계약상 StepResult mutation 불가 → Atlas update를 Hook로 하지 않는 게 맞음(조사에서도 Hook 구현 불가 결론).

PRD-023 Retrieval Intelligence Upgrade (PRD-026 완료 후)

(Exit Criteria 요약: 기존 hierarchical 유지, Strategy Port로 교체 가능, semantic/hybrid 최소 1개 + 지표 근거, 로딩 순서 유지(Policy→Structural→Semantic), 선택이 bundle/pin에 고정. 

EXIT_CRITERIA_PRD023-028

)

필수 근거 포인트

Retrieval core 진입: src/core/decision/decision_context.service.ts (context loading/merge)

Strategy 교체: PRD-021 Strategy Port (코드 위치는 레포에 존재)

Atlas는 Retrieval의 “검색 범위 축소/후보 생성”에 쓰되, plan hash에 결합하지 않음.

PRD-027 WorkItem Completion & VERIFIED 판정 (PRD-025 후행)

(Exit Criteria: completion_policy 평가기, auto_verify_allowed=true 자동 VERIFIED, false면 사용자 확인, 상태 전이 강제, 코딩 도메인 실제 케이스 통과. 

EXIT_CRITERIA_PRD023-028

)

필수 근거 포인트

WorkItem 상태 전이 강제(IMPLEMENTED→VERIFIED→CLOSED)

Evidence/Conflict/Contract clear를 completion_policy로 외부화

Atlas(026)가 제공하는 ConflictPoints/Contract 재검증 상태가 VERIFIED 판정 근거로 쓰임.

PRD-028 Domain Pack Library + Pack Validation (2번째 도메인 진입 시)

(Exit Criteria: 스키마 검증, core 수정 없이 교체, 실패 시 로딩 차단, 2개 pack 공존/격리, 버전 관리/pin 유지. 

EXIT_CRITERIA_PRD023-028

)

필수 근거 포인트

scan_budget / allowlist / blocklist / completion_policy 등은 Pack 쪽으로 외부화됨

PRD-026의 Budget Enforcer는 Pack 규칙의 “강제 집행 계층”으로만 동작해야 함.

3) PRD-026 설계 문서에서 이미 확정된 LOCK 요약 (후속 PRD 근거로 중요)

PRD-026 문서에 포함된 핵심 보강 LOCK들:

Atlas는 파생 인덱스(SSOT 아님), 충돌 시 Session/Decision 우선

PersistSession 성공 후 Atlas 갱신 시도, 실패해도 세션 롤백 없음(telemetry 기록)

Decision↔Atlas 순환 트리거 금지

Plan Hash와 Atlas Hash 완전 분리

Snapshot Hash 범위 분리(repoStructureHash/decisionStateHash/compositeHash)

Budget Enforcer는 executePlan 루프 구조 변경 금지 

PRD-026_Atlas_Index_Engine

4) 다음 설계 채팅에서 바로 쓰는 “핵심 논점 체크리스트”

Atlas update는 PersistSession 기준으로 묶는다(SSOT 정렬)

Atlas 저장은 SQLite 신규 테이블로 간다(원자성/정합성)

Plan hash에는 Atlas를 절대 포함하지 않는다

Budget abort는 walkDirectory에서 throw 기반 fail-fast로 한다

repository_snapshots는 현재 UNUSED로 간주하고 설계 의존하지 않는다

PRD-025/027의 VERIFIED 판정 근거는 Atlas(Conflict/Contract 상태) + Evidence로 구성