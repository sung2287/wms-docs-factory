# AI Repository Atlas & Decision Graph Implementation Blueprint

> **⚠️ 기존 내용 삭제 금지**: 아래 본문(0~12)은 기존 설계도를 그대로 보존한다. 본 문서 하단에 **[ADDENDUM]** 섹션으로만 확장 내용을 추가한다.

---

## 0. 목적 (Why This Exists)

특정 작업 유형(예: PRD, 코드 변경 등)마다 전체 Artifact 공간을 전수 스캔하는 구조는 비용 낭비이며 확장 불가능하다.

본 설계의 목적은 다음과 같다:

1. 과거 결정(Decision)을 재사용한다.
2. 핵심 충돌 지점을 미리 구조화한다.
3. 전체 스캔을 "Atlas 조회 + 부분 스캔" 구조로 전환한다.
4. 인간이 잊어도 시스템이 결정 이력을 추적한다.
5. Decision 변경은 덮어쓰기가 아닌 버전 체인으로 기록한다.

이 문서는 특정 도메인에 종속되지 않는 범용 Decision Governance Engine의 설계 문서다.

---

# Atlas 3대 설계 원칙 (오염 방지 최상위 목표)

1. Decision 오염 방지  
   - 애매하면 반드시 사용자에게 묻는다.  
   - STRONG 결정과 충돌 시 자동 확정 금지.  
   - 잘못된 root 덮어쓰기를 구조적으로 차단한다.

2. 비용 최소화  
   - Atlas 조회를 기본 경로로 한다.  
   - 키워드/도메인/Conflict Point로 후보를 축소한다.  
   - fingerprint가 변경되지 않은 근거는 재검증을 생략한다.

3. 점진적 자동화 확장  
   - 엣지케이스는 UPDATE_EXISTING vs NEW_ROOT로 구조화한다.  
   - 반복 패턴은 Rule로 승격한다.  
   - 자동 분류는 안전 임계치를 만족할 때만 확장한다.

---

# 1. 전체 구조 개요

```
User Change Context
      ↓
Atlas Query (Low Cost)
      ↓
Relevant Decisions / Contracts / Conflict Points 추출
      ↓
필요한 Artifact만 부분 스캔
      ↓
충돌 감지 / 추가 질문
      ↓
결정 확정 → Decision Version 업데이트
      ↓
Cycle 종료 시 Atlas 갱신
```

핵심 원칙:
- Atlas는 SSOT 인덱스
- 전체 Artifact 공간은 필요할 때만 읽는다
- Decision은 immutable version chain

---

# 2. 핵심 구성 요소

## 2.0 Domain Pack 교체 구조 (범용화 핵심)

본 설계는 특정 산업이나 도메인에 종속되지 않는다.

원칙:
- Core(엔진)는 고정
- 도메인별로 달라지는 요소는 Domain Pack(외부 설정)으로 교체
- 새로운 데이터 소스가 필요할 때만 Adapter(플러그인) 코드를 추가

즉, 새 도메인 추가는 원칙적으로 "대형 공사"가 아니라:

1) Domain Pack 추가/교체 (설정 파일)
2) 필요 시 Adapter만 추가 (입력/출력 커넥터)

로 끝나야 한다.

Domain Pack으로 외부화되는 항목:
- Evidence 타입/권위 정책
- Taxonomy(분류 체계)
- Conflict Point 정의 및 위험도
- Drift 트리거 및 사용자 확인 강제 조건
- Edge-case Learning Loop 규칙

Adapter로만 처리해야 하는 항목:
- 새로운 Evidence 소스 연동
- 특정 포맷 파서

---

## 2.1 Decision Graph

### Decision (논리적 동일 결정의 루트)

- rootId
- domain (generic taxonomy 기반)
- title
- currentVersionId

### DecisionVersion (실제 상태)

- versionId
- rootId
- prevVersionId
- statement
- strength (WEAK / MEDIUM / STRONG)
- changedBy (HUMAN / SYSTEM)
- changeReason
- createdAt
- isActive

결정 변경은 "새 version 생성 + active 포인터 이동"으로 처리한다.
기존 버전은 삭제하지 않는다.

---

## 2.2 Evidence

Evidence는 Decision의 근거 조각이다.

