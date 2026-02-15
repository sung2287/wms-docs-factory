# PRD-028: Snapshot History / Time Travel v1

---

## 1. 목적 (Purpose)

PRD-025~027에서 확립된 append-only Snapshot 구조를
사용자가 직접 확인하고 활용할 수 있도록
별도의 Snapshot History 화면을 제공한다.

이 PRD의 목표는 다음과 같다:

1. Snapshot 목록을 조회할 수 있다.
2. 특정 Snapshot을 read-only로 미리보기 할 수 있다.
3. Preview → Confirm → Restore 흐름을 제공한다.
4. Restore는 append-only 원칙을 유지한다.

---

## 2. 화면 구조 (Route & Layout)

### 2.1 Route

```
/workspace/:id/history
```

### 2.2 Layout

좌측 패널:
- Snapshot 리스트 (시간 역순 정렬)
- snapshot_id
- created_at
- schema_version
- Snapshot origin label (Save / Restore)
- 현재 head 명확히 강조 표시 (badge 또는 highlight)

우측 패널:
- 선택 Snapshot의 read-only 미리보기
- "이 상태로 복구" 버튼

---

## 3. 기능 범위 (Scope v1)

### 포함

- Snapshot 목록 조회 API (Pagination 지원 권장)
- Snapshot 단건 조회 API
- Read-only 렌더링
- Restore 버튼 (Confirm 모달 포함)
- 현재 head 표시
- 현재 head 표시

### 제외

- Snapshot diff 비교
- Snapshot 간 비교 기능
- Tag / Release 기능
- GC 정책
- 자동 복구

---

## 4. Restore 흐름 (Preview → Confirm → Restore)

### Step 1: Snapshot 선택

- Snapshot 클릭 시 우측 패널에 read-only 렌더
- 상단에 "과거 상태 열람 중" 배너 표시
- 저장 버튼 비활성화

### Step 2: Restore 버튼 클릭

모달 표시:

"이 Snapshot으로 Workspace를 복구하시겠습니까?"

"현재 상태는 새로운 Snapshot으로 보존됩니다."

옵션:
- Cancel
- Confirm Restore

### Step 3: Confirm Restore

동작:

1. 선택 Snapshot을 기반으로 새로운 Snapshot 생성
2. 새로운 Snapshot INSERT
3. Workspace.head_snapshot_id를 새 Snapshot으로 업데이트
4. Snapshot count 증가
5. History 화면에서 새 head 강조 표시

Restore는 단일 트랜잭션으로 수행되어야 하며,
실패 시 어떠한 상태 변화도 발생해서는 안 된다.

기존 Snapshot 수정 없음.

---

## 5. 데이터 동작 원칙

- Restore는 과거로 "되돌아가는" 것이 아니라
  과거 상태를 현재로 "재확정"하는 행위다.
- append-only 원칙을 침해하지 않는다.
- 모든 Snapshot은 immutable이다.

---

## 6. UX 원칙

1. 현재 head는 항상 명확히 강조 표시한다.
2. 과거 Snapshot은 read-only 상태임을 시각적으로 구분한다.
3. Restore는 반드시 2단계 확인 절차를 거친다.
4. Restore 후에도 이전 Snapshot들은 그대로 유지된다.

---

## 7. Acceptance Criteria

1. Snapshot 목록이 시간 역순으로 정상 표시된다.
2. Snapshot 선택 시 read-only 렌더가 정확히 표시된다.
3. Restore 실행 시 Snapshot count가 증가한다.
4. head_snapshot_id가 새 Snapshot을 가리킨다.
5. 기존 Snapshot 데이터는 변경되지 않는다.
6. 트랜잭션 실패 시 상태는 변경되지 않는다.

---

## 8. 확장 가능성 (Future)

- Snapshot diff 보기 (인접 Snapshot 간 텍스트 차이 비교)
- Snapshot 간 비교
- Release/Tag 기능 (의미 있는 이름 부여)
- Audit view

v1에서는 위 기능을 포함하지 않는다.

---

## 9. 설계 의도 (Intent)

이 화면은 append-only 철학을 사용자에게 시각적으로 드러내는 기능이다.

데이터는 쌓이며,
복구는 파괴가 아니라 새로운 상태의 확정이다.

Snapshot History는 시스템 신뢰성의 UI 표현이다.

---

End of PRD-028

