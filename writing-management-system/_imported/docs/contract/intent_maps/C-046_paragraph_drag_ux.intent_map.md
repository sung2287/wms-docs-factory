# C-046: Paragraph Drag UX Intent Map

## Intent Summary
본 PRD는 Paragraph Block Editor의 UI 레이어에서 단락 재정렬(Drag & Drop) 경험을 현대화하는 것을 목적으로 한다.

본 변경은 Core, Snapshot, 저장 모델을 변경하지 않으며, Reorder는 Snippet 내부 UI 배열 재정렬에 한정된다.

Mutation은 Drop 시점 1회로 고정된다.

Dirty 판단 기준은 사용자 입력 유형이 아니라 normalize(join(blocks))의 최종 결과값이다.

---

## 1. Objective
Map user drag-and-drop interactions to transient UI states and the final block array mutation, ensuring that the design intent of a "Virtual Reorder" is maintained until the drop event.

## 2. Intent-Reaction Mapping

| User Intent | UI Action / Trigger | System Reaction |
| :--- | :--- | :--- |
| **Initiate Move** | PointerDown on `Handle (⋮⋮)` | Enter `ACTIVE_DRAG` state. Initialize `DragOverlay`. |
| **Preview Order** | PointerMove over Sibling | Update `PROJECTED_ORDER`. Apply CSS transforms to siblings. |
| **Confirm Reorder**| PointerUp (Drop) | Execute Drop Mutation (as defined in PRD-046). Update block array. Trigger Auto-save. |
| **Cancel Reorder** | Escape Key / Loss of Focus | Exit Drag Mode. Restore original UI positions. |
| **Select Text** | PointerDown on Text Area | Ignore Drag logic. Trigger browser default selection. |

---

## Guard Rails (Intent Drift Conditions)
다음 변경은 Intent Drift로 간주된다:

- **Drag Move 단계에서 실제 mutation이 발생하는 경우**: 드래그 중 배열이 실제로 바뀌거나 Dirty가 발생하는 행위.
- **Cross-snippet reorder를 허용하는 경우**: 다른 섹션으로 단락을 넘기는 행위.
- **React key를 index 기반으로 사용하는 경우**: 텍스트 입력 유실 및 렌더링 불일치 초래.
- **Dirty 판단 기준을 변경하는 경우**: `join()` 결과와 무관하게 "드래그 했으므로 Dirty"라고 처리하는 행위.
- **Core / Snapshot / Tree Engine 로직을 수정하는 경우**: UI 기능을 위해 시스템 근간을 수정하는 행위.

---

## 3. Reorder Commitment Workflow
1. **User Action:** Drags Block A below Block C and releases.
2. **Logic Check:** `if (newIndex !== oldIndex)`.
3. **Commit:** Execute Drop Mutation (as defined in PRD-046). Update canonical blocks array.
4. **Integration:** Reset Auto-save debounce timer.
5. **UI Update:** Restore focus to the moved block to ensure input continuity.

---

## 4. Explicit Non-Goals
본 기능(v1)에서는 다음 항목을 의도적으로 배제한다:
- **멀티 블록 이동**: 한 번에 하나의 단락만 이동.
- **키보드 reorder**: 마우스/터치 드래그에 한정.
- **ARIA reorder announce**: 실시간 음성 안내 배제.
- **Virtualization**: 대규모 문서 최적화 배제.
- **Mobile UX 최적화**: 기본 드래그 동작 외 전용 인터페이스 배제.

---

## 5. Future Extension Boundary
다음은 v2 이후의 고도화 영역으로 정의하며, v1 설계에서는 고려하지 않는다:
- 키보드 기반 reorder 지원.
- Multi-select reorder 기능.
- 트리 탐색기와 연동된 Cross-snippet drag.
- Paragraph 외 Block type (Heading, List 등) 확장.
