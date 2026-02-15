# D-023: Save UX Platform Implementation

## 1. Scope
- UI implementation of the Top Bar save controls.
- Integration with the Workspace persistence model (PRD-024) and Append-only Snapshot strategy (PRD-025).
- Implementation of the LOCKED policy during saving.
- Feedback UI (Toast/Notification) implementation.

## 2. Non-goals
- Implementing the actual API endpoint (handled by infrastructure).
- Version history browsing UI (handled in a separate PRD).

## 3. UI Components
- **TopBar**:
  - `Title`: Workspace name.
  - `SaveButton`: 
    - Props: `disabled={!canSave}`, `loading={isSaving}`, `onClick={handleSave}`.
  - `StatusMessage`: Displays "All changes saved" or "Unsaved changes".
- **ToastNotification**: A global layout component for success/error feedback.

## 4. State Store (Save Logic)
- **Store**: `WorkspaceStore` (SSOT)
  - `isSaving: boolean`
  - `isDirty: boolean`
  - `lastSavedAt: Date | null`

**Derived State:**
- `canSave = !isSaving && isDirty`
- `saveStatusMessage = !isDirty ? "All changes saved" : "Unsaved changes"`

**LOCKED Policy Enforcement:**
- When `isSaving === true`:
  - Editor component must receive `readOnly={true}` or `disabled={true}`.
  - Tree component must disable drag-and-drop, node creation, deletion, and renaming.

- **Actions**:
  - `executeSave()`:
    ```typescript
    async executeSave() {
      if (!canSave) return;
      
      // 1. Enter LOCKED State
      setSaving(true);
      
      try {
        // 2. Append-only Save Request (PRD-025)
        // Note: The storage implementation must perform:
        //   a) INSERT INTO snapshots ...
        //   b) UPDATE workspaces SET head_snapshot_id = new_id, rev = rev + 1 ...
        //      - rev is a Workspace-level revision counter.
        //      - rev is independent of Snapshot overwrite concepts.
        //      - rev tracks Workspace head movements while Snapshots remain immutable.
        //   No UPDATE is allowed on existing snapshot records.
        const response = await api.post('/workspaces/default/snapshots', currentSnapshot);
        
        // 3. Update Canonical State
        dispatch({ 
          type: 'SAVE_SUCCESS', 
          payload: { 
            rev: response.rev,
            head_snapshot_id: response.head_snapshot_id,
            updatedAt: response.updatedAt 
          } 
        });
        
        // 4. Clear Auxiliary Visualization State
        clearVisualDirtySet(); // Auxiliary (PRD-022)
        
        showToast("Successfully saved!", "success");
      } catch (e) {
        showToast("Save failed: " + e.message, "error");
      } finally {
        // 5. Release LOCKED State
        setSaving(false);
      }
    }
    ```

## 5. Storage Integration (Append-only)
- Implementation must follow the "Append-only" strategy defined in PRD-025.
- Existing snapshot records are immutable.
- Every save operation results in a new snapshot ID being associated with the workspace head.
- **Revision Policy**: `rev` is a auxiliary Workspace-level counter used to track the history of head movement, not the version of individual snapshots.

## 6. Performance & UX
- **Button Feedback**: The Save button should transition to a loading state to prevent redundant clicks.
- **BeforeUnload**: The application must bind to the `beforeunload` event if `isDirty` is `true`.
  ```typescript
  window.onbeforeunload = isDirty ? () => "You have unsaved changes." : null;
  ```

---
### 정합성 체크리스트
- [x] canSave/isDirty 기반 UI 로직 유지
- [x] LOCKED 정책(Editor/Tree 차단) 유지
- [x] 서버 저장 로직을 Snapshot insert + Workspace head update로 명시
- [x] 기존 Snapshot UPDATE 금지 명시
- [x] 성공 시 new snapshot 및 head 정보 반영 명시
- [x] rev가 Workspace-level head 이동 카운터임을 명확히 기술