필드:
- evidenceId
- type (도메인 팩에서 정의)
- pointer (artifact 위치)
- fingerprint (변경 감지용)
- note

하나의 DecisionVersion은 여러 Evidence를 참조할 수 있다.

---

## 2.3 Atlas (범용 Artifact 인덱스)

Atlas는 특정 레포에 한정되지 않는 Artifact 공간의 인덱스다.

### A. Structure Index
- Artifact layer 구분
- 주요 entry point

### B. Contract Index
- 변경 시 재검증이 필요한 상위 규칙

### C. Decision Index
- 핵심 결정 목록
- domain 태그

### D. Conflict Points Index
- 자주 충돌하는 영역 정의
- 관련 Decision 및 Artifact 연결

---

# 3. Change Cycle 시작 시 동작 알고리즘

## Step 1. Change Context 분석
- 키워드 추출
- domain 후보 추출

## Step 2. Atlas 조회
- 관련 Decision
- Contract Lock
- Conflict Points

## Step 3. 충돌 후보 계산
- 기존 Decision과 의미 비교
- 충돌 가능 시 사용자 확인

## Step 4. 부분 스캔
- Atlas에 등록된 Artifact만 읽음
- fingerprint 변경 없으면 재검증 생략

## Step 5. 질문 최소화
- 확정된 결정은 재질문하지 않음
- 불확실 영역만 질문

---

# 4. Decision Strength 정책

기본 정책은 Domain Pack에서 정의한다.

충돌 시:
- STRONG vs WEAK → 경고 및 확인
- STRONG vs STRONG → 명시적 변경 승인 요구

---

# 5. Drift 감지 로직

Drift 트리거:
1. Change Context가 기존 Decision과 충돌
2. Evidence fingerprint 변경
3. Contract 변경 시도

동작:
- 기존 Decision 요약 표시
- 사용자 확인
- 버전 체인 업데이트

---

# 6. Atlas 갱신 규칙

Cycle 종료 시:
1. 생성/변경된 Decision 기록
2. 관련 Artifact fingerprint 저장
3. Conflict Point 갱신
4. Structure Index 갱신

## 6.1 Artifact 변경 대응

- fingerprint 변경 시 REVALIDATION_REQUIRED
- STRONG Evidence 변경 시 재검증 승격
- 변경 없는 Artifact는 재검증 생략

Atlas는 JSON SSOT + Markdown 렌더 구조로 관리된다.

---

# 7. Phase Plan

## Phase 1
- Decision version chain
- Evidence 연결
- Atlas 조회
- Drift 질문

## Phase 2
- Conflict Point 인덱스
- Fingerprint 기반 부분 스캔
- Atlas 자동 생성

## Phase 3
- Semantic 충돌 탐지
- 위험 등급 계산
- 그래프 시각화

---

# 8. 기대 효과

1. 전수 스캔 제거
2. 질문 최소화
3. 인간 기억 의존 감소
4. 감사 가능 구조 확보
5. 도메인 교체 가능 구조 확보

---

# 9. 현실적 한계

- Atlas는 stale 가능 → fingerprint 필수
- 전수 감사는 필요할 수 있음
- 분류 오판 가능 → 사용자 확인으로 방지

---

# 10. Edge-case Learning Loop

자동 분류는 사용자 판단 데이터를 축적하여 확장된다.

- 애매하면 묻는다
- resolutionType 저장
- 반복 시 Rule 승격
- 안전 임계치 하에서만 자동 확정

---

# 11. 도메인 예시: 코딩을 하나의 Bundle로 구현하는 경우

코딩 도메인은 이 엔진 위에 올릴 수 있는 하나의 Domain Pack 예시일 뿐이다.

예:
- Artifact 공간 = Git Repository
- Evidence = 코드/테스트/문서/커밋
- Conflict Points = 세션 스키마, 오버라이드 계산, 정책 위반 등

