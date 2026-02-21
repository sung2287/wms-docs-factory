# PRD-054: React Paragraph Editing v1 (Reuse writing-save Contract)

**Status: Draft**

## 1. Objective
Enable native paragraph block editing within the React-based Writing Workspace (PRD-052) by leveraging existing backend infrastructure. The system shall transition paragraph rendering from read-only to read-write mode while strictly reusing the established writing-save contract, ensuring full compatibility with existing snapshot and conflict management policies.

## 2. In Scope
* **Editable Textareas:** Transition React paragraph components from `readOnly` to editable states.
* **Paragraph Codec Integration:** Reuse existing client-side logic for paragraph splitting, joining, and normalization.
* **Save Triggering:** 
    * Save Triggering은 기존 PRD-042 Auto-Save 정책을 유지한다.
    * 2초 Debounce Auto-Save 동작을 변경하지 않는다.
    * 명시적 Save 버튼은 기존 Save UX(PRD-030)의 상태 머신을 그대로 따른다.
    * Auto-Save 엔진 로직, 타이밍, Dirty 정책은 수정하지 않는다.
    * React UI는 새로운 Save 트리거(focus-out, blur 기반 자동 저장 등)를 추가하지 않는다.
    * 저장 트리거는 기존 Legacy Workspace(PRD-042)의 Auto-Save 및 명시적 Save 정책과 100% 동일해야 한다.
    * React는 기존 Save Scheduler를 호출하는 UI Layer일 뿐, Save 타이밍 또는 호출 조건을 변경하지 않는다.
    * Save 트리거 로직은 재정의(redefine)하지 않고, 재사용(reuse)만 허용된다.
* **HTTP 409 (Conflict) Handling:** Integration with the UI to detect and respond to server-side conflict signals.
* **UI Persistence Indicators:** Implement visual feedback for "Saving," "Saved," and "Error" states aligned with PRD-049/051 aesthetics.

## 3. Out of Scope
* **Autosave Engine Redesign:** No changes to the timing or logic of the existing background save scheduler.
* **New Backend Endpoints:** Absolute prohibition on creating new API routes for writing persistence.
* **Core Logic Modification:** No changes to `src/core/**` or business-level state machines.
* **Reordering Operations:** Drag-and-drop or tree reordering remain in the scope of PRD-046 and PRD-048.

## 4. Contract Reuse (Mandatory)
The implementation must exclusively use the existing writing-save endpoint:

* **Endpoint:** `POST /api/workspaces/<workspaceId>/writing-save`
* **Request Body:**
```json
{
  "node_id": "string",
  "raw_text": "string",
  "writing_status": "string",
  "review_required": "boolean"
}
```
* **Success (200 OK):** The client updates the local head snapshot reference and clears the dirty flag.
* **Conflict (409 Conflict):** The client halts the save operation and initiates the conflict resolution flow.

## 5. Conflict Handling
In accordance with system-wide integrity policies:
* **Detection:** Upon receiving an HTTP 409 status code during a save operation.
* **Action:** Transition the UI to the Conflict Comparison Mode (as defined in PRD-043).
* **Constraints:** 
    * The system MUST NOT silently overwrite remote changes.
    * The system MUST NOT attempt automatic merging of text content at this stage.

### [Draft Preservation Rule]
* HTTP 409 응답은 "저장 실패"가 아니라 "모드 전환 신호"로 간주한다.
* 409 수신 시, 현재 React 상태에 존재하는 Draft(raw_text 및 block 배열)는 절대 폐기되지 않아야 한다.
* UI는 즉시 PRD-043 Comparison Mode로 전환해야 한다.
* Comparison Mode 진입 시:
    * Left: Server Head (읽기 전용)
    * Right: User Draft (읽기 전용)
* Draft는 Comparison Mode에서 수정 불가하며, Override 또는 Refresh 중 하나가 명시적으로 선택되기 전까지 유지된다.
* 409 발생 시:
    * 자동 재시도 금지
    * Silent overwrite 금지
    * Silent discard 금지

### [Conflict Mode Execution Freeze]
* Comparison Mode 진입 즉시:
    * 모든 Auto-Save Debounce 타이머는 중단되어야 한다.
    * 추가 Save 요청은 차단되어야 한다.
    * Editing UI는 읽기 전용 상태로 전환되어야 한다.
* Override 또는 Refresh가 명시적으로 선택되기 전까지:
    * 추가 저장 호출 금지
    * 추가 Draft 변경 금지
    * 백그라운드 재시도 금지
* 409은 Error 상태가 아니라 State Transition(Editing → Comparison)으로 처리되어야 한다.

## 6. UI Constraints
* **Document Mode:** Maintain the seamless "Document Canvas" feel defined in PRD-049.
* **Visual Consistency:** Adhere to minimal interaction controls (hover-only affordance) as per PRD-051.
* **Theme Tokens:** All colors and spacing must be derived from centralized theme tokens; hardcoded values are prohibited.
* **Scroll Policy:** Only document-level scrolling is permitted; individual paragraph textareas must auto-grow to prevent inner scrollbars.

## 7. Acceptance Criteria
* **Content Integrity:** Editing a paragraph correctly updates the `raw_text` field in the persistence payload.
* **Snapshot Consistency:** A successful 200 OK response correctly advances the local workspace state to the latest server snapshot.
* **Conflict Trigger:** An HTTP 409 response successfully halts authoring and displays the Conflict Comparison UI.
* **Contract Stability:** Zero changes to server-side API definitions or request/response structures.
* **Core Purity:** Verification that no files under `src/core/**` have been modified in the implementation branch.
* **Draft Preservation on 409:** 409 수신 시 Draft가 손실되지 않는다.
* **Comparison Accuracy:** 409 수신 후 Comparison Mode 진입 시, Right 패널에는 Save 직전의 Draft 내용이 정확히 표시된다.
* **Memory Retention:** Override 또는 Refresh 선택 전까지 Draft는 메모리에서 유지된다.
* **Auto-Save Consistency:** PRD-042 Auto-Save 정책(2초 Debounce)이 기존과 동일하게 동작한다.
* **Save Status UX:** PRD-030 Save 상태 표시(Saving/Saved/Error)가 기존과 동일하게 표현된다.
* **Execution Freeze on 409:** 409 수신 직후 Auto-Save 타이머가 즉시 중단된다.
* **API Call Suppression:** 409 이후 추가 Save API 호출이 자동으로 발생하지 않는다.
* **State Transition Logic:** 409은 UI Error 배너가 아닌 Comparison Mode 전환으로 처리된다.
* **Scheduler Reuse:** React는 Save Scheduler를 재정의하지 않으며, 기존 호출 경로를 그대로 사용한다.

## 8. Drift Prevention
* **Zero Core Changes:** Implementations found modifying `src/core/**` will be rejected.
* **Adapter Integrity:** No new endpoints or public methods shall be added to the Adapter layer; only existing persistence methods should be invoked.
* **No Rule Expansion:** Snapshot creation rules and autosave intervals must remain exactly as they were in the legacy workspace.
