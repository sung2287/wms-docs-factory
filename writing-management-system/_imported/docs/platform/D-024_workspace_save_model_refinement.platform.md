# D-024: Workspace Save Model Refinement Platform

## 1. Scope
- Implementation of the `WorkspaceStore` state model updates.
- Wiring of the save action with UI locking and full snapshot payload.
- `beforeunload` event listener management.

## 2. Non-goals
- Detailed implementation of the backend API.
- Complex conflict resolution logic.

## 3. State Model Update
The `WorkspaceStore` must include:
```typescript
interface WorkspaceState {
  snapshot: WorkspaceSnapshot (as defined in the current repository schema);
  selectedNodeId: string | null;
  isDirty: boolean;
  isSaving: boolean;
}
```

## 4. Action Implementation

### 4.1. Action-Based Dirty Logic
- Every reducer that modifies `snapshot.tree` or `snapshot.snippets` must automatically set `isDirty = true`.
- **Exception**: The `LOAD_WORKSPACE` and `SAVE_SUCCESS` actions set `isDirty = false`.

### 4.2. Save Workflow
```typescript
async function saveWorkspace() {
  const state = getStoreState();
  if (!state.isDirty || state.isSaving) return;

  // 1. Lock UI
  dispatch({ type: 'SET_SAVING', payload: true });

  try {
    // 2. Full Snapshot PUT
    // Invoke existing persistence endpoint via full snapshot PUT
    const updatedMeta = await api.put('/workspaces/default', state.snapshot);

    // 3. Success Update
    dispatch({ 
      type: 'SAVE_SUCCESS', 
      payload: updatedMeta // Contains new rev and updatedAt
    });
  } catch (error) {
    // 4. Failure Handle
    dispatch({ type: 'SAVE_FAILURE', payload: error });
  }
}
```

## 5. UI Implementation
- **Blocking Interaction**:
  - The root layout or specific panels (Editor/Tree) should accept an `isReadOnly` or `disabled` prop.
  - When `isSaving` is true, pass `disabled={true}` to all input fields and tree interaction handlers.
  - Alternatively, render a semi-transparent overlay with a spinner over the main content area.

## 6. Lifecycle Management
- **Unload Listener**:
  - In the main app component (e.g., `App.tsx` or `WorkspaceLayout`), use `useEffect` to bind `beforeunload`.
  ```typescript
  useEffect(() => {
    const handleBeforeUnload = (e: BeforeUnloadEvent) => {
      if (isDirty) {
        e.preventDefault();
        e.returnValue = ''; // Trigger browser warning
      }
    };
    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => window.removeEventListener('beforeunload', handleBeforeUnload);
  }, [isDirty]);
  ```
