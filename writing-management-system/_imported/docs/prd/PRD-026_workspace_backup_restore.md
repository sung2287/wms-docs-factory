# PRD-026: Workspace Backup / Restore v1

---

## 1. 목적 (Purpose)

Workspace 단위의 Backup / Restore 기능을 정의한다.

본 PRD는 DB 전체 백업이 아닌, **단일 Workspace의 Export / Import** 기능만을 범위로 한다.

Snapshot 전략(PRD-025: append-only)을 전제로 한다.

---

## 2. 범위 (Scope)

### 포함

- Workspace 1개 Export
- Workspace 1개 Import
- JSON 파일 기반 백업
- Snapshot 전체 포함 구조

### 제외

- DB 전체 백업
- 다중 Workspace 묶음 백업
- 압축/암호화
- 자동 GC
- Schema Migration 로직

---

## 3. Backup (Export) 규칙

### 3.1 단위

- Export 단위는 Workspace 1개

### 3.2 Export 파일 형식

단일 JSON 파일로 생성한다.

### 3.3 Export 파일 구조 (v1 최소 구조)

```
{
  "schema_version": "string",
  "exported_at": "ISO timestamp",
  "workspace": {
    "id": "string",
    "title": "string",
    "created_at": "ISO timestamp"
  },
  "snapshots": [
    {
      "id": "string",
      "created_at": "ISO timestamp",
      "payload_json": { ... },
      "schema_version": "string"
    }
  ]
}
```

### 3.4 Export 규칙

- Workspace에 속한 모든 Snapshot을 포함한다.
- Snapshot은 append-only 순서를 유지한다.
- head_snapshot_id는 snapshots 배열 중 하나여야 한다.

---

## 4. Restore (Import) 규칙

### 4.1 기본 원칙

- Restore는 기존 Workspace를 덮어쓰지 않는다.
- Import 시 **새로운 Workspace를 생성**하는 것을 기본값으로 한다.

### 4.2 Import 동작

1. Backup JSON 검증
2. schema_version 확인
3. 새로운 Workspace 생성
4. Snapshot 전체 복원 (append-only 유지)
5. head_snapshot_id 설정

### 4.3 금지 사항

- 기존 Workspace overwrite
- Snapshot 수정 후 삽입
- schema_version 불일치 무시

---

## 5. schema_version 정책

- Export 파일 최상단에 schema_version 필드를 반드시 포함한다.
- Snapshot 내부에도 schema_version을 유지한다.
- schema_version이 현재 시스템과 호환되지 않으면 Restore를 거부한다.

Migration 로직은 PRD-027에서 정의한다.

---

## 6. 안전성 규칙 (Safety Rules)

- Restore는 트랜잭션으로 수행한다.
- Snapshot 복원 중 실패 시 전체 롤백한다.
- Partial Import는 허용하지 않는다.

---

## 7. Acceptance Criteria

- Workspace 1개를 JSON 파일로 Export 가능하다.
- Export 파일을 기반으로 새로운 Workspace 생성 가능하다.
- Snapshot 수와 순서가 원본과 동일하다.
- head_snapshot_id가 정상 설정된다.
- schema_version 불일치 시 Import가 거부된다.

---

## 8. 설계 의도 (Intent)

- 사용자 데이터의 이동 가능성 보장
- 단일 Workspace 단위의 안전한 복구
- Snapshot append-only 전략과 구조 일관성 유지
- 향후 Time Travel 기능 확장의 기반 확보

---

## 9. 구조 요약

Workspace 단위 Export / Import를 공식 백업 전략으로 고정한다.

Overwrite Restore는 v1에서 금지한다.

---

## 10. 구현 고려 사항 (Non-Scope but Required Handling)

### 10.1 ID 충돌 방지 — 필수

Import 시 Snapshot ID와 Workspace ID는
기존 DB와 충돌할 수 있다.

따라서 v1에서는 다음을 강제한다:

- Import 시 새로운 Workspace ID를 생성한다.
- 모든 Snapshot ID도 신규 생성한다.
- 기존 ID는 내부 매핑 테이블을 통해 변환한다.

기존 ID를 그대로 사용하는 방식은 허용하지 않는다.

---

### 10.2 대용량 파일 처리 — 향후 개선 대상

Snapshot 수가 많을 경우 Export JSON 파일 크기가 커질 수 있다.

v1에서는 단일 JSON 파일 전략을 유지한다.

단, 구현 시 다음을 고려한다:

- 스트리밍 파싱 가능 구조 유지
- 향후 압축(zip) 또는 분할 전략 확장 가능성 확보

압축/분할 기능은 v2 범위로 한다.

