# D-045: Paragraph Block Editor Platform Design

## 1. Objective
Define the implementation strategy for the Paragraph Block Editor, focusing on component state management, rendering performance, and the lifecycle of the virtual block array.

## 2. Component State Model

### 2.1 State Structure
```typescript
interface BlockEditorState {
  nodeId: string;
  blocks: string[];         // The virtual block array
  lastSavedText: string;    // Result of join(split(normalize(source))) at load time
  isDirty: boolean;         // Computed or tracked flag
}
```

### 2.2 Lifecycle
1.  **Mount:**
    - Receive `rawText` from store.
    - Execute `normalized = normalize(rawText)`.
    - Set `lastSavedText = normalized`.
    - Set `blocks = splitParagraphBlocks(normalized)`.
2.  **Edit:**
    - Update `blocks[i]` in local state.
    - Emit onMutation events to Workspace.
    - Workspace layer handles debounce and save state machine.
3.  **Unmount/Save:**
    - Emit normalizedText to the Workspace layer.
    - The Workspace layer is solely responsible for snapshot dispatch.

## 3. Rendering Strategy
- **List Rendering:** Map the `blocks` array to a list of `BlockComponent` instances.
- **Keys:** Use a unique stable identifier if available; otherwise, use `index` (with caution) or a session-specific UUID generated per block upon split.
- **Virtualization:** For sections exceeding 50 blocks or 10,000 words, implement list virtualization to maintain 60fps interaction.

## 4. Interaction & Performance
- **Debounce:** Keystrokes trigger a 2000ms debounce for the `join` and `dirty` validation.
- **Focus Management:** When moving blocks up/down, focus must follow the moved block to ensure continuous keyboard accessibility.
- **Word Count:** Compute total word count by aggregating `wordCount(block)` for all blocks in the array.

## 5. Failure Handling
- **Normalization Failure:** If `normalize` produces an unexpected result, log a `StructuralIntegrityWarning` but allow editing.
- **Save Conflict:** If a 409 Conflict occurs during auto-save, transition UI to **PRD-043 Comparison Mode** using the current `blocks` array as the "Draft" source.

## 6. Constraints
- **Persistence Layer:** Under no circumstances should individual blocks be sent to the backend. The platform must always provide a single `rawText` string.
