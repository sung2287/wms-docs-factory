# PRD-030: Save UX v2 Enhancement

---

## 1. 목적 (Purpose)

PRD-023 Save UX v1과 PRD-028/029 Snapshot History 및 Time Travel 기능을 기반으로,
저장 경험을 강화하여 사용자가 현재 상태와 저장 이력을 명확히 인지할 수 있도록 한다.

이 PRD의 목표는 다음과 같다:

1. 마지막 저장 상태를 명확히 표시한다.
2. Snapshot 기반 저장 개념을 사용자에게 시각적으로 전달한다.
3. 저장 성공/실패 상태를 일관되게 표현한다.
4. append-only 철학을 UX에 반영한다.

---

## 2. 핵심 개념

Save는 단순한 "덮어쓰기"가 아니다.

- Save는 새로운 Snapshot 생성 행위다.
- 모든 저장은 기록으로 남는다.
- 현재 상태는 항상 특정 Snapshot을 가리킨다.

Save UX는 이 구조를 사용자에게 투명하게 보여준다.

---

## 3. UI 구성 요소

### 3.1 상단 상태 바 (Status Bar)

에디터 상단 또는 하단에 다음 정보를 표시한다:

- 현재 Snapshot ID (축약 표시 가능)
- 마지막 저장 시각 (e.g., "Last saved at 14:32:10")
- Snapshot 총 개수

예시:

"Snapshot #42 · Last saved 14:32:10 · 18 snapshots total"

Snapshot 번호와 총 개수는 사용자가 작업 이력이 누적되고 있음을 인지할 수 있도록 항상 동기화되어야 한다.

저장 성공 시 서버에서 반환된 최신 `snapshot_id`와 `snapshot_count`를 즉시 반영한다.

---

### 3.2 저장 버튼 상태 (Save State Machine)

버튼은 다음 상태를 가진다:

1. Idle (저장 필요 없음)
2. Dirty (저장 필요)
3. Saving (진행 중)
4. Saved (방금 저장 완료 표시, 짧은 시간 유지)
5. Error (저장 실패)

상태 전이 가이드:

| State  | Trigger | UI Feedback |
|--------|---------|------------|
| Idle   | 최초 로드 또는 저장 직후 | 비활성화 또는 체크 아이콘 |
| Dirty  | 사용자 입력 발생 | "Unsaved changes", 버튼 활성화 |
| Saving | Save 버튼 클릭 | 스피너(Spinner), 입력 일시 차단 |
| Saved  | API 성공 응답 수신 | "저장 완료" 메시지 (1~2초 유지) |
| Error  | 네트워크/서버 오류 | 경고 아이콘, 재시도 유도 |

각 상태는 명확한 시각적 피드백을 제공해야 한다.

---

### 3.3 Dirty 표시

- 수정이 발생하면 "Unsaved changes" 표시
- Snapshot ID와 현재 Draft 상태를 시각적으로 구분

---

## 4. 저장 동작 흐름

### Step 1: Dirty 상태 발생

- 사용자 입력 발생
- dirtySnippetIdSet 업데이트
- 저장 버튼 활성화

### Step 2: Save 클릭

- 저장 버튼 → Saving 상태
- API 호출 (append-only Snapshot 생성)

### Step 3: 성공

- 새로운 Snapshot ID 수신
- head_snapshot_id 갱신
- Snapshot count 증가
- Dirty 상태 초기화
- "Saved" 표시 후 Idle 상태 전환

### Step 4: 실패

- 상태 변경 없음
- Dirty 유지
- Error 상태 표시
- 사용자 재시도 가능

---

## 5. Snapshot 정보 반영 규칙

- Save 성공 시 상태 바의 Snapshot ID 즉시 업데이트
- Snapshot count 즉시 증가 표시
- 서버 응답 값과 UI 상태는 항상 동기화되어야 한다.
- Time Travel Mode에서는 상태 바 정보를 "열람 중인 Snapshot" 기준으로 표시한다.
- Time Travel Mode에서는 저장 버튼을 숨기거나 완전히 비활성화한다.

---

## 6. Draft 구분 원칙

- 현재 메모리에만 존재하는 수정사항(Draft)과
  마지막으로 확정된 Snapshot 사이의 차이를 명확히 구분한다.
- Dirty 상태는 "확정되지 않은 변경"임을 시각적으로 표현한다.
- Save 실패 시 Draft는 유지되어야 한다.

---

## 7. UX 원칙

1. 저장은 항상 가시적인 기록 생성으로 표현되어야 한다.
2. 사용자는 "현재 내가 어떤 Snapshot 위에 있는지" 항상 알 수 있어야 한다.
3. Save 실패 시 어떠한 데이터도 손실되지 않는다.
4. Saving 상태에서는 비동기 처리를 유지하되, 입력은 일시 차단한다.
5. Time Travel Mode에서는 저장 UI가 혼동을 일으키지 않아야 한다.

---

## 7. 비범위 (Out of Scope)

- Auto-save (별도 PRD 대상)
- Snapshot diff 표시
- Release/Tag 기능
- Snapshot GC 정책

---

## 8. Acceptance Criteria

1. 저장 성공 시 Snapshot count가 증가한다.
2. Snapshot ID가 즉시 갱신된다.
3. Dirty 상태는 Save 후 초기화된다.
4. Save 실패 시 Dirty 상태는 유지된다.
5. Time Travel Mode에서 저장이 불가능하다.

---

## 9. 설계 의도 (Intent)

Save UX v2는 append-only 구조를 사용자 경험으로 번역하는 단계다.

사용자는 단순히 "저장했다"가 아니라,
"새로운 기록을 남겼다"는 감각을 가져야 한다.

이 PRD는 저장 엔진과 UI 사이의 의미적 연결을 강화한다.

---

End of PRD-030

