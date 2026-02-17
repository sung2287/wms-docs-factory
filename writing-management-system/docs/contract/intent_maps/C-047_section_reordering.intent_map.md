# C-047: Section Reordering Intent Map

## 1. Intent-Reaction Mapping

| User Intent | UI Action | System Reaction |
| :--- | :--- | :--- |
| **Move Section to New Chapter** | Drag Section `S` to Chapter `C2` | Remove from `C1`, Add to `C2`. **Regenerate S.external_key**. Set **S.review_required = true** (if completed). |
| **Move Chapter to New Part** | Drag Chapter `CH` to Part `P2` | Recursive: Regenerate keys for `CH` and all its Sections. Set **review_required = true** for all completed nodes in subtree. |
| **Reorder within Chapter** | Drag Section `S1` below `S2` | Update `children` array order. No metadata cascade. |

## 2. Transition Workflow
1. **Selection:** User drags a node to a valid drop target.
2. **Execution:** UI performs an optimistic move.
3. **Cascading Logic:** System recursively computes new `external_keys` for the subtree.
4. **Compliance Logic:** System flags affected `completed` nodes as `review_required`.
5. **Commit:** Save the new structural state as a single snapshot.
