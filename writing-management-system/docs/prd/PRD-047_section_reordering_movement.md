# [PRD-045] Section Reordering & Structural Movement

## 1. Objective
워크스페이스 트리 구조 내에서 Section의 순서 변경 및 부모 변경 등 구조 편집 기능을 정의한다.

## 2. In Scope
- 동일 부모 내 Section 순서 변경 (Reorder)
- 부모 노드 변경 (Move/Reparenting) 및 Subtree Cascading
- 구조 변경에 따른 메타데이터 자동 갱신

## 3. Out of Scope
- 복수 노드의 대규모 일괄 이동
- 이동 시 발생하는 복잡한 충돌의 자동 해결

## 4. 구조 변경 규칙

### 4.1 Reorder (동일 부모 내)
- 노드 이동 시 해당 부모 하위의 모든 자식 노드에 대해 `order_int`를 재할당한다.
- 이동 완료 즉시 신규 스냅샷을 생성한다.

### 4.2 Move (부모 변경 & Subtree Cascading)
- **Cascading Key Regeneration**: 노드의 부모가 변경될 경우, **해당 노드뿐만 아니라 하위의 모든 자식 노드(Descendants)의 `external_key`가 새로운 경로에 맞춰 재귀적으로 재생성된다.**
- **Review Propagation**: 부모 변경으로 인해 상속받는 `effective_design_spec`이 변하므로, **이동된 노드 및 그 하위의 모든 `completed` 상태 섹션들의 `review_required`를 `true`로 전환한다.**
- **Atomic Transaction**: 키 재생성, 리뷰 상태 전파, 신규 스냅샷 생성은 단일 트랜잭션 내에서 원자적으로 수행되어야 한다.

### 4.3 정합성 유지
모든 구조 변경은 `lineage_id`를 유지하며 수행되므로, 차후 Re-import 시에도 정체성이 보존된다.

## Revision Note (v1.1)
- 부모 변경 시 하위 모든 노드의 `external_key`가 재생성되는 Subtree Cascading 규칙을 명문화함.
- 구조 변경에 따른 리뷰 상태 전파 범위와 트랜잭션 원자성 정책을 확립함.
