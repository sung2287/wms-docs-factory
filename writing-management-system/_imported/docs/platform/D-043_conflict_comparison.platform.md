# D-043: Conflict Comparison Platform Design

## 1. Objective
Define the UI implementation details for the Comparison Mode, focusing on the rendering of the `DiffResult` and interaction with the `PRD-045` editor state.

## 2. Comparison View Component
- **Layout:** Two-column `flex` or `grid` layout.
- **Sync Scrolling:** Implement a synchronized scroll listener. Scrolling one pane MUST scroll the other to keep `Head[i]` and `Draft[i]` aligned.
- **Read-only:** Both panes render blocks as non-editable text areas or divs to prevent further branching of content during resolution.

## 3. Visual Highlighting Rules
- **REMOVED (Left Pane):** Background color `#fee2e2` (light red), text color `#991b1b`.
- **ADDED (Right Pane):** Background color `#dcfce7` (light green), text color `#166534`.
- **PLACEHOLDER:** A dashed-border box with matching height to the counterpart block to maintain vertical alignment.
- **UNCHANGED:** Standard background, no highlighting.

### Placeholder Height Determinism Rule

- PLACEHOLDER height는 counterpart block의 실제 렌더된 `clientHeight`를 기준으로 계산한다.
- Diff 렌더링 이후 DOM layout이 확정된 시점에서 높이를 동기화해야 한다.
- Scroll synchronization은 placeholder height 확정 이후에만 활성화해야 한다.
- Placeholder 계산은 DiffResult의 positional index에만 의존해야 하며, 블록 내용을 기반으로 재계산해서는 안 된다.

## 4. Interaction with PRD-045
- The platform MUST use the `joinParagraphBlocks` and `splitParagraphBlocks` functions from `B-045` for all data transformations.
- The platform MUST rely on pre-normalized block arrays provided by the application layer.
- No additional normalization or mutation is permitted at the platform layer.

## 5. Flow Integration
- **Overlay/Modal:** Comparison Mode is rendered as a full-screen overlay over the `Writing Workspace`.
- **Action Buttons:**
  - **Override (Danger/Primary):** "Save My Version"
  - **Refresh (Secondary):** "Discard My Changes & Load Latest"
- **Error Handling:** If an `Override` attempt fails with another 409 (Double Conflict), the UI must update the `Head` side with the *new* server content and re-calculate the diff.

### Double 409 Determinism Rule (C-043 Alignment)

- Double 409 발생 시 서버에서 전달된 최신 `serverRawText`만 갱신한다.
- `headBlocks`는 반드시 split(normalize(serverRawText))로 재계산한다.
- `draftBlocks`는 절대 재계산하지 않는다.
- draftBlocks는 최초 conflict 감지 시점의 in-memory 배열을 그대로 유지해야 한다.
- 비교 재계산 시 normalize(join(draftBlocks))는 기존 규칙을 따르되, UI 블록 배열을 rawText로부터 다시 생성해서는 안 된다.
