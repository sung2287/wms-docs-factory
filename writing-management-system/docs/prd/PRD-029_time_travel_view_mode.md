# PRD-029: Time Travel View Mode v1

---

## 1. 목적 (Purpose)

PRD-028 Snapshot History 화면과 연계하여
과거 Snapshot을 안전하게 열람할 수 있는
Time Travel View Mode를 정의한다.

이 PRD의 목표는 다음과 같다:

1. 과거 Snapshot을 현재 작업 상태와 명확히 구분한다.
2. 과거 상태는 완전한 read-only 모드로 동작한다.
3. 현재 편집 상태와 충돌하지 않는다.
4. Restore 동작과 자연스럽게 연결된다.

---

## 2. 핵심 개념

Time Travel은 "과거로 이동"하는 기능이 아니다.

이는 특정 Snapshot을 기준으로 한
"읽기 전용 상태 열람 모드"다.

- head는 변경되지 않는다.
- 새로운 Snapshot은 생성되지 않는다.
- 편집은 불가능하다.

---

## 3. 진입 경로

### 3.1 History 화면에서 진입

/workspace/:id/history

Snapshot 선택 시 우측 패널에서
Time Travel View Mode로 진입한다.

---

## 4. UI 동작 원칙

### 4.1 상태 배너

상단에 다음 문구를 표시한다:

"과거 Snapshot 열람 중 (Read-Only Mode)"

### 4.2 편집 차단

- 저장 버튼 비활성화
- 입력 필드 비활성화
- 단축키 저장 동작 차단
- 에디터 컴포넌트는 `readOnly` 프로퍼티를 통해 제어되어야 한다.
  - TIME_TRAVEL_MODE일 때 `readOnly = true`
  - ACTIVE_HEAD_MODE일 때 `readOnly = false`
  - 별도의 에디터 구현을 만들지 않고 동일 컴포넌트를 재사용한다.

### 4.3 현재 상태 구분

- 현재 head Snapshot과 다른 경우 명확히 구분
- 현재 Snapshot으로 돌아가기 버튼 제공

---

## 5. 상태 관리 규칙

### 5.1 전역 상태 분리

애플리케이션 상태는 다음 두 모드를 가진다:

1. ACTIVE_HEAD_MODE
2. TIME_TRAVEL_MODE(snapshot_id)

Time Travel Mode에서는:

- Snapshot 데이터는 API에서 직접 조회한다.
- 로컬 편집 상태를 덮어쓰지 않는다.
- Dirty 상태를 변경하지 않는다.
- 메모리에 존재하는 Local Draft(저장되지 않은 수정본)는 유지되어야 한다.
  - History 진입/이탈 시 `dirtySnippetIdSet`과 임시 편집 텍스트는 초기화되지 않는다.
  - TIME_TRAVEL_MODE 종료 후 ACTIVE_HEAD_MODE로 복귀하면 기존 Draft가 그대로 복원되어야 한다.

---

## 6. Restore 연계 규칙

Time Travel Mode에서 Restore를 수행하면:

1. Confirm 모달 표시
2. Restore API 호출
3. 새로운 Snapshot 생성
4. head 업데이트
5. ACTIVE_HEAD_MODE로 전환
6. 최신 상태 렌더

---

## 7. 비범위 (Out of Scope)

- Snapshot diff 비교
- Snapshot 병합 기능
- 부분 Restore
- 자동 Restore

---

## 8. Acceptance Criteria

1. Time Travel 진입 시 편집이 불가능하다.
2. head는 변경되지 않는다.
3. Restore 실행 시 새로운 Snapshot이 생성된다.
4. Restore 성공 후 ACTIVE_HEAD_MODE로 정상 복귀한다.
5. Restore 실패 시 모드는 유지되고 상태 변화가 없다.

---

## 9. 설계 의도 (Intent)

Time Travel Mode는 데이터 안전성을 시각적으로 보장하는 기능이다.

사용자는 과거를 자유롭게 탐색할 수 있지만,
의도하지 않은 데이터 변경은 발생하지 않는다.

이 모드는 Snapshot History의 확장 기능이며,
append-only 철학을 유지한다.

---

End of PRD-029

