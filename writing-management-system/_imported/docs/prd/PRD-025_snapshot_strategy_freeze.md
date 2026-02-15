# PRD-025: Snapshot Strategy Freeze (Append-Only)

---

## 1. 목적 (Purpose)

Workspace 저장 구조를 **append-only snapshot 전략**으로 고정한다.

본 PRD는 저장 모델의 철학을 확정하며,
이후 Backup/Restore(PRD-026), Schema Version(PRD-027)의 기반이 된다.

이 PRD는 구조적 방향을 고정하는 **아키텍처 결정 PRD**이다.

---

## 2. 결정 사항 (LOCKED Decisions)

### 2.1 저장 전략

- Save는 **overwrite(덮어쓰기)를 금지**한다.
- Save 시마다 새로운 Snapshot 레코드를 **append** 한다.
- 기존 Snapshot은 수정/삭제하지 않는다. (Immutable)

### 2.2 Workspace 구조

Workspace는 실제 데이터를 직접 보유하지 않는다.

Workspace는 다음을 가진다:

- id
- title
- head_snapshot_id (현재 활성 Snapshot 포인터)
- created_at
- updated_at

### 2.3 Snapshot 구조

Snapshot은 다음을 가진다:

- id
- workspace_id
- created_at
- payload_json (문서/트리/상태 전체)
- schema_version

Snapshot은 생성 이후 수정되지 않는다.

---

## 3. 동작 규칙 (Behavior Rules)

### 3.1 Save 동작

1. 현재 Workspace 상태를 직렬화한다.
2. 새로운 Snapshot을 생성한다.
3. Workspace.head_snapshot_id를 새 Snapshot으로 변경한다.

기존 Snapshot은 변경되지 않는다.

---

### 3.2 Restore (구조 전제)

Restore는 다음 방식만 허용한다:

- 특정 Snapshot을 선택
- Workspace.head_snapshot_id를 해당 Snapshot으로 변경

Snapshot 자체를 수정하는 방식은 금지한다.

---

## 4. 금지 사항 (Prohibited)

- Snapshot UPDATE
- Snapshot DELETE
- Save 시 기존 레코드 overwrite
- Snapshot 직접 편집

Append-only 원칙은 구조적 불변 규칙이다.

---

## 5. 설계 의도 (Intent)

이 전략은 다음을 보장한다:

- 히스토리 보존
- 실수 복구 가능성
- Audit 친화 구조
- 의미 드리프트 방지 기반

본 시스템의 DELTA 기반 철학과 일관성을 유지한다.

---

## 6. Acceptance Criteria

다음 조건을 모두 만족해야 한다:

- Save 실행 시 Snapshot row 수가 증가한다.
- 기존 Snapshot은 변경되지 않는다.
- Workspace는 항상 하나의 head_snapshot_id를 가진다.
- 특정 Snapshot으로 포인터 변경이 가능하다.
- Snapshot에는 schema_version 필드가 존재한다.

---

## 7. 범위 (Scope)

본 PRD는 다음을 포함하지 않는다:

- Backup 파일 포맷
- DB 전체 백업 전략
- Schema Migration 로직

해당 사항은 PRD-026, PRD-027에서 정의한다.

---

## 8. 구조 요약

Append-only Snapshot + Workspace Pointer 모델을
저장 구조의 단일 공식 전략으로 고정한다.

이 결정은 이후 PRD에서 변경되지 않는다.

---

## 9. 기술적 고려 사항 (Non-Scope but Mandatory Constraints)

### 9.1 원자성(Atomicity) 보장 — 필수

Save 동작의 다음 두 단계는 반드시 **단일 데이터베이스 트랜잭션**으로 묶여야 한다:

1. 새로운 Snapshot 생성
2. Workspace.head_snapshot_id 업데이트

두 동작은 분리될 수 없다.

트랜잭션이 보장되지 않을 경우 고립된(Orphan) Snapshot이 발생할 수 있으며,
이는 구조 위반으로 간주한다.

---

### 9.2 스토리지 증가 (GC 정책) — 향후 과제

Append-only 전략은 저장 횟수에 비례하여 스토리지가 증가한다.

Garbage Collection(GC) 정책은 본 PRD 범위에 포함하지 않는다.

단, 장기적으로 다음 중 하나를 선택할 수 있다:

- 일정 개수 이상 Snapshot 아카이빙
- 시간 기준 Snapshot 정리 정책
- 외부 백업 후 로컬 축소 전략

GC는 별도 PRD로 정의한다.

