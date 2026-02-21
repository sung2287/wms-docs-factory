# C-054: React Paragraph Editing v1 Intent Map

## 1. Rationale: UI-Only Transformation
The decision to implement editing strictly at the React UI layer is driven by the stability of the existing persistence logic. Since the backend and adapter layers already handle the complexities of snapshots and concurrency, the intent is to "bridge" these capabilities into the new React Viewer without re-architecting proven systems.

## 2. Intent: Mode Transition vs. Error
The system treats HTTP 409 (Conflict) as a signal for **State Transition** rather than a failure. 
- **Reason:** A conflict is a natural occurrence in collaborative or multi-session writing. Treating it as an error would imply a system failure, whereas a mode transition acknowledges the need for human-in-the-loop resolution (Comparison Mode).

## 3. Intent: Draft Preservation
Data integrity is the highest priority. The intent is to ensure that no user keystrokes are lost due to network state. By freezing the execution and preserving the Draft in memory during a conflict, we allow the user to decide whether to discard their work (Refresh) or persist it (Override).

## 4. Intent: Save Scheduler Reuse
The intent is to prevent "logic drift." By reusing the legacy Save Scheduler, we ensure that:
- Debounce timing (2s) remains consistent.
- Dirty-checking logic remains centralized.
- The React layer remains a "dumb" view that simply requests a save from a "smart" scheduler.

## 5. Philosophy: Core Layer Immutability
Core business rules (how paragraphs are stored, how snapshots are calculated) are considered "settled science." PRD-054 intends to respect this boundary to minimize regression risks in the critical persistence path.