이 경우 기존 PRD/레포 개념은 단지 하나의 구현 번들(Bundle #1)이며,
본 Atlas 엔진은 그 상위에 위치하는 범용 Decision Governance Layer다.

---

# 12. 최종 결론

AI Repository Atlas는

"전체 Artifact 공간을 매번 읽는 구조"를
"결정 그래프 + 인덱스 조회 + 부분 스캔" 구조로 전환한다.

이것은 특정 산업 전용 도구가 아니라,
복잡한 의사결정이 누적되는 모든 시스템을 위한
범용 Governance Engine이다.

AI Repository Atlas는

"레포 전체를 매번 읽는 구조"를
"결정 그래프 + 인덱스 조회 + 부분 스캔" 구조로 전환한다.

이 설계는

- Decision/Evidence 아키텍처
- PRD 사이클
- Sandbox/Core 승격 구조

와 완전히 정합적이다.

이것은 단순 메모 시스템이 아니라,

정책 기반 오케스트레이션 플랫폼의 필수 인프라다.

---

# [ADDENDUM] LLM이 판단하고, 코드가 실행/강제하는 구조 (2026-02-26 추가)

> 목표: **사용자 질문 이해·관련 범위 선택은 LLM이 담당**하고, **실행·제약·오염 방지는 코드가 담당**한다.
> 즉, “판단(Plan)과 집행(Enforce)을 분리”하여 커버리지를 확보하면서도 Atlas 오염을 방지한다.

## A. 역할 분리: Planner(LLM) vs Enforcer(Core)

### A-1) LLM (Planner)
- 사용자 입력을 해석하여 Change Context를 의미적으로 분류한다.
- Atlas 인덱스를 읽고 관련 Decision/Contract/Conflict Point 후보를 선택한다.
- 추가 확인이 필요한 경우 “부분 스캔 요청(artifact_requests)”을 만든다.
- 불확실하거나 STRONG 충돌 가능성이 있으면 사용자 질문을 생성한다.

### A-2) 코드 (Enforcer)
- LLM이 제안한 계획을 **도메인 팩 정책**과 **예산/화이트리스트**로 검증한다.
- 허용된 범위 내에서만 부분 스캔(검색/파일읽기)을 실행한다.
- fingerprint 기반으로 “변경 없음 → 재검증 생략”을 강제한다.
- Decision 업데이트는 “버전 체인 규칙”과 “근거 필수”를 강제한다.

**핵심:** LLM은 *실행 권한*이 없고, 코드는 *판단*을 하지 않는다.

---

## B. Domain Pack 외부화: Change Type / Risk Policy

Change Type(변경 유형)은 도메인마다 다르므로 Core에 하드코딩 금지.
Domain Pack이 다음 항목을 제공한다.

### B-1) change_types (예시)
- id: feature / refactor / bugfix / doc_update …
- risk_level: low|medium|high
- requires_conflict_scan: boolean
- requires_contract_scan: boolean
- scan_budget:
  - max_files
  - max_bytes
  - max_hops (Conflict Point 확장 깊이)

### B-2) conflict_policy (예시)
- STRONG vs STRONG 충돌 시 사용자 승인 필수
- STRONG 관련 Evidence fingerprint 변경 시 재검증 승격
- 특정 Conflict Point는 “항상 질문” 트리거

**의미:** LLM은 “이건 refactor 같다”라고 분류하고, 코드는 Domain Pack에 정의된 규칙으로만 실행을 허용한다.

---

## C. LLM 출력 표준: Query Plan (구조화 산출물)

LLM은 Atlas 인덱스(요약본) + Change Context를 보고 아래 JSON 형태의 Query Plan을 반환한다.
(스키마는 최소 필수만 정의하고, 도메인 확장은 Domain Pack에서 추가 필드로 허용)

### C-1) QueryPlanV1 (최소)
- change_type_id: string
- domain: string
- decision_candidates: string[] (rootId 또는 tag)
- contract_candidates: string[] (contractId 또는 index key)
- conflict_points: string[] (conflictPointId)
- artifact_requests: Array<{ pointer: string; reason: string; required: boolean }>
- questions_for_user: Array<{ question: string; why: string; blocks_progress: boolean }>
- risk_notes: string[]

**원칙:** LLM은 “무엇을 보고 싶다(artifact_requests)”까지만 말한다. 실제 읽기는 Enforcer가 수행한다.

---

## D. 실행 강제: Enforcer Guardrails (Core)

Enforcer는 Query Plan을 받아 아래를 수행한다.

### D-1) 검증(Validate)
- change_type_id가 Domain Pack에 존재하는지
- artifact_requests가 허용된 pointer 규칙/루트 경로/파일 타입인지
- scan_budget을 초과하지 않는지

### D-2) 실행(Execute)
- Atlas 조회 결과 + 요청된 pointer만 부분 스캔
- fingerprint가 동일하면 재검증 생략

### D-3) 오염 방지(Protect)
- STRONG 충돌 감지 시 자동 확정 금지
- questions_for_user 중 blocks_progress=true가 존재하면 “확정 전 진행 금지”
- Decision 업데이트는 다음 조건 없으면 거부:
  - changeReason
  - evidenceRefs(최소 1개)

---

## E. 서브에이전트(검색/확인) 호출 규칙

서브에이전트는 “LLM이 요청했다”만으로 호출되지 않는다.
Enforcer가 아래 조건을 만족할 때만 호출한다.

- Query Plan이 required=true로 표시한 artifact_requests
- Conflict Point가 “확인 필요”로 판단된 경우
- fingerprint 변경으로 REVALIDATION_REQUIRED가 발생한 경우

서브에이전트 결과는 Evidence로 저장 가능하며, Decision 변경의 근거로만 사용한다.

---

## F. 구현 단계와의 연결 (설계 ↔ 구현 ↔ 완료)

Atlas는 “설계까지만”이 아니라, 제품 기능으로서 다음 상태를 추적할 수 있다.

### F-1) 최소 확장: DecisionVersion 상태 필드(권장)
- status: DRAFT | APPROVED | IMPLEMENTED | VERIFIED

### F-2) Evidence로 완료 근거 연결
- 테스트 결과(요약)
- 변경된 파일 fingerprint
- 관련 커밋/PR 포인터

**의미:** 코딩 단계에서 변경이 발생할 때마다 동일한 Atlas 루프(조회→부분스캔→충돌질문→업데이트)가 반복되고, 최종적으로 VERIFIED로 닫힌다.

---

## G. 최종 요약

- “무엇을 볼지”는 LLM이 Atlas 맵을 보고 판단한다.
- “진짜로 읽고 실행하는 것”은 코드가 Domain Pack 규칙으로만 수행한다.
- 변경 유형/위험도/스캔 예산/질문 강제 조건은 Domain Pack에서 외부화한다.
- 이 구조는 Atlas의 3대 원칙(오염 방지/비용 최소화/점진적 자동화)을 그대로 유지한다.

---

# [ADDENDUM-2] WorkItem(작업 단위) 및 완료 판정 구조 (제품 완성형 확장)

> 목적: “설계 → 구현 → 검증 → 완료”까지 하나의 흐름으로 닫히는 사용자 경험을 제공하기 위함.
> Decision은 ‘의미 SSOT’, WorkItem은 ‘진행 상태 SSOT’로 분리한다.

## 1. WorkItem 엔티티 (권장 최소 스키마)

WorkItem은 PRD/기능/변경 요청 단위의 진행 상태를 추적한다.
Decision과 역할이 다르며, 반드시 분리한다.

### 1-1) WorkItem
- workId
- title
- domain
- change_type_id
- status (PROPOSED | ANALYZING | DESIGN_CONFIRMED | IMPLEMENTING | IMPLEMENTED | VERIFIED | CLOSED)
- linkedDecisionRootIds: string[]
- relatedArtifacts: string[]
- createdAt
- updatedAt

원칙:
- WorkItem은 진행 흐름을 추적한다.
- Decision은 의미와 정책을 추적한다.
- WorkItem은 Decision을 참조만 한다.

---

## 2. WorkItem 상태 전이 규칙 (기본 흐름)

1) PROPOSED
   - 사용자 요청 입력

