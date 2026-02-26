# PRD-025 — Decision Capture Layer
Status: DESIGN_CONFIRMED
Created: 2026-02-26
Depends On: PRD-026 (CLOSED)

## 0. 개요 및 범위
PRD-025는 대화 Turn에서 Decision을 자동으로 포착하고 WorkItem으로 실행 추적하는 레이어다. VERIFIED 자동 판정은 이 PRD 범위에 포함하지 않는다 — 해당 기능은 PRD-027 범위다.

| 항목 | 내용 |
| :--- | :--- |
| 역할 | 대화 → Decision 자동화 + WorkItem MVP |
| 선행 조건 | PRD-026 CLOSED (Atlas 기반 완성) |
| 제외 범위 | VERIFIED 자동 판정 (PRD-027), Domain Pack Library (PRD-028) |
| 완료 기준 | Exit Criteria 6개 전부 통과 |

## 1. 핵심 설계 원칙 (LOCK)

### 1.1 계층 분리 원칙
세 레이어는 명확히 분리되며 상호 오염을 허용하지 않는다.

| 레이어 | 역할 | 변경 가능성 |
| :--- | :--- | :--- |
| Decision | 의미 SSOT — 결정 본문과 근거 | Immutable (Non-Overwrite, Version Chain) |
| WorkItem | 실행 의도 SSOT — 현재 진행 상태 | Mutable (상태 필드 한정, 예외 선언) |
| Atlas | 파생 인덱스 — 조회 최적화 | Derived (Cycle End 갱신, SSOT 아님) |

**NON-OVERWRITE 예외 선언:** Decision/Evidence에는 Non-Overwrite 원칙이 절대 적용된다. WorkItem의 status 필드는 예외적으로 Mutable을 허용하며, 모든 상태 전이는 work_item_transitions에 append-only로 기록된다. 이 예외는 아키텍처 문서에 명시되며 Decision 레이어로 확대되지 않는다.

### 1.2 의존 방향 (단방향 고정)
의존 흐름은 반드시 단방향으로만 흐른다.
**WorkItem → Decision Commit → (Cycle End) → Atlas Update**

**금지 방향 (아키텍처 위반):**
- Atlas → WorkItem 상태 변경
- Atlas → Decision 자동 변경
- WorkItem → Atlas 직접 갱신

PRD-026 LOCK-C 완전 정합. Guardian(PRD-022) 및 Completion Policy(PRD-027)는 Atlas 조회 결과를 Decision 변경 트리거로 직접 사용할 수 없다.

<!-- ADDED FOR ATLAS MIRRORING DELAY CLARIFICATION -->
<!-- ADDED IN ALIGNMENT WITH EVIDENCE PACK -->
Decision 변경은 Atlas Index에 즉시 반영되지 않는다.
Atlas는 Cycle 종료 시점에만 갱신되며,
Atlas 기반 판단이 Decision 변경을 자동으로 유발하는 구조는 금지된다.

## 2. 스키마 정의

### 2.1 DecisionProposal
대화 Turn에서 자동 생성되는 결정 제안 객체다.

```ts
interface DecisionProposal {
  proposalId:           string;        // UUID v4
  conversationTurnRef:  string;        // 필수 — Exit Criteria 1번
  content:              string;        // 결정 본문
  evidenceRefs:         string[];      // 필수 — 없으면 Commit 거부
  changeReason:         string;        // 필수 — 없으면 Commit 거부
  create_work_item:     boolean;       // default: true
  conflictStrength?:    'NORMAL' | 'STRONG' | 'LOCK';
  createdAt:            string;        // ISO8601
}
```
`create_work_item=false`이면 Decision만 커밋되고 WorkItem 생성 없음. 기록용/아키텍처 선언용 Decision 분리 목적.

### 2.2 work_items 테이블
```sql
CREATE TABLE work_items (
  id                TEXT PRIMARY KEY,
  decision_id       TEXT NOT NULL,      -- decision.id (version UUID) FK 고정
  root_decision_id  TEXT NOT NULL,      -- 조회 편의용 비정규화 (SSOT는 decision_id)
  status            TEXT NOT NULL CHECK (status IN (
    'PROPOSED', 'ANALYZING', 'DESIGN_CONFIRMED',
    'IMPLEMENTING', 'IMPLEMENTED', 'VERIFIED', 'CLOSED'
  )),
  created_at        TEXT NOT NULL,
  updated_at        TEXT NOT NULL,
  locked_by_prd     TEXT,               -- 'PRD-025' | 'PRD-027' (가드 출처 추적)
  FOREIGN KEY (decision_id) REFERENCES decisions(id) ON DELETE RESTRICT -- <!-- ADDED IN MIGRATION -->
);

-- <!-- ADDED FOR HARDENING -->
-- <!-- ADDED FOR QUERY PERFORMANCE -->
CREATE INDEX idx_work_items_decision_id
ON work_items(decision_id);
```
<!-- ADDED IN MIGRATION -->
- **FK 제약 강화:** `decision` 삭제 시 `WorkItem` 고아 방지 (INV-1 강화 목적)

