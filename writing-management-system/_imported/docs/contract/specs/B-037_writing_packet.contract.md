# Contract: Writing Packet Extraction

## 1. Archive Exclusion Rule
Archive 상태의 노드는 Packet 추출 공정에서 완전히 격리된다.
- **Exclusion**: `is_archived == true`인 노드는 어떠한 경우에도 Writing Packet의 대상이 될 수 없다.
- **Context Exclusion**: Archive 노드는 `hierarchy_context` 및 `neighborhood_context` 구성 요소에서 사전 배제된다.

## 2. Determinism & Traversal
Packet 생성의 결정론은 다음 순서에 의해 보장된다.
1. **Filtering**: 트리 순회 시작 전 모든 `is_archived == true` 노드를 검색 대상에서 제외한다.
2. **Collection**: 대상 섹션의 유효 조상 및 인접 노드를 `order_int` 순으로 수집한다.
3. **Composition**: 수집된 노드들만을 대상으로 PRD-036의 병합 규칙을 적용한다.

## 3. Effective Spec Property
- Packet에 포함된 `effective_design_spec`은 해당 시점의 Snapshot 상태를 반영한 정규화된 읽기 전용 뷰이다.
