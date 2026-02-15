# D-034_markdown_import.platform.md

## 1. Execution Environment
- The import tool MUST run in a **Sandbox** to ensure safe recursive scanning of the host file system.
- It operates as a **Core-Managed Adapter**.

## 2. Application Flow

### Step 1: Folder Scanner
- Recursively traverses the input directory.
- Filters for `*.md` files.
- Identifies folder structures to determine grouping nodes.

### Step 2: Key Normalizer
- Extracts filenames and strips extensions.
- Converts all hyphens (`-`) to dots (`.`).
- Validates that segments are strictly numeric.

### Step 3: Parent Auto-Generator
- Analyzes the set of normalized keys.
- Identifies missing intermediate levels (e.g., if `1.2.3` exists but `1.2` does not).
- Pre-calculates the necessary virtual nodes to complete the hierarchy.

### Step 4: Validation Engine
- Checks for duplicate normalized keys.
- Ensures no mixed-style collisions (different source names mapping to the same key).
- Verifies structural integrity (no cycles).

### Step 5: Tree Builder
- Converts the normalized set into a `NodeTree`.
- Assigns UUID `node_id`s.
- Establishes parent/child relationships based on key segments.
- Calculates `order_int` using **Natural Numeric Sort**.

### Step 6: Snippet Builder
- Creates a `Snippet` (UUID) for every node.
- Reads file content for file-based nodes.
- Initializes `""` for auto-created and folder-grouping nodes.

### Step 7: Snapshot Writer
- Atomically persists the `Workspace`, `NodeTree`, and `SnippetPool`.
- Creates the initial `Snapshot`.
- Transitions state to `Workspace SSOT`.

## 3. Layer Boundaries
- **Adapter Layer:** FS Scanning, Path normalization, Key extraction.
- **Core Domain:** Hierarchy computation, Parent auto-generation, Natural sorting logic.
- **Infrastructure:** UUID generation, DB Transaction management, Snapshot persistence.

## 4. Error Handling
- Errors MUST follow the **Core Error Model**.
- Specific codes: `IMPORT_INVALID_KEY`, `IMPORT_DUPLICATE_KEY`, `IMPORT_STYLE_COLLISION`.
- Any error MUST trigger a complete rollback of the creation transaction.