### 2.3 work_item_transitions 테이블
```sql
CREATE TABLE work_item_transitions (
  id                    TEXT PRIMARY KEY,
  work_item_id          TEXT NOT NULL,
  from_status           TEXT,            -- NULL 허용: 최초 생성 시 이전 상태 없음
  to_status             TEXT NOT NULL,
  triggered_by          TEXT NOT NULL,   -- 'USER' | 'SYSTEM' | 'GUARDIAN'
  conversation_turn_ref TEXT,            -- 이벤트 근거 (전이 속성)
  evidence_refs         TEXT,            -- JSON array, nullable
  reason                TEXT,
  created_at            TEXT NOT NULL,
  FOREIGN KEY (work_item_id)
  REFERENCES work_items(id)
  ON DELETE RESTRICT -- <!-- ADDED FOR HARDENING -->
);

-- <!-- ADDED IN MIGRATION -->
-- 상태 이력 조회 성능 보장
CREATE INDEX idx_work_item_transitions_work_item_id ON work_item_transitions(work_item_id);

<!-- ADDED FOR HARDENING -->
- **상태 이력 삭제 방지:** audit 체인 보호 목적
```
`conversation_turn_ref`는 WorkItem의 정적 속성이 아닌 전이 이벤트의 속성이다. 최초 생성 턴과 이후 전이 턴이 다를 수 있으므로 transitions에만 존재한다.

## 3. 상태 전이 가드 (코드 레이어)

### 3.1 PRD-025 허용 전이 목록
| From | To | 조건 |
| :--- | :--- | :--- |
| (없음) | PROPOSED | WorkItem 최초 생성 — Decision Commit과 동시 |
| PROPOSED | ANALYZING | 분석 시작 명시적 트리거 |
| ANALYZING | DESIGN_CONFIRMED | 설계 확정 — PRD-025 terminus |
| DESIGN_CONFIRMED | * | PRD-025에서 도달 불가 — PRD-027 가드로 차단 |

### 3.2 전이 가드 구현 (TypeScript)
```ts
const ALLOWED_TRANSITIONS_PRD025: Record<string, string[]> = {
  PROPOSED:          ['ANALYZING'],
  ANALYZING:         ['DESIGN_CONFIRMED'],
  DESIGN_CONFIRMED:  [],   // PRD-025 terminus
};

const LOCKED_UNTIL_PRD027 = [
  'IMPLEMENTING', 'IMPLEMENTED', 'VERIFIED', 'CLOSED'
];

function assertTransitionAllowed(from: string, to: string): void {
  if (LOCKED_UNTIL_PRD027.includes(to)) {
    throw new Error(`${to} 상태는 PRD-027 이전에 도달 불가능`);
  }
  const allowed = ALLOWED_TRANSITIONS_PRD025[from] ?? [];
  if (!allowed.includes(to)) {
    throw new Error(`${from} → ${to} 전이 불허`);
  }
}
```

## 4. 핵심 실행 흐름

### 4.1 Proposal → Commit → WorkItem 생성 (단일 트랜잭션)
**Decision Commit + WorkItem 생성은 반드시 동일 트랜잭션 내에서 수행된다.** <!-- ADDED IN MIGRATION -->

```
BEGIN TRANSACTION
  ├─ DecisionVersion Commit (createNextVersionAtomically)
  ├─ if (proposal.create_work_item === true):
  │     INSERT work_items (status='PROPOSED', decision_id=version.id)
  │     INSERT work_item_transitions (from=NULL, to='PROPOSED',
  │       triggered_by='USER', conversation_turn_ref=proposal.turnRef)
  └─ COMMIT
  ↓
Cycle End → Atlas Update (PRD-026)
```
WorkItem 생성 실패 시 Decision Commit 롤백. Atlas 갱신은 여전히 Cycle End에서만 수행.

<!-- ADDED FOR PRD-026 FAILURE POLICY ALIGNMENT -->
<!-- ADDED IN ALIGNMENT WITH EVIDENCE PACK -->
Atlas 갱신은 PersistSession 성공 이후 Cycle End에서만 수행된다.
Decision Commit 성공 후 Atlas 갱신 실패가 발생하더라도
Decision 및 WorkItem 트랜잭션은 롤백되지 않는다.
Atlas Stale 상태는 허용되며, Telemetry에 기록된다.

