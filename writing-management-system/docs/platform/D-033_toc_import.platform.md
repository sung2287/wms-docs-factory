# D-033_toc_import.platform.md

## 1. Execution Environment
- The import tool MUST run in a **Sandbox** environment to handle external file parsing.
- It is implemented as a **Parser Adapter** that interfaces with the Core Tree Service.

## 2. Application Flow

### Step 1: Parser (YAML/TSV)
- **YAML:** Uses a standard YAML parser to build an in-memory object tree.
- **TSV:** Loads rows into a flat list and maps headers to node attributes.

### Step 2: Depth Normalizer & Sorter
- Calculates the depth of each node based on its `key` (dot-count).
- Sorts nodes by depth (ASC) to ensure parents are processed before children.
- Preserves relative order from input for nodes at the same depth level.

### Step 3: Validation Engine
- Verifies `key` uniqueness.
- Validates that every `parent_key` exists.
- Checks `external_key` dot-notations against parent hierarchy.
- Checks for circular dependencies.

### Step 4: Tree Builder
- Iterates through the sorted list of nodes.
- Generates `node_id` (UUID).
- Sets `parent_id` by looking up the `node_id` of the parent's `external_key`.
- Assigns `order_int` sequentially within each parent group.

### Step 5: Empty Snippet Generation
- For every `node_id` created, generates a `snippet_id` (UUID).
- Sets `snippet.body = ""`.

### Step 6: Snapshot Writer
- Atomically creates the `Workspace`.
- Persists the full `NodeTree` and `SnippetPool`.
- Creates the initial `Snapshot`.

## 3. Layer Boundaries
- **Adapter Layer:** YAML/TSV parsers and Input Normalization.
- **Core Domain:** Tree construction, Order management, and Structural Validation.
- **Infrastructure Layer:** DB transaction management and Snapshot creation.

## 4. Error Model
- Uses standard **Core Error Codes**.
- Specific codes for import: `IMPORT_INVALID_FORMAT`, `IMPORT_KEY_COLLISION`, `IMPORT_DEPTH_MISMATCH`.
- Any error during any step triggers a total transaction rollback.
