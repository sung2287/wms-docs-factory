# C-043: Conflict Comparison Intent Map

## 1. Objective
Map the transition from a failed save due to state conflict (Stale Save) to a resolved state through the Comparison UI.

## 2. Intent-Reaction Mapping

| User Intent | Trigger / UI Action | System Reaction |
| :--- | :--- | :--- |
| **Resolve Conflict** | API returns `409 Conflict` | Transition Workspace to **Comparison Mode**. Lock Editor. |
| **Compare Content** | View Side-by-Side | Execute `B-043 compareParagraphBlocks`. Render Diff. |
| **Discard Local Work**| Click "Refresh" | Drop `Draft`. Update local `rawText` with `Head`. Re-init Editor. |
| **Force My Work** | Click "Override" | Compute draftNormalized = normalize(join(draftBlocks)) Dispatch draftNormalized with parent = latest head_snapshot_id. |
| **Abandon** | Click "Cancel" | Return to Editor preserving the pre-conflict editor state. State MUST remain unchanged from the moment conflict was detected. Warning: "Still out of sync". |

**Deterministic Preparation Rule:**
- headBlocks MUST be computed as split(normalize(serverRawText)).
- draftBlocks MUST reflect the exact UI block array at conflict time.
- No additional normalization or mutation is allowed during comparison preparation.

## 3. Resolution Workflow
1.  **Detection:** Save fails with 409. Payload includes the current Server `rawText`.
2.  **Preparation:**
    - `headBlocks = split(normalize(serverRawText))`
    - `draftBlocks = currentUIBlocks`
    - draftBlocks MUST NOT be recomputed from rawText during conflict mode.
    - draftBlocks MUST represent the exact in-memory UI state at conflict detection.
3.  **Visualization:** Render `DiffResult` using Side-by-Side layout.
4.  **Action: Override:**
    - The system attempts to save the Draft again, explicitly targeting the new `head_snapshot_id` as the parent.
    - If successful, `writing_status` remains "draft" (unless it was a completion attempt).

    **Parent Consistency Rule:**
    - Override save MUST reference the latest head_snapshot_id received in the 409 response.
    - If the head changes again before override commit, the system MUST repeat conflict detection.

    **Override Determinism Rule:**
    - draftNormalized = normalize(join(draftBlocks))
    - headNormalized = normalize(serverRawText)
    - If draftNormalized === headNormalized, comparison mode MUST exit without creating a new snapshot.

5.  **Action: Refresh:**
    - The system overwrites local state with the Server content.
    - The UI block array is re-initialized from the new Server `rawText`.

**Refresh Invariant:**
- After refresh, blocks MUST be reinitialized strictly via: split(normalize(serverRawText)).

**Cancel Invariant:**
- Exiting comparison mode via Cancel MUST NOT modify: (1) draftBlocks (2) lastSavedNormalizedText (3) serverRawText reference

**Overlay Invariant:**
- Comparison Mode MUST behave as a pure overlay.
- Entering and exiting Comparison Mode MUST NOT alter editor state.
