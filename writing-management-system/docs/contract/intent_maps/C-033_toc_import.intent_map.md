# C-033_toc_import.intent_map.md

## 1. Purpose
The lightweight TOC import provides a low-friction entry point for AI-generated or manually drafted structures. It allows users to bootstrap a Workspace structure before writing actual content.

## 2. Policy Freezes

### 2.1 Identity Separation (UUID vs. External Key)
- **UUID is Identity:** The system's internal integrity is tied to immutable UUIDs.
- **external_key is Navigation:** The `external_key` (dot-notation) is frozen as a user-facing navigation alias. It is not used for internal foreign keys. This prevents "cascading updates" if a hierarchy is renumbered.

### 2.2 Rendering Independence
- **No Stored Numbers:** Rendering numbers (e.g., "Chapter 1") are computed at runtime based on the tree structure. This import function freezes the policy of not storing transient presentation state in the persistence layer.

### 2.3 Creation-Only Constraint (v1)
- To prevent accidental corruption of existing data, v1 is frozen as a "Creation-Only" tool. Update/Merge logic is deferred to v2 to allow for more complex diff-resolution policies.

## 3. Risk Mitigation

### 3.1 Structural Chaos Prevention
- By enforcing dot-depth validation (`1.2.3` must have parent `1.2`), we prevent "floating nodes" or inconsistent hierarchies that would break the editor's tree view.
- Deterministic sorting (Depth -> Input Order) ensures that two people importing the same file will always get the exact same internal `order_int` values.

### 3.2 Snippet Integrity
- Every node is born with an empty snippet. This ensures the editor never encounters a `null` body state, maintaining the 1:1 node-to-snippet invariant across the system.

## 4. Philosophical Alignment
- **AI-Ready:** The format is designed to be easily produced by LLMs (YAML) or spreadsheet exports (TSV).
- **Stability First:** We prioritize a valid tree structure over flexibility. If the input is slightly inconsistent, we fail fast rather than trying to "guess" the user's intent.