2) ANALYZING
   - Atlas 조회
   - QueryPlan 생성
   - 필요한 질문 도출

3) DESIGN_CONFIRMED
   - 사용자 질문 응답 완료
   - Decision version 확정

4) IMPLEMENTING
   - 코드/Artifact 변경 시작

5) IMPLEMENTED
   - 변경 완료
   - Evidence 수집 완료

6) VERIFIED
   - completion_policy 조건 만족
   - Conflict/Drift 없음 확인

7) CLOSED
   - 장기 보관 상태

상태 전이는 Core가 임의로 점프할 수 없다.
Domain Pack의 completion_policy와 Drift 조건을 만족해야 한다.

---

## 3. Domain Pack: completion_policy (완료 판정 외부화)

완료 기준은 도메인마다 다르므로 Core에 하드코딩 금지.
Domain Pack이 다음 항목을 정의한다.

### 3-1) completion_policy (예시: 코딩 도메인)
- requires_test_evidence: boolean
- requires_contract_validation: boolean
- requires_conflict_clearance: boolean
- required_evidence_types: string[]
- auto_verify_allowed: boolean

### 3-2) 예시 동작

코딩 도메인이라면:
- 테스트 PASS Evidence 존재
- 관련 파일 fingerprint 최신
- STRONG Conflict 없음
- Contract Lock 위반 없음

