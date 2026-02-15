# PRD-023: Save UX v1 (UI 명세)

---

## 1. 목적 (Why)

사용자에게 명확한 저장 상태를 전달하고, 명시적 저장(Explicit Save) 과정에서의 안정적인 UX를 제공한다.

본 문서는 PRD-024에서 확정한 저장 모델 및 PRD-025의 Snapshot 전략을 기반으로 한 **상단 바(Top Bar) 및 피드백 루프 명세**이다.

---

## 2. 범위 (Scope)

### 포함
1. Top Bar 내 저장 버튼 및 상태 메시지
2. 저장 중 편집 차단(Locking) UX
3. 저장 결과(성공/실패)에 대한 UI 피드백

### 제외
- 저장 데이터 구조 및 API 명세 (PRD-024/025)
- 자동 저장 및 버전 관리
- 다중 사용자 충돌 해결

---

## 3. UI 컴포넌트 및 상태

### Top Bar 구성
```
┌──────────────────────────────────────┐
│ Workspace Name   [저장]   상태표시   │
└──────────────────────────────────────┘
```

### 상태 연동 (WorkspaceStore 구독)
- **버튼 활성화 (`canSave`)**: `!isSaving && isDirty`
  - `isDirty`가 `false`이면 버튼은 비활성화된다.
- **상태 메시지 (`statusMessage`)**:
  - `isDirty === false` : "모든 변경사항 저장됨"
  - `isDirty === true` : "저장되지 않은 변경사항 있음"
- **저장 중 표시**: `isSaving === true` 일 때 버튼 내 Spinner 표시 및 "저장 중..." 메시지 노출.

---

## 4. 저장 프로세스 UX (LOCKED 정책 반영)

사용자가 "저장" 버튼을 클릭하면 다음과 같은 시퀀스가 발생한다:

1. **상태 전이**: `isSaving = true`로 설정.
2. **입력 잠금 (UI Locking)**:
   - 에디터(Editor)는 즉시 `readOnly` 또는 `disabled` 상태로 전환된다.
   - 트리(Tree) 조작 및 노드 추가/삭제 기능이 비활성화된다.
   - 추가적인 편집 행동을 원천 차단하여 데이터 정합성을 보장한다.
3. **API 호출**: 서버는 현재 상태를 기반으로 새로운 Snapshot을 append 생성하고, Workspace.head_snapshot_id를 갱신한다. (PRD-025 Append-only 전략)
4. **결과 처리**:
   - **성공 시**: 
     - "저장 성공" Toast 메시지 표시.
     - `isDirty = false`, `dirtySnippetIdSet.clear()` (UI 보조 상태 초기화).
     - `rev` 및 `updatedAt` UI 반영.
   - **실패 시**:
     - "저장 실패" 알림 및 오류 메시지 표시.
     - `isDirty = true` 상태 유지.
5. **잠금 해제**: `isSaving = false`로 설정되어 편집 가능 상태로 복귀.

---

## 5. Unload 경고

- 사용자가 페이지를 이탈하려 할 때, `isDirty === true`라면 브라우저 표준 confirm 대화상자를 통해 데이터 유실 위험을 알린다 (PRD-024 Unload 정책).

---

## 6. 수용 기준 (Acceptance Criteria)

1. 수정 발생 시 저장 버튼이 활성화되고 상태 메시지가 "저장되지 않은 변경사항 있음"으로 변한다.
2. **저장 버튼 클릭 즉시 에디터와 트리의 편집 기능이 차단된다.**
3. 저장 성공 후 버튼이 비활성화되고 메시지가 "모든 변경사항 저장됨"으로 변한다.
4. 저장 실패 시 편집 차단은 해제되지만, 저장 버튼은 여전히 활성 상태를 유지한다.

---

## 7. 정합성 체크리스트
- [x] `canSave` 계산식이 `isDirty` 중심으로 유지되는가?
- [x] 저장 중 편집 차단(LOCKED) 정책이 명시되었는가?
- [x] PRD-025의 Append-only Snapshot 생성 및 head 갱신 개념이 반영되었는가?
