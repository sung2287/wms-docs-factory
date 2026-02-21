# D-054: React Paragraph Editing v1 Platform

## 1. Component Responsibilities
- **React Paragraph Component:** Responsible for rendering content and capturing input. It MUST interface with the `Paragraph Codec` for normalization.
- **Save Orchestrator (UI Hook):** Manages the transition between Local State and the Save Scheduler. It MUST track the `isDirty` flag.

## 2. Integration Points
- **Codec Integration:** React textareas MUST utilize the existing Paragraph Codec (shared logic) for `raw_text` <-> `block` transformation to ensure parity with the legacy editor (PRD-045).
- **Save Scheduler Path:** React UI MUST invoke the established `WorkspaceAdapter.requestSave()` path. It MUST NOT perform direct `fetch` calls to the `/writing-save` endpoint.

## 3. State Transition Diagram
```text
[IDLE] --(Input)--> [EDITING/DIRTY] 
[EDITING/DIRTY] --(2s Debounce/Manual)--> [SAVING]
[SAVING] --(HTTP 200)--> [IDLE]
[SAVING] --(HTTP 409)--> [COMPARISON MODE]
```

## 4. Technical Requirements for Execution Freeze
- **Timer Management:** The platform MUST provide a mechanism to cancel the active debounce timer immediately upon a 409 response.
- **Comparison UI Entry:** Upon 409, the renderer MUST switch the Document Canvas display from the Editable List to the Dual-Pane Comparison View (PRD-043).

## 5. Persistence Security
- **No New Endpoints:** The platform uses existing REST endpoints only.
- **No Core Mutation:** No direct state mutation of `src/core` structures is allowed from React components. All updates must flow through the Adapter boundary.