위 조건을 모두 만족하면 → VERIFIED

자동 VERIFY는 auto_verify_allowed가 true일 때만 가능.
그 외에는 사용자 확인 필요.

---

## 4. 설계 ↔ 구현 ↔ Atlas 루프 통합

WorkItem은 Atlas 루프와 완전히 통합된다.

설계 단계:
- Atlas 조회
- Decision 확정
- WorkItem → DESIGN_CONFIRMED

구현 단계:
- Artifact 변경
- fingerprint 비교
- Drift 감지
- 필요 시 질문
- WorkItem → IMPLEMENTED

검증 단계:
- completion_policy 평가
- 조건 충족 시 → VERIFIED

모든 상태 변화는 Evidence를 동반해야 한다.

---

## 5. 핵심 분리 원칙 (중요)

- Decision = “무엇이 맞는가”의 기록
- WorkItem = “어디까지 진행됐는가”의 기록
- Atlas = “무엇을 확인해야 하는가”의 인덱스
- LLM = 판단(Plan)
- Core = 집행/제약(Enforce)

이 분리가 유지되어야 제품이 오염되지 않는다.

---

## 6. 최종 구조 요약 (제품 완성형)

Meta Factory 내부 구조는 다음과 같이 정리된다:

- Runtime (Executor)
- Memory (Decision SSOT)
- Atlas (Change Governance Engine)
- WorkItem Manager (진행 상태 추적)
- Domain Pack (정책/완료 기준 외부화)

이 구조를 구현하면:

✔ 설계 단계에서 자동 충돌 탐지  
✔ 구현 단계에서 Drift 감지  
✔ Evidence 기반 완료 판정  
✔ 도메인 교체 시 코드 수정 최소화  
✔ 전수 스캔 제거

네가 설명한 “설계부터 완료까지 맞물려 돌아가는 그림”이 완성된다.

---

# [ADDENDUM-3] Decision Capture Layer (Conversation → DecisionProposal → Commit)

> 목적: 대화에서 자연스럽게 나온 수정 지시/규칙을 **자동 감지**하고, 오염 없이 **DecisionVersion으로 안전하게 반영**한다.
> 원칙: **감지는 LLM(Planner), 집행/저장은 코드(Enforcer)**.

## 0. 레이어 삽입 위치 (기존 루프 무손상)

```
Conversation Turn
  → Decision Capture Layer   ← (추가)
  → Change Context (풍부해짐)
  → Atlas Query
  → ... (기존 루프 그대로)
```

Core 수정 없이, 기존 Atlas 루프의 “앞단”에 레이어 1개만 삽입한다.

---

## 1. 3단계 오염 방지 필터: Candidate → Proposed → Committed

### 1-1) Candidate
- 대화에서 “앞으로 반복 적용될 가능성이 있는 규칙/설정/계약” 후보를 감지한 상태
- 브레인스토밍/일회성 지시는 여기에서 최대한 걸러진다

### 1-2) Proposed (DecisionProposal)
- Candidate를 DecisionVersion 형태로 구조화한 **제안본**
- 아직 저장되지 않음

### 1-3) Committed
- Enforcer(코드)가 Domain Pack 정책을 통과시키고 버전 체인 규칙으로 저장한 상태

이 3단계는 Atlas 3대 원칙의 “Decision 오염 방지”를 직접 구현하는 필터다.

---

## 2. LLM 산출물 표준: DecisionProposalV1 (최소)

LLM은 매 턴(또는 조건 충족 시) 아래 구조로 “저장 후보”를 제안한다.

