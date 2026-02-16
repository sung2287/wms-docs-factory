# Platform: Lightweight TOC Import

## 1. Application Flow
1. **Source Parser**: 입력을 받아 트리 구조의 원본 노드 배열을 추출한다.
2. **Depth Normalizer & Sorter**: 
   Sort order must be:
   1) Depth ASC
   2) external_key natural numeric sort (dot segments compared numerically)
   3) stable tie-breaker = original input order
3. **Identity Generator**: 각 노드에 대해 고유한 `node_id`와 `lineage_id`(UUID)를 내부적으로 생성한다.
4. **Hierarchy Builder**: `external_key`의 부모-자식 관계를 분석하여 `parent_id`를 할당한다.
5. **Persistence Orchestrator**: 
   - Workspace 및 노드 데이터를 원자적 트랜잭션으로 저장한다.
   - 모든 노드에 빈 Snippet을 생성하여 1:1 관계를 수립한다.
6. **Snapshot Initializer**: `"Lightweight TOC Import"` 메시지와 함께 Snapshot #1을 생성한다.

## 2. Core Logic (DesignSpec)
- 생성되는 모든 노드의 DesignSpec은 초기 빈 값(Empty Spec)으로 설정된다.

## 3. Atomic Transaction Boundary
- Workspace 생성부터 최초 Snapshot 커밋까지의 전 과정은 단일 트랜잭션 내에서 처리되어야 하며, 실패 시 어떠한 노드도 생성되지 않아야 한다.
