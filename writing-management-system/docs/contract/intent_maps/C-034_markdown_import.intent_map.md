# C-034_markdown_import.intent_map.md

## 1. Purpose
The bulk import function allows users to transition existing Markdown-based writing projects into the Writing Management System. It recognizes the file system as the initial structural authority and converts it into a managed Workspace environment.

## 2. Policy Freezes

### 2.1 File System as Structural Authority (One-Time)
- **Policy:** For v1, the filename acts as the "source of truth" for the hierarchy.
- **Intent:** To provide a low-friction entry point for users with established local file collections. Once imported, the Workspace becomes the SSOT, and the file system structure is no longer authoritative.

### 2.2 Deterministic Ancestor Auto-Creation
- **Policy:** The system MUST auto-create missing parents in the key hierarchy.
- **Intent:** To eliminate the burden of manual folder/file creation for structural nodes. This ensures a valid tree structure is always built, even from fragmented file sets.

### 2.3 Mode A Exclusivity (v1)
- **Policy:** v1 supports only Filename-Based Import (Mode A).
- **Intent:** To freeze the core tree-building logic before introducing more complex semantic parsing (Mode B). This ensures a stable foundation for structural importing.

## 3. Risk Mitigation

### 3.1 Naming Collision Prevention
- By enforcing strict validation against duplicate normalized keys (dot vs hyphen), we prevent "shadowing" where one file's content accidentally overwrites another during import.

### 3.2 Orphan Node Prevention
- Auto-generation of parent nodes prevents "floating" nodes in the database, which would otherwise break tree-traversal and snapshot consistency.

### 3.3 Identity Separation
- We strictly decouple `node_id` (internal identity) from `external_key` (external structure). This allows the system to remain robust even if files are renamed or re-indexed in the future (though v1 is one-time).

## 4. Philosophical Alignment
- **Zero-Partial-States:** Import is either 100% successful or 100% aborted. This prevents "dirty" workspaces that require manual cleanup.
- **Natural Ordering:** Using natural numeric sort (1.2 < 1.10) aligns the system's internal organization with human intuition and common writing practices.