- proposalId
- domain
- change_type_id (Domain Pack 기반)
- action: CREATE_NEW_ROOT | UPDATE_EXISTING_ROOT
- targetRootId?: string
- title
- statement (DecisionVersion.statement 초안)
- strength: axis | lock | normal  (또는 WEAK/MEDIUM/STRONG — Domain Pack에서 매핑)
- scope: global | domain
- evidenceRefs: string[]  (최소 1개 필수)
- changeReason
- confidence: low | medium | high
- requires_user_confirmation: boolean

### 2-1) evidenceRefs 포맷 명시 (미래 구현 슬롯 예약)

evidenceRefs는 다음 두 타입 중 하나 이상을 반드시 포함해야 한다.

1) conversationTurnRef  
   - 형식: `conversation:<conversationId>:<turnId>`  
   - 예: `conversation:main:turn-042`  
   - 의미: 해당 DecisionProposal이 근거로 삼은 대화 발화를 정확히 가리키는 포인터  
   - 최소 슬롯 예약 필드:
     - conversationId
     - turnId

2) artifactRef  
   - 형식: `artifact:<artifactId or path>#<optional-fragment>`  
   - 예: `artifact:repo:/docs/contract.md#L120-L148`

원칙:
- 최소 1개 이상의 conversationTurnRef 또는 artifactRef가 존재해야 Commit 가능
- conversationTurnRef는 “대화의 어느 발화를 어떻게 참조하는가”의 모호성을 제거하기 위한 명시적 슬롯이다.
- 실제 conversationId/turnId 생성 방식은 런타임 구현 세부에 위임하되, 스키마 수준에서는 반드시 예약한다.

원칙:
- LLM은 “결정 내용/근거/의도”만 제안한다.
- 실제 저장과 버전 체인 집행은 Enforcer가 수행한다.

---

## 3. 저장 정책 (옵션 A/B/C) — Domain Pack으로 외부화

### A) Explicit-only (가장 보수)
- 사용자가 명시적으로 “저장해/고정해/룰로 박아”를 말한 경우에만 Commit

### B) Auto-detect + Ask-to-commit (기본값, 추천)
- LLM이 Proposal을 만들면 Enforcer가 **저장 제안**을 사용자에게 표시
- 사용자가 YES면 Commit

### C) Conditional Auto-commit (고급 옵션)
- Domain Pack에서 정의한 조건을 만족할 때만 자동 Commit
- 예: normal 강도 + 반복 패턴 + confidence=high + conflict 없음

권장 롤아웃:
- 초기 MVP: **B만** 구현
- 데이터/신뢰도 축적 후: **B + C**로 확장

---

## 4. Enforcer(코드) 강제 규칙

Enforcer는 DecisionProposal을 받아 다음을 강제한다.

### 4-1) 정책 검증
- change_type_id가 Domain Pack에 존재해야 함
- strength/auto-commit 허용 여부는 Domain Pack 정책을 따라야 함

### 4-2) 오염 방지
- STRONG(또는 lock/axis) 충돌 가능성 있으면 자동 확정 금지
- requires_user_confirmation=true면 반드시 사용자 확인

### 4-3) 저장 집행
- DecisionVersion은 반드시 “새 version 생성 + active 포인터 이동”
- evidenceRefs 없으면 저장 거부
- changeReason 없으면 저장 거부

---

## 5. Atlas/WorkItem과의 결합

- Decision Capture Layer의 Proposal은 **Atlas Query 입력(Change Context)을 풍부하게 만든다**.
- WorkItem이 존재하면, Proposal을 해당 WorkItem에 링크하고:
  - 설계 확정 시점에 Committed로 전환
  - 구현/검증 Evidence가 쌓이면 VERIFIED로 진행

---

## 6. 최종 효과

- 사용자가 매번 “이걸 규칙으로 저장해”라고 말하지 않아도,
  시스템이 자연어 대화에서 규칙 후보를 자동 감지한다.
- 그러나 자동 저장이 기본값이 아니므로(옵션 B), 오염 위험을 통제한다.
- Planner/Enforcer 분리 원칙을 그대로 유지하면서 “대화→결정→저장” 흐름이 명시적으로 완성된다.

