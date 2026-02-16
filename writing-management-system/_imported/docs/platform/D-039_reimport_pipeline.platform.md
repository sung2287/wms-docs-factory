# Platform: Re-Import Pipeline

## 1. Re-import Orchestration
1. **Blueprint Parsing**: 엑셀을 읽어 `lineage_id` 기반의 임시 트리 구성.
2. **Identity Mapping**: 현재 Workspace(Active + Archive)에서 `lineage_id` 매칭 수행.
3. **Diff Generation**:
   - `B-039 2` 섹션의 우선순위에 따라 Diff 목록 생성 및 정규화.

## 2. Transaction Execution Sequence
**REMOVE는 반드시 가장 먼저 적용되어야 하며**, 다음의 엄격한 순서를 준수하여 트랜잭션을 실행한다:
1. **REMOVE**
2. **REKEY**
3. **MOVE**
4. **REORDER**
5. **UPDATE_SPEC**
6. **UPDATE_BODY**
7.x **Propagation Root Determination**
   - Collect all target nodes from UPDATE_SPEC diffs as candidate roots.
   - If an ancestor–descendant chain exists, prune all descendant nodes from the candidate set, retaining only the ancestor.
   - The final root set MUST be sorted deterministically (e.g., by `lineage_id` ascending).
7. **Review Propagation**
   Review Propagation MUST operate exclusively on the finalized root set determined in Step 7.x.
   Review Propagation SHALL NOT reference the raw UPDATE_SPEC diff list directly.
   - Traverse descendant trees based on the final root set.
   - Results MUST be identical regardless of the execution order of roots in the set.
8. **Snapshot Commit**

## 3. Phase Separation
**Structural Phase (REMOVE, REKEY, MOVE, REORDER)**와 **Data Phase (UPDATE_SPEC, UPDATE_BODY)**는 서로 혼재될 수 없다. 데이터 업데이트는 트리 위상(Topology)이 완전히 안정화된 이후에만 실행된다.

## 4. Archive Recovery Flow
- 매칭 과정에서 Archive 노드가 발견되면 `is_archived = false` 처리 후 새로운 부모 노드 하위로 이동시킨다. 이는 `MOVE`의 특수 사례로 처리한다. 부모 노드 식별은 항상 `lineage_id`를 기준으로 한다.
