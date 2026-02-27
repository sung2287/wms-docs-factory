# 🚀 AI Worker OS → Decision Infrastructure 전략 문서

본 문서는 전문가 워커 OS에서 시작하여 AI Decision Infrastructure로 진화하기 위한 단계적 로드맵과, 초기 단계에서 반드시 열어두어야 할 구조적 확장 포인트를 정의한다.

---

# I. 단계별 진화 로드맵

---

## 🟢 Phase 1 — 전문가 워커 OS (Ecosystem Formation)

### 🎯 목표
- 전문가가 자신의 업무 파이프라인을 정의
- Bundle 기반 워커 생성
- 실행 + 개선 루프 형성
- 번들 마켓플레이스 형성
- 플랫폼 수수료 모델 확보

### 🧩 핵심 기능
- 플랜 설계 인터페이스 (업무 단계 정의)
- 단계별 규칙(Decision) 설정
- 도구 연결 (Tool Invocation)
- 실행 채팅 인터페이스
- Bundle 버전 고정(Pinning)

### 💰 수익 모델
- 전문가 구독
- 번들 판매 수수료

### 📌 성공 기준
- 활성 전문가 100명 이상
- 재사용 가능한 번들 다수 생성
- 실제 매출 발생

## 🔒 Phase 1 Structural Forward-Slots (LOCK)

