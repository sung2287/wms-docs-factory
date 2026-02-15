# D-020_toc_snippet_link.platform.md

## 1. 구현 아키텍처 (Implementation Architecture)

### 1.1 Core Layer (Business Logic)
- **Snippet Resolver:** `(treeRoot: TreeNode, targetNodeId: string, pool: SnippetPool) => SnippetResult`
  - 트리 루트에서 targetNodeId를 탐색하여 해당 노드를 찾고,
  - 해당 노드의 linkedSnippetId를 통해 Pool에서 Snippet을 추출한다.
  - 결과값(`SnippetResult`)은 `SUCCESS`, `UNLINKED`, `DANGLING` 상태와 함께 데이터를 반환한다.

### 1.2 Adapter Layer (State Management)
- **Selection State:** 현재 사용자가 선택한 Node ID를 관리한다.
- **Derived State:** 선택된 ID가 변경될 때마다 Core의 Resolver를 호출하여 우측 패널에 공급할 데이터를 계산한다.

### 1.3 UI Layer (Presentation)

#### Left Panel: Tree Navigator
- **Numbering:** 트리의 계층 구조에 따라 `1.`, `1.1.`, `1.1.1.` 식의 번호를 동적으로 계산하여 표시한다.
- **Status Indicator:** 각 노드 옆에 연결 상태 아이콘을 표시한다.
  - ✅ (Connected) / ⚪ (Unlinked) / ⚠️ (Dangling)

#### Right Panel: Content Viewer
- **Snippet Renderer:** Snippet의 `kind`에 따라 적절한 컴포넌트로 렌더링한다.
- **Placeholder Handling:**
  - `Unlinked` 시: "내용이 없습니다. (Snippet 연결 필요)"
  - `Dangling` 시: "삭제된 내용입니다. (참조 오류)"

## 2. 성능 및 제약 (Performance & Constraints)

- **Targeted Resolution:** 전체 트리를 매번 순회하지 않고, 사용자가 클릭한 특정 노드에 대해서만 Snippet 조회를 수행한다.
- **No Heavy Caching:** Snippet Pool은 메모리에 이미 로드되어 있으므로 별도의 복잡한 캐싱 레이어는 구현하지 않는다. (Pure Function 기반의 Memoization 수준으로 충분)
- **Batch Render 금지:** 본 단계에서는 모든 Snippet을 한 화면에 리스트로 보여주는 기능을 구현하지 않으며, 단일 노드 뷰에 집중한다.

## 3. 동작 흐름 (Flow)

1. 사용자가 좌측 트리에서 노드를 선택한다.
2. `selectedNodeId` 상태가 업데이트된다.
3. UI는 `selectedNode.linkedSnippetId`를 확인한다.
4. `snippetPool[linkedSnippetId]`를 조회한다.
5. 조회 결과에 따라 우측 패널의 렌더링 분기를 결정한다.
   - 데이터 존재 → Content 표시
   - ID 없음 → "미연결" 표시
   - ID는 있으나 데이터 없음 → "Dangling" 표시
