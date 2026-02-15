# PRD-027: Schema Version / Migration Freeze

---

## 1. 목적 (Purpose)

시스템의 데이터 구조 변경에 대비하여
Schema Version 정책과 Migration 원칙을 고정한다.

본 PRD는 Snapshot(PRD-025) 및 Backup/Restore(PRD-026)의
안전한 진화를 보장하기 위한 상위 구조 규칙이다.

---

## 2. 핵심 결정 사항 (LOCKED Decisions)

### 2.1 schema_version은 필수 필드이다

- 모든 Snapshot은 schema_version을 가진다.
- Backup 파일 최상단에도 schema_version을 포함한다.
- schema_version 없는 데이터는 유효하지 않은 것으로 간주한다.

---

### 2.2 버전 비교는 문자열이 아닌 명시적 정책으로 처리한다

- 단순 문자열 비교로 호환 여부를 판단하지 않는다.
- 시스템은 "지원 가능한 schema_version 목록"을 명시적으로 관리한다.

---

### 2.3 하위 호환 자동 보장은 하지 않는다

- 구버전 Snapshot은 자동으로 실행되지 않는다.
- 명시적 Migration 과정을 거쳐야 한다.

---

## 3. Migration 기본 원칙

### 3.1 Migration은 명시적 단계다

- Migration은 자동 Save 과정에 포함되지 않는다.
- Migration은 명확한 변환 로직을 가진다.

---

### 3.2 Migration은 순차 적용한다

예:

v1 → v2 → v3

직접 v1 → v3로 점프하지 않는다.

각 버전 간 변환 로직은 독립적으로 정의한다.

---

### 3.3 Migration은 원본을 수정하지 않는다

- 기존 Snapshot을 직접 수정하지 않는다.
- Migration 결과는 새로운 Snapshot으로 생성한다.
- append-only 원칙을 유지한다.
- 생성된 Snapshot에는 `migrated_from_snapshot_id` 메타데이터를 포함하여
  어떤 원본 Snapshot으로부터 파생되었는지 추적 가능해야 한다.

Migration 과정 전체는 단일 트랜잭션으로 수행되어야 하며,
실패 시 전체 롤백한다.

---

- 기존 Snapshot을 직접 수정하지 않는다.
- Migration 결과는 새로운 Snapshot으로 생성한다.
- append-only 원칙을 유지한다.

---

## 4. Restore 시 검증 규칙

Restore 과정에서 구버전 데이터가 감지되면:

- 시스템은 해당 데이터가 현재 버전과 직접 호환되지 않음을 명시한다.
- Migration이 필요한 경우, 사용자 승인 절차를 거친다.
- 사용자 승인 없이 자동 Migration을 수행하지 않는다.

(승인 UI 흐름은 상위 UX PRD에서 정의한다.)

---

Restore 시 다음을 수행한다:

1. Backup 파일의 schema_version 확인
2. 현재 시스템 지원 여부 판단
3. 미지원 버전이면 Restore 거부
4. 지원 가능하지만 변환 필요 시 Migration 수행

---

## 5. 금지 사항 (Prohibited)

- schema_version 없는 Snapshot 허용
- Silent Migration (사용자 모르게 변환)
- 기존 Snapshot 직접 수정
- Migration 실패 후 부분 반영

---

## 6. Acceptance Criteria

- 모든 Snapshot에 schema_version 존재
- Backup 파일 최상단에 schema_version 존재
- Migration은 순차 적용된다
- Migration 실패 시 전체 롤백된다
- Migration 결과는 새로운 Snapshot으로 생성된다

---

## 7. 설계 의도 (Intent)

- 장기 운영 가능성 확보
- 데이터 구조 진화 안전성 확보
- 과거 데이터 완전 보존
- Append-only 전략과의 일관성 유지

---

## 8. 구조 요약

Schema Version은 시스템의 진화 경로를 통제하는 장치다.

Migration은 선택이 아니라 통제된 변환 절차이며,
데이터 불변성 원칙을 침해하지 않는다.

