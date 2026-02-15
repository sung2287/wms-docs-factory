# D-027: Schema Version / Migration Freeze Platform

## 1. Scope
- Migration registry and version chain implementation.
- Transactional transformation logic.
- Metadata requirements for migrated snapshots.

## 2. Non-goals
- Implementing specific UI for migration progress.

## 3. Migration Registry Concept
The system should maintain a registry of migration functions:
```typescript
const MigrationRegistry = {
  'v1_to_v2': (payload) => { /* transform logic */ return newPayload; },
  'v2_to_v3': (payload) => { /* transform logic */ return newPayload; },
};

const SupportedVersions = ['v1', 'v2', 'v3'];
```

## 4. Sequential Execution Logic
When migrating from `startVersion` to `targetVersion`:
1. Find the path in the version chain.
2. For each step:
   - Apply the registry function to the payload.
   - Update the internal version tracker.
3. Once all steps are complete, proceed to the final INSERT.

## 5. Transactional Migration Procedure
```typescript
async function migrateSnapshot(sourceSnapshot, targetVersion) {
  await db.transaction(async (tx) => {
    let currentPayload = sourceSnapshot.payload_json;
    let currentVersion = sourceSnapshot.schema_version;

    while (currentVersion !== targetVersion) {
      const migrator = getMigrator(currentVersion);
      currentPayload = migrator(currentPayload);
      currentVersion = getNextVersion(currentVersion);
    }

    const newSnapshot = await tx.snapshots.insert({
      workspace_id: sourceSnapshot.workspace_id,
      payload_json: currentPayload,
      schema_version: targetVersion,
      migrated_from_snapshot_id: sourceSnapshot.id
    });

    // NOTE:
    // head_snapshot_id must only be updated when migration
    // is part of an explicit Restore or Upgrade operation.
    // Historical/background migration must not implicitly move the active head.
    await tx.workspaces.update(sourceSnapshot.workspace_id, {
      head_snapshot_id: newSnapshot.id
    });
  });
}
```

### Head Pointer Update Policy

- Updating the Workspace `head_snapshot_id` must only occur when migration is part of an explicit Restore or Upgrade operation.
- Migration logic must not implicitly move the active head unless explicitly defined by the calling context.
- Historical or background migrations must preserve the existing head pointer unless intentionally upgrading the active state.

## 6. Implementation Constraints
- **Immutability**: Ensure the migration logic does not modify existing records.
- **Traceability**: The `migrated_from_snapshot_id` field must be used to track history.

---
### 정합성 체크리스트
- [x] PRD 번호 일치 (027)
- [x] Migration 레지스트리/체인 개념 명시
- [x] 트랜잭션 단위 수행 명시
- [x] 원본 Snapshot 수정 금지 명시
- [x] migrated_from_snapshot_id 필드 활용 포함
