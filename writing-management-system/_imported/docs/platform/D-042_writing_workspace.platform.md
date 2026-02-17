# D-042: Writing Workspace Platform Design

## 1. Objective
Define the implementation details for the Writing Workspace UI, including the integration of the Paragraph Block Editor, the dirty state tracking mechanism, and visual save indicators.

## 2. Component Integration
- **Layout:** Standard Two-Pane (Tree Explorer left, Editor right).
- **Editor:** Mounts the `ParagraphBlockEditor` (PRD-045).
- **Inter-Component Communication:** The Editor emits a `onMutation` event to the Workspace parent, which manages the Auto-Save state machine and timers.

## 3. Dirty State Tracking Implementation
- **Reference:** Store `lastSavedNormalizedText` in the workspace state.
- **Logic:**
  ```typescript
  // Triggered on mutation
  const currentText = joinParagraphBlocks(currentBlocks);
  const normalizedCurrent = normalize(currentText);
  const isDirty = normalizedCurrent !== lastSavedNormalizedText;
  ```
- This check ensures that the system does not create redundant snapshots for purely formatting-related or identity-preserving changes.

### Frozen Normalized Value Rule (C-042 Alignment)

- DIRTY → SAVING 전이 시점에 normalize(join(blocks)) 값을 반드시 단 한 번 계산하고 이를 `frozenNormalizedText`로 저장해야 한다.
- 해당 `frozenNormalizedText`는 다음 세 용도로 동일 값이 재사용되어야 한다:
  (1) Snapshot 비교
  (2) Save Payload
  (3) SUCCESS 시 lastSavedNormalizedText 업데이트
- SAVING 상태 동안 추가 mutation이 발생하더라도 `frozenNormalizedText`는 변경되어서는 안 된다.
- 동일 상태 전이 내에서 normalize() 재계산은 금지한다.
- Workspace는 “Single Evaluation per Transition” 제약을 따른다.

## 4. UI Indicators & Feedback
- **Save Status Indicator:**
  - Located in the Editor Header.
  - **"Saving..."**: Visible while in `SAVING` state.
  - **"Saved"**: Visible for 1500ms after `SUCCESS`.
  - **"Error"**: Persistent red indicator if in `ERROR` state.
- **Non-Intrusive:** The indicator must not cause layout shifts (use absolute positioning or a dedicated reserved slot).

## 5. Lifecycle & Navigation Guards
- **Editor Mount:** Fetch data -> Split into blocks -> Initialize `lastSavedNormalizedText`.
- **Navigation Guard:**
  - Use a framework-specific router guard (e.g., `onBeforeRouteUpdate`).
  - Access the Workspace state machine.
  - If `isDirty`, return a promise that resolves only after a successful save or user cancellation (if cancellation is supported).

## 6. Performance & Error Handling
- **Debounce Management:** Ensure the debounce timer is cleaned up on component unmount to prevent memory leaks or "ghost" saves.
- **Save Conflict (409):** If an auto-save returns 409, the platform MUST transition to the **PRD-043 Conflict Comparison UI** immediately.
