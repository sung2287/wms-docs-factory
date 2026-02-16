# Contract: Re-Import & Structural Diff

## 1. Identity Anchor: Lineage ID
재유입(Re-import) 시 노드의 동일성 판정은 엑셀 템플릿에 명시된 `lineage_id`를 최종 앵커(Identity Anchor)로 사용한다.
- **Identity Consistency**: `external_key`가 변경되더라도 `lineage_id`가 동일하면 해당 노드는 동일한 실체로 간주한다.
- **REKEY Definition**: `lineage_id`는 유지되나 `external_key`가 변경된 경우를 의미한다.
- **MOVE Definition**: **자식(Child)의 `lineage_id`는 유지되나 부모(Parent)의 `lineage_id`가 변경된 경우**로 정의한다. `external_key`는 위치 표현일 뿐 동일성 판정 기준이 아니다.
- **MOVE & REKEY Sequence**: REKEY 이후 MOVE가 수행될 경우, 부모 매칭은 변경된 `external_key`가 아니라 **부모의 `lineage_id`를 기준으로 수행**한다.
- **Archive Recovery**: Archive 영역 내의 노드도 `lineage_id`가 일치할 경우 복구(Restore) 대상으로 판정한다.

## 2. Diff Normalization Rules (Priority)
다수의 변경이 겹칠 경우 다음 우선순위에 따라 순차적으로 적용한다.
1. **Exclusion**: `REMOVE`가 확정된 노드는 이후의 모든 `UPDATE_SPEC`, `UPDATE_BODY` 대상에서 즉시 제외한다.
2. **Identity Update**: `REKEY`를 최우선으로 적용하여 구조 내 정체성을 확보한다.
3. **Structural Move**: `REKEY` 이후 `MOVE`(부모 변경)를 적용한다.
4. **Sibling Reorder**: `MOVE` 적용 후 동일 부모 내에서 `REORDER`(순서 변경)를 적용한다.
5. **Spec Update**: 모든 구조적 변경이 완료된 상태에서 `UPDATE_SPEC`을 반영한다.
6. **Body Update**: 최종 단계에서 마크다운 파일을 통한 `UPDATE_BODY`를 수행한다.

## 3. Review Propagation Timing
**Review propagation은 엄격하게 `UPDATE_SPEC` 적용 이후에만 실행되며, 구조적 변경 단계(REMOVE, REKEY, MOVE, REORDER) 중에는 절대 실행되지 않는다.**

## 3.1 Propagation Root Set
1. Candidate root set MUST be initialized with all nodes classified under the `UPDATE_SPEC` diff.
2. If an ancestor–descendant relationship exists within the candidate set, only the highest ancestor SHALL remain as a propagation root; all descendant nodes within that chain MUST be excluded from the root set.
3. The generation of the Propagation Root Set MUST be deterministic and independent of diff generation or sorting order.
4. Review propagation SHALL be executed independently for each root in the set, and the final system state MUST remain idempotent.
5. Propagation from a root MUST NOT affect unrelated branches outside its own descendant tree.
6. Duplicate entries of the same node within the candidate set MUST be collapsed into a single root before ancestor pruning.

The final Root Set SHALL be the only input to the Review Propagation phase.

## 4. Error Constraints
- **Identity Collision**: 하나의 노드에 대해 `REMOVE` 및 `REKEY`가 동시에 발생할 수 없으며, 감지 시 즉시 에러 처리한다.
- **Lineage Duplication**: 엑셀 내 중복된 `lineage_id`는 허용되지 않는다.

## 5. Archive Recovery
- 엑셀에 존재하나 현재 Active Tree에 없고 Archive에 존재하는 `lineage_id` 발견 시, 해당 노드를 Active 상태로 복구하고 Spec/Body를 업데이트한다.
