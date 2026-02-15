# PRD-031: Snapshot Retention Policy (Core Only)

---

## 1. 목적 (Purpose)

PRD-025~027에서 확립된 append-only Snapshot 구조와
PRD-028 Snapshot History, PRD-029 Time Travel 기능을 기반으로,
장기 운영 시 Snapshot이 무한 증가하는 문제를 통제하기 위한
Core 레벨 Retention 정책을 정의한다.

이 PRD의 목표는 다음과 같다:

1. Snapshot 보존 범위를 명확히 정의한다.
2. Time Travel 기능과 충돌하지 않는 보존 정책을 수립한다.
3. append-only 철학을 침해하지 않는 GC 전략을 고정한다.
4. 운영 안정성을 확보한다.

---

## 2. 핵심 원칙 (LOCKED Principles)

### 2.1 Retention은 View가 아니라 저장 정책이다

Retention은 UI 정책이 아니다.

- History 화면은 "현재 존재하는 Snapshot"만 표시한다.
- Time Travel은 "현재 DB에 존재하는 Snapshot"만 열람한다.

Retention은 단지 "어떤 Snapshot을 보존할지"를 결정한다.

---

### 2.2 Append-only 철학은 유지된다

Retention은 기존 Snapshot을 수정하지 않는다.

- Snapshot은 여전히 immutable이다.
- 삭제는 개별 row 수정이 아닌, 정책 기반 정리 절차로만 수행된다.
- 삭제는 반드시 명시적 Retention 실행 단위에서만 발생한다.

---

### 2.3 Time Travel 보장 범위는 Retention에 의해 제한된다

Time Travel은 Retention 정책에 의해 제거된 Snapshot에 대해 접근을 보장하지 않는다.

Retention 이후 존재하지 않는 Snapshot은
History 및 Time Travel에서 표시되지 않는다.

---

## 3. Retention 정책 레벨 (v1)

v1에서는 단순 정책만 고정한다.

### 3.1 기본 정책

- 최소 N개의 최신 Snapshot은 항상 보존한다.
- 현재 head Snapshot은 절대 삭제하지 않는다.
- Migration으로 생성된 Snapshot은 일반 Snapshot과 동일하게 취급한다.
- Retention은 반드시 workspace 단위로 계산된다.

N의 기본값은 구현 단계에서 상수로 정의한다.
권장 초기값: 50~100 범위.

---

### 3.2 보호 규칙

다음 Snapshot은 보호 대상이다:

1. 현재 head_snapshot_id
2. 최근 N개 Snapshot
3. (향후 확장) 특정 Tag/Release로 지정된 Snapshot

---

## 4. GC 실행 원칙

### 4.1 자동 실행 금지 (v1)

- Background 자동 GC는 v1 범위에 포함되지 않는다.
- Retention은 명시적 Core 호출에 의해 수행된다.

---

### 4.2 트랜잭션 보장

Retention 수행 시:

1. 삭제 대상 계산 (workspace 단위)
2. 단일 트랜잭션으로 정리
3. 실패 시 전체 롤백

중간 상태가 남아서는 안 된다.

---

### 4.3 Head 안전성 보장

Retention은 다음을 보장해야 한다:

- head_snapshot_id는 항상 유효한 Snapshot을 가리킨다.
- head 이동은 Retention 과정에서 발생하지 않는다.

---

### 4.4 Orphan Snapshot 방지

Retention 로직은 다음을 보장해야 한다:

- 유효하지 않은 workspace_id를 참조하는 Snapshot은 삭제 대상이다.
- 정책 범위를 벗어난 Snapshot은 head로부터 도달 가능 여부와 무관하게 제거된다.
- 삭제 대상 계산은 명확한 WHERE 조건으로 결정되어야 한다.

---

### 4.5 성능 고려 사항

- snapshots 테이블은 (workspace_id, created_at) 기준 인덱스를 권장한다.
- Retention 계산은 created_at 역순 정렬 기반으로 수행한다.
- 대량 삭제 시에도 단일 트랜잭션 범위를 유지한다.

---

### 4.2 트랜잭션 보장

Retention 수행 시:

1. 삭제 대상 계산
2. 단일 트랜잭션으로 정리
3. 실패 시 전체 롤백

중간 상태가 남아서는 안 된다.

---

### 4.3 Head 안전성 보장

Retention은 다음을 보장해야 한다:

- head_snapshot_id는 항상 유효한 Snapshot을 가리킨다.
- head 이동은 Retention 과정에서 발생하지 않는다.

---

## 5. 비범위 (Out of Scope v1)

- Snapshot 압축
- Diff 기반 압축 저장
- 시간 기반 자동 삭제
- Tag/Release 고급 정책
- UI 기반 보존 설정

---

## 6. Acceptance Criteria

1. Retention 실행 후 Snapshot 수가 정책 범위로 감소한다.
2. head_snapshot_id는 변경되지 않는다.
3. 최근 N개 Snapshot은 항상 보존된다.
4. Retention 실패 시 DB 상태는 변경되지 않는다.
5. Time Travel 기능은 Retention 이후에도 정상 동작한다.

---

## 7. 설계 의도 (Intent)

Snapshot은 시스템의 역사다.

Retention은 역사를 부정하는 행위가 아니라,
운영 안정성을 위한 "보존 범위 통제"다.

이 PRD는 무제한 성장 리스크를 제거하면서도
append-only 구조와 Time Travel UX를 보호하기 위한
Core 정책 고정 단계다.

---

## 8. 구조 요약

- Snapshot은 immutable이다.
- Retention은 정책 기반 정리 절차다.
- Head는 항상 보호된다.
- Time Travel은 현재 존재하는 Snapshot만을 대상으로 한다.

PRD-031은 운영 안정성을 위한 Core 통제 장치다.

---

End of PRD-031