본 섹션은 기능 확장이 아니다.
미래 확장을 위해 [II-3. ExecutionReceipt (Canonical Schema)](#3️⃣-executionreceipt-canonical-schema)에 정의된 확장 슬롯들을 예약 상태로 유지한다.

### 🧩 예약된 확장 포인트 (Reserved)
- **Provenance**: 번들 마켓플레이스 및 공급망 신뢰 체계 대비
- **Policy Snapshot**: 실행 당시 적용된 정책 참조용
- **Computed Risk**: 실행 시점 동적 위험도 계산 결과 저장용
- **Export Redaction**: 외부 감사 연계 시 민감정보 마스킹 프로파일 지정용

LOCK:
Core 로직은 위 확장 필드들을 해석하거나 구현하지 않는다.
단지 Canonical Schema상에서 구조적으로 수용 가능해야 한다.

---

## 🟡 Phase 2 — 검증된 번들의 고도화 및 B2B 확장

### 🎯 목표
- 사고율 낮은 번들 선별
- 고위험 도메인(법률, 회계 등) 패키징
- 기업용 안정화 버전 출시

### 🧩 추가 기능
- 번들 안정성 지표
- Risk 등급 분류
- Stable/Canary 채널 분리
- SLA 기반 배포 모델

### 💰 수익 모델
- 기업용 번들 라이선스
- 도메인별 고가 구독

### 📌 성공 기준
- 기업 고객 확보
- 고급 도메인 번들 상용화

---

## 🔴 Phase 3 — AI Decision Infrastructure (Audit & Evidence Layer)

### 🎯 목표
- AI 의사결정의 증거 계층 확보
- 감사·규제 대응 가능한 인프라 구축
- 소프트웨어 및 피지컬 AI까지 확장

### 🧩 핵심 기능
- Immutable Audit Artifact
- Decision 변경 체인 구조
- Execution Snapshot 체계
- Audit Export Protocol
- Explainability Replay Engine

### 🏛 포지셔닝
- 실행 통제 레이어 위의 "결정 증거 계층"
- 기업 감사/GRC 시스템과 연동 가능한 인프라

### 📌 성공 기준
- 기업 감사 시스템과 연동
- 규제 대응 사례 확보
- 고위험 도메인 적용

---

# II. 최종 단계 진화를 위해 지금 반드시 열어두어야 할 구조

Phase 3 기능을 지금 구현할 필요는 없다.
그러나 구조적으로 불가능해지는 설계를 피해야 한다.

아래는 Phase 1 MVP 단계에서 반드시 포함되어야 할 최소 구조이다.

---

## 1️⃣ Bundle Version 고정 참조
- 모든 워커는 특정 bundle_version에 묶여야 한다.
- bundle_hash를 저장해야 한다.

---

## 2️⃣ Decision Version 객체화
- Decision은 단순 텍스트가 아니라 versioned object여야 한다.
- rootId / versionId / previousVersionId 구조 필요

## 🔒 Evidence Reference Forward Compatibility (LOCK)

Decision은 evidenceRefs?: string[] 필드를 가질 수 있다.
Phase 1에서는 Evidence 본문 저장을 요구하지 않는다.
단지 참조 배열을 수용 가능한 구조로 명시한다.

LOCK:
Core는 Evidence 내용을 해석하지 않는다.
Reference-only 구조를 유지한다.

---

## 3️⃣ ExecutionReceipt (Canonical Schema)

각 실행 단위마다 생성되는 영수증의 정본 스키마이다.
Phase 1에서는 Core 필드만 필수로 사용하며, 나머지는 예약(Reserved) 상태이다.

### Core Fields (Mandatory)
- receiptId: string
- bundle_id: string
- bundle_version: string
- bundle_hash: string
- decision_version_refs: string[]
- input_hash: string
- output_hash: string
- timestamp: ISO8601

### Extension Blocks (Optional/Reserved)
미래 확장을 위해 `extensions` 오브젝트 아래에 도메인별 블록을 예약한다.

- **extensions.provenance**: `{ issuer_id?, build_pipeline_id?, signature_ref? }`
- **extensions.policy**: `{ policy_version_ref?, export_redaction_profile? }`
- **extensions.physical_ai**: `{ sensor_evidence_refs?, device_id?, firmware_version?, safety_state? }`

### Risk Fields Distinction
- **risk_level**: (Bundle/Decision 속성) 설계 시점에 정의된 정적 위험도.
- **computed_risk_level**: (Receipt 속성) 실행 시점에 동적으로 계산된 위험도 결과값.

※ 원문 데이터 전체 저장 불필요
※ 해시 기반 참조 구조 유지

---

## 4️⃣ Export Hook 자리 확보
- exportExecutionReceipt(receiptId) 인터페이스 정의
- 실제 구현은 Phase 3에서 수행

---

# III. 전략 원칙

1. Core는 가볍게 유지한다.
2. 기능은 최소화하되 데이터 뼈대는 미래 확장 가능하도록 설계한다.
3. Phase 3은 옵션이며, 생태계 형성이 우선이다.
4. 확장은 Sidecar/Hook 방식으로 구현한다.
5. 처음부터 인프라처럼 보일 필요는 없다.

---

# IV. 최종 비전

- Phase 1: 전문가 생산성 OS
- Phase 2: 검증된 번들 경제
- Phase 3: AI Decision Evidence Infrastructure

1~2단계 성공만으로도 사업은 성립한다.
3단계는 장기적 전략 옵션이며, 초기 설계에서 그 입구만 열어둔다.

---

# 🧭 Reserved Layer — Multi-Domain Orchestrator (Forward Slot)

본 섹션은 기능 구현이 아니다.
향후 멀티 도메인 자동 라우팅을 위한 구조적 슬롯을 예약한다.

## 역할 정의

- Orchestrator는 **Domain Router**이다.
- 각 Worker의 실행 로직에는 관여하지 않는다.
- Commit/Decision/WorkItem 상태 변경 권한을 가지지 않는다.

## 출력 스키마 (Ephemeral Signal)

Orchestrator는 다음의 일회성 라우팅 신호만 생성할 수 있다:

```json
{
  "selectedDomainId": string,
  "confidence": number,
  "needs_user_confirmation": boolean,
  "reason": string
}
```

이 신호는 영구 저장되지 않으며 SSOT가 아니다.

## 자동/확인 정책

- confidence ≥ threshold → 자동 도메인 전환 가능
- confidence < threshold → 사용자 확인 요청
- STRONG / LOCK 영향 가능성 존재 시 → 자동 전환 금지 (항상 확인)

## 권한 제한 (LOCK)

- Orchestrator는 Decision Commit을 직접 수행할 수 없다.
- WorkItem 생성/상태 전이를 트리거할 수 없다.
- Atlas를 수정할 수 없다.
- Domain Routing 결과는 Enforcer 승인 체계를 우회할 수 없다.

## 설계 타이밍

본 레이어는 PRD-026/025/022/028 완료 이후,
멀티 도메인 Pack 안정화 시점에 구현을 검토한다.

---

## ⚠ Structural Risks & Safeguards (Pre-Implementation)

본 섹션은 Multi-Domain Orchestrator 도입 시 발생 가능한
구조적 리스크와 그에 대한 아키텍처적 방어선을 정의한다.

이 내용은 구현 지침이 아니라,
권한 경계 및 오염 방지 원칙을 선고정하기 위한 선언이다.

---

### 1️⃣ 잘못된 도메인 라우팅 (Misrouting Risk)

**리스크**
- 잘못된 도메인 자동 선택
- 도메인 전환이 사용자 의도와 불일치
- 실행 흐름 왜곡

**Safeguards**
- confidence 기반 전환 정책 (threshold 미만 시 사용자 확인)
- 명시적 하드 트리거 문구 우선 적용
- 도메인 전환은 Ephemeral Signal로만 기록 (SSOT 반영 금지)

---

### 2️⃣ 권한 오염 (Unauthorized Commit Risk)

**리스크**
- Orchestrator가 Decision Commit 또는 WorkItem 상태 전이를 유발
- 자동 저장으로 인한 의미 왜곡

**LOCK**
- Orchestrator는 Commit/WorkItem API에 접근할 수 없다.
- Decision Commit은 기존 Enforcer + 사용자 승인 체계만을 따른다.
- STRONG/LOCK 영향 가능성 존재 시 자동 진행 금지.
- Routing 결과는 영구 상태 변경을 직접 트리거할 수 없다.

---

### 3️⃣ 도메인 컨텍스트 혼합 (Cross-Domain Contamination)

**리스크**
- 서로 다른 도메인의 정책/문맥/근거가 혼합
- Evidence/Decision 참조 오염

**Safeguards**
- 도메인 전환 시 해당 Domain Bundle만 로드
- 이전 도메인 Bundle 자동 Drop
- Evidence/Decision은 domain namespace 기반 격리
- Cross-domain 실행은 항상 명시적 사용자 승인 필요

---

## 🔒 Authority Boundary Principle

Orchestrator는 “선택자(Selector)”이지 “집행자(Executor)”가 아니다.

- Domain Routing은 허용
- Commit Authority는 부여하지 않음
- 상태 전이 권한은 기존 PRD 체계를 유지

이 원칙은 PRD-026/025/022의 엔진 무결성을 침해하지 않는다.

---

## 🚫 Scope Guard

본 패치는 다음을 수행하지 않는다:

- Receipt 본문 저장 확대 금지
- 정책 스냅샷 저장 구현 금지
- 리스크 차단 로직 도입 금지
- 번들 검증/서명 시스템 구현 금지
- Core 내부 로직 변경 금지

이 문서는 오직 "구조적 확장 슬롯 확보" 목적이다.

---

## 📝 Patch Summary (2026-02-25)

### v1.1: Structural Hardening
- Provenance, Policy, Risk 슬롯 초기 예약.
- Decision 구조에 `evidenceRefs` 필드 가용성 명시.

### v1.2: Schema Consolidation & Refinement
- **Canonical Schema 통합**: II-3 섹션에 `ExecutionReceipt` 단일 정본 정의.
- **Extension Block 도입**: `extensions.physical_ai`, `extensions.provenance` 등으로 계층화하여 Sidecar 패턴 최적화.
- **Risk 정의 분리**: 설계 시점(`risk_level`)과 실행 시점(`computed_risk_level`) 속성 명확화.
- **중복 제거**: Phase 1의 슬롯 정의를 II-3 정본 참조 구조로 단순화.

---

*Internal Strategy Draft v1.2 (Hardened & Refined)*

