# B-022: Node State Visualization Contract

## 1. Objective
Define the pure logic for determining the visual state of a node based on its `writing_status`, `review_required` flag, and session dirty state.

## 2. Visual State Mapping Logic

```typescript
type VisualStatus = "EMPTY" | "COMPLETED" | "REVIEW_REQUIRED" | "DIRTY_COMPLETED" | "DIRTY_EMPTY";

function calculateVisualStatus(
  writingStatus: "empty" | "completed",
  reviewRequired: boolean,
  isDirty: boolean
): VisualStatus {
  if (reviewRequired) return "REVIEW_REQUIRED";
  
  if (writingStatus === "completed") {
    return isDirty ? "DIRTY_COMPLETED" : "COMPLETED";
  }
  
  return isDirty ? "DIRTY_EMPTY" : "EMPTY";
}
```

## 3. Indicator Priority
1. **REVIEW_REQUIRED** (Highest): Must signal design mismatch regardless of completion.
2. **DIRTY**: Must signal unsaved session progress.
3. **WRITING_STATUS**: Basic progress state.

## 4. Determinism
The visual status must be computed reactively from the state store without side effects.
