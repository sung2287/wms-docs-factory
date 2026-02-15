# D-022: Node State Visualization Platform Implementation

## 1. Scope
- UI implementation for ✏️ state icons in the Tree Panel.
- Store logic for managing `visualDirtySnippetIdSet` as an auxiliary state.
- Optimization for node-specific re-renders.

## 2. Non-goals
- Acting as the source of truth for saving (handled by `isDirty` in D-023).
- Persistent storage of the visual dirty set.

## 3. Store Structure
- **visualDirtySnippetIdSet**: `Set<string>` (Auxiliary UI state).
  - This set is used ONLY for rendering the ✏️ icon on specific nodes.
  - Global save logic depends on `WorkspaceStore.isDirty`, not this set.

- **Actions (Internal naming to prevent confusion)**:
  - `SET_VISUAL_DIRTY(snippetId)`: Adds ID to the auxiliary set.
  - `CLEAR_VISUAL_DIRTY()`: Batch clears the entire set (called upon successful save).

## 4. Visualization Rules
- **Content Change**: When a snippet is edited, its `linkedSnippetId` is added to `visualDirtySnippetIdSet`.
- **Structural Change**: When a node is moved or reordered, its own ID (or the `linkedSnippetId` if available) is added to the set to indicate that the node's position/state is unsaved.
- **Batch Resolution**: All icons are removed when `CLEAR_VISUAL_DIRTY` is called after a successful PRD-024 save.

## 5. Component Implementation
- **StatusIcon Component**:
  ```typescript
  const StatusIcon = ({ nodeId, linkedSnippetId }) => {
    const isVisualDirty = useVisualDirty(linkedSnippetId || nodeId);
    
    if (isUnlinked(nodeId)) return <WarningIcon />; // ⚠️
    if (isVisualDirty) return <EditIcon />;        // ✏️
    return <LinkIcon />;                           // 🔗
  };
  ```

## 6. Performance Optimization
- **Granular Subscription**: `TreeNode` components should subscribe only to their specific ID within the `visualDirtySnippetIdSet` to avoid full tree re-renders on every keystroke.
- **Performance Threshold**: If the tree size exceeds management limits, specialized performance strategies (e.g., virtualization) will be defined in a future PRD.

## 7. Logic Flow
1. **User Action (Edit/Move)**:
   - Sets global `isDirty = true` (PRD-024).
   - Dispatches `SET_VISUAL_DIRTY(id)` (PRD-022 auxiliary).
2. **UI Update**: Only the affected node re-renders to show the ✏️ icon.
3. **Save Success**:
   - `isDirty` set to `false`.
   - `CLEAR_VISUAL_DIRTY()` removes all ✏️ icons.

---
### PRD-024 정합성 체크리스트
- [x] dirtySnippetIdSet은 보조 상태임을 명시
- [x] 액션 명칭/주석으로 글로벌 isDirty와 혼동 방지 (SET_VISUAL_DIRTY)
- [x] 구조 변경 시 ID 추가 규칙 명시
- [x] 저장 성공 시 일괄 초기화(Batch Clear) 반영