### 4.2 Commit 거부 조건 (Enforcer)
아래 조건 중 하나라도 충족되지 않으면 Commit이 거부된다. Exit Criteria 3번/6번 요건.

| 조건 | 거부 사유 |
| :--- | :--- |
| evidenceRefs 없음 또는 빈 배열 | 근거 없는 결정 Commit 불가 |
| changeReason 없음 또는 빈 문자열 | 변경 이유 없는 Commit 불가 |
| conflictStrength === 'STRONG' | 'LOCK' | Guardian 승인 전 자동 Commit 금지 |
| conversationTurnRef 없음 | 대화 추적 불가 — Proposal 무효 |

### 4.3 DecisionVersion 버전 체인
overwrite 금지. createNextVersionAtomically 기반 append-only 체인.
- 기존 버전 `is_active = 0`으로 비활성화
- 신규 버전 `version+1`, `is_active = 1`로 삽입
- UNIQUE INDEX (root_id) WHERE is_active=1 — DB 레벨 단일 활성 보장
- `WorkItem.decision_id`는 생성 시점의 version UUID에 고정 — 이후 버전 이동 없음

## 5. Exit Criteria (PRD-025)
6개 조건 전부 통과 시 PRD-025 CLOSED.

| # | 종료 조건 | 검증 방법 |
| :--- | :--- | :--- |
| 1 | 대화 Turn에서 DecisionProposal 자동 생성 — conversationTurnRef 포함 필수 | 턴 이벤트 → Proposal 생성 테스트 |
| 2 | 옵션 B 저장 정책 정상 작동 (YES → Committed 전환) | 사용자 승인 플로우 통합 테스트 |
| 3 | evidenceRefs / changeReason 없으면 Commit 거부 | Enforcer 유닛 테스트 |
| 4 | DecisionVersion 새 버전 생성 + active 포인터 이동 (overwrite 금지) | 버전 체인 원자성 테스트 |
| 5 | WorkItem 상태 전이 강제 (PROPOSED→ANALYZING→DESIGN_CONFIRMED, 임의 점프 불가) | 전이 가드 유닛 테스트 |
| 6 | STRONG/LOCK 충돌 시 자동 Commit 금지 (Guardian 이전 SSOT 오염 방지) | 충돌 강도 분류 기반 차단 테스트 |

## 6. 아키텍처 불변 조건 (Invariants)
| ID | 불변 조건 | 위반 시 |
| :--- | :--- | :--- |
| INV-1 | WorkItem.decision_id는 생성 시점 version UUID로 고정 — 이후 변경 불가 | 아키텍처 위반 |
| INV-2 | Decision/Evidence는 Non-Overwrite (버전 체인만 허용) | SEAL-B 위반 |
| INV-3 | WorkItem 상태 전이는 전이 가드 통과 필수 | 상태 SSOT 오염 |
| INV-4 | Atlas는 WorkItem/Decision 변경 트리거 불가 (단방향) | PRD-026 LOCK-C 위반 |
| INV-5 | Commit과 WorkItem 생성은 단일 트랜잭션 경계 | 정합성 깨짐 |
| INV-6 | conversation_turn_ref는 work_item_transitions에만 존재 | 설계 오염 |
| INV-7 | BudgetExceededError는 WorkItem 상태 전이를 트리거하지 않는다. FailFast는 상태머신 외부 계층에서 처리된다. | 상태 SSOT 오염 | <!-- ADDED IN ALIGNMENT WITH EVIDENCE PACK -->

## 7. 후속 PRD 연결 지점
| PRD | 연결 조건 | 비고 |
| :--- | :--- | :--- |
| PRD-022 (Guardian) | ConflictPoints는 PRD-026 Atlas 조회 API에서 가져옴 | 단방향 조회만 허용 |
| PRD-027 (VERIFIED 판정) | IMPLEMENTING→VERIFIED→CLOSED 전이 가드 PRD-027에서 해제 | 코딩 번들 실사용 후 시작 |
| PRD-023 (Retrieval) | Decision Index 데이터 축적 후 전략 고도화 | PRD-025 완료 후 진행 |
| PRD-028 (Domain Pack) | completion_policy 외부화 — Pack 교체로 도메인 전환 | 2번째 도메인 진입 시 |

---
PRD-025 설계 본문 v1.0 | 작성: 2026-02-26 | 선행: PRD-026 CLOSED 필수 | 다음: PRD-022 Guardian 설계 진입
