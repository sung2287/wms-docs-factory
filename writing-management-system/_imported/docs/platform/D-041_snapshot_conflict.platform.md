# [D-041] Snapshot Conflict Platform Spec

## 1. API Contract
- **Endpoint**: `POST /workspaces/{id}/sections/{section_id}/save`
- **Request Payload**:
  ```json
  {
    "base_snapshot_id": "UUID",
    "body": "String",
    "writing_status": "Enum",
    "override": boolean
  }
  ```
  - `override`가 `false`인 경우: `base_snapshot_id`는 편집 시작 시점의 ID여야 함.
  - `override`가 `true`인 경우: `base_snapshot_id`는 사용자가 Conflict 화면에서 확인하고 승인한 최신 `head_id`여야 함.

## 2. 반환 타입 (Response Codes)
- **201 Created (Success)**: 저장 성공 및 신규 스냅샷 생성 완료.
- **409 Conflict (Conflict)**: `base_snapshot_id` 불일치 감지. 일반 저장 실패 또는 Override 재검증 실패 포함.
- **400 Bad Request (Error)**: 유효하지 않은 데이터 형식.

## 3. Conflict Response Payload
- **current_head_snapshot_id**: 현재 서버에 저장된 최신 스냅샷 ID.
- **head_summary**: 현재 최신본의 메타데이터 (저장 시간 등).

## 4. Transaction Boundary (Atomic Logic)
엔진은 다음 로직을 단일 데이터베이스 트랜잭션 내에서 수행한다.
```sql
BEGIN;
  -- 1. 현재 head_snapshot_id 잠금 조회 (FOR UPDATE)
  SELECT head_snapshot_id INTO v_current_head FROM nodes WHERE id = :section_id FOR UPDATE;
  
  -- 2. 버전 일치 여부 검증
  -- (Normal Save 또는 Override 요청 시 전달된 base_snapshot_id가 서버의 최신과 같은지 확인)
  IF v_current_head != :base_snapshot_id THEN
    ROLLBACK; RETURN 409_CONFLICT;
  END IF;
  
  -- 3. 신규 Snapshot 및 Snippet 생성
  -- parent_snapshot_id를 v_current_head로 설정하여 계보 유지
  INSERT INTO snapshots (parent_snapshot_id, ...) VALUES (v_current_head, ...);
  INSERT INTO snippets ... ;
  
  -- 4. Node의 head_snapshot_id 업데이트
  UPDATE nodes SET head_snapshot_id = :new_id WHERE id = :section_id;
COMMIT;
```

## 5. Determinism
- 모든 판정은 데이터베이스 트랜잭션의 격리 수준과 `FOR UPDATE` 잠금을 통해 결정론적으로 처리된다.
- 클라이언트는 409 응답을 받을 경우 반드시 최신 상태를 다시 확인해야 한다.

---

## Revision Note (v1.2)
- `override` 플래그를 통한 통합 API 처리 방식 확정.
- 트랜잭션 내부에서 `base_snapshot_id`와 `current_head`를 비교하는 로직을 단일화하여 Override 시의 재검증(Double-check)을 수용함.
