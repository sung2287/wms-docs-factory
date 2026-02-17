# B-044: Effective Design Preview Contract

## 1. Objective
Define the pure logic for computing the "Effective DesignSpec" of a target node by traversing its ancestral hierarchy. This ensures that the writer sees all active constraints and guidelines inherited from Series, Volume, Part, and Chapter levels.

## 2. Pure Function: computeEffectiveDesignSpec

### 2.1 Interface
```typescript
/**
 * Computes the effective DesignSpec for a node by merging its spec with ancestors.
 * @param nodePath Array of nodes from Root (Series) to Leaf (Target Section)
 * @returns The resolved Effective DesignSpec
 */
function computeEffectiveDesignSpec(nodePath: Node[]): DesignSpec;
```

### 2.2 Merge Rules (PRD-036 Alignment)
1.  **Accumulate Fields:** (e.g., `constitution.rules`, `constraints.forbidden`)
    - Result = `unique(Union(Series.rules, Volume.rules, ..., Section.rules))`.
    - Order: Ancestor rules first, followed by local node rules.
2.  **Append Fields:** (e.g., `volume.notes`, `section.notes`)
    - Result = `Concatenate(Series.notes, ..., Section.notes)`.
3.  **Override Fields:** (e.g., `series.core_sentence`, `section.purpose`)
    - Result = The value from the closest node in the path (starting from target, moving up to root) that is not `null`.

## 3. Visual Source Mapping
The contract must allow the UI to identify the *source* of each rule (e.g., "This forbidden claim comes from Part 1").

## 4. Constraints
- **Read-only:** This function only reads from the hierarchy; it never modifies any node.
- **Determinism:** Given the same `nodePath`, the result must always be identical.
