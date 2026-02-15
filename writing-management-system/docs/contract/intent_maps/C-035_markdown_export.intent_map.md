# C-035_markdown_export.intent_map.md

## 1. Purpose
The Markdown export function provides a way for users to extract their content from the managed Workspace into a portable, standard format. It ensures that the Writing Management System remains an "open" system with no data lock-in.

## 2. Policy Freezes

### 2.1 Pure Function (Read-Only)
- **Policy:** Export is a pure read operation.
- **Intent:** To guarantee that exporting data never risks the integrity of the Workspace or its snapshot history. It allows for safe content backup and distribution without side effects.

### 2.2 Round-Trip Stability
- **Policy:** Export MUST produce files that match PRD-034 Mode A import rules.
- **Intent:** To freeze the relationship between the internal database and the external file system. This ensures that users can move content out of the system, edit it with external tools, and bring it back in with zero structural loss.

### 2.3 Flat Export (v1)
- **Policy:** v1 exports all files into a single flat directory.
- **Intent:** To simplify the initial export implementation and avoid the complexities of folder mapping strategies. Flat export using `external_key` as filenames is the most robust way to ensure deterministic re-importing.

## 3. Risk Mitigation

### 3.1 State Mutation Protection
- By explicitly forbidding snapshot creation or metadata updates during export, we prevent "audit log pollution" where exports appear as edits in the system history.

### 3.2 Partial Export Prevention
- The "Temp-then-Rename" strategy protects the user's file system from corrupted or incomplete folder states if the export process is interrupted (e.g., disk full, power failure).

### 3.3 Identity Leaks
- By exporting only via `external_key` and ignoring internal `node_id`s (UUID), we prevent exposing internal implementation details and ensure the exported content remains truly portable and independent of a specific database instance.

## 4. Philosophical Alignment
- **Open Data:** The system should not hold user content hostage. Export is the primary mechanism for data sovereignty.
- **Raw Fidelity:** We export the "raw" snippet body because we believe the system should not meddle with the user's Markdown formatting during the export-import cycle.
