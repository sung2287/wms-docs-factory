# B-020_toc_snippet_link.contract.md

## 1. 개요 (Overview)
본 문서는 Tree(TOC) 구조와 Snippet(Content) 블록 간의 최소 연결 모델을 정의한다.
구조(Tree)와 내용(Snippet)을 분리하여 관리하며, Tree가 Snippet을 참조하는 단방향 연결 방식을 채택한다.

## 2. 데이터 구조 (Data Structure)

### 2.1 TreeNode 확장
`TreeNode` 인터페이스에 Snippet 참조 필드를 추가한다.

| 필드명 | 타입 | 필수 여부 | 설명 |
| :--- | :--- | :---: | :--- |
| `linkedSnippetId` | `string` | Optional | 연결된 Snippet의 고유 식별자 (string, ID 형식은 SnippetPool 규칙을 따른다) |

### 2.2 참조 규칙 (Reference Rules)
- **단방향 참조 (Unidirectional):** `TreeNode` → `Snippet` 방향으로만 참조한다.
- **다중 참조 허용 (Many-to-One):** 서로 다른 `TreeNode`들이 동일한 `linkedSnippetId`를 가질 수 있다.
- **Snippet 독립성:** Snippet 객체는 자신을 참조하는 Node에 대한 어떠한 정보도 가지지 않는다. (역참조 필드 금지)

## 3. 불변성 및 제약 사항 (Invariants & Constraints)

- **Schema Stability:** PRD-017에서 정의된 Snapshot의 최상위 구조(`tree`, `snippetPool`)는 변경하지 않는다.
- **No Back-references:** Snippet 데이터 모델에 Node ID를 저장하는 행위를 금지한다.
- **Dangling Reference Tolerance:** 참조하는 Snippet이 Pool에 존재하지 않더라도(`Dangling`), 데이터 로드 및 트래킹은 실패하지 않아야 한다.
- **Manual Ordering:** 트리의 노드 순서는 사용자의 수동 조작에 의해서만 결정된다. 시스템에 의한 자동 정렬(예: 가나다순, 생성일순)을 금지한다.
- **No Auto-cleanup:** Snippet이 삭제될 때 이를 참조하는 모든 Node의 `linkedSnippetId`를 즉시 null로 만드는 자동 정리 로직은 본 범위에 포함되지 않는다.

## 4. 인터페이스 정의 (Interfaces)

```typescript
interface TreeNode {
  id: string;
  name: string;
  children: TreeNode[];
  linkedSnippetId?: string; // 참조 필드 추가
  // ... 기존 필드 유지
}

interface SnippetPool {
  [snippetId: string]: Snippet;
}

interface WmsSnapshot {
  tree: TreeNode;
  snippetPool: SnippetPool;
  // ... 기존 필드 유지
}
```

## 5. 상태 정의 (State Definitions)

Viewer에서 `TreeNode`의 렌더링 상태는 다음 3가지 중 하나로 결정된다.

1. **Connected:** `linkedSnippetId`가 존재하고, 해당 ID의 Snippet이 `snippetPool`에 존재하는 상태.
2. **Unlinked:** `linkedSnippetId`가 존재하지 않는(undefined/null) 상태.
3. **Dangling:** `linkedSnippetId`는 존재하나, 해당 ID의 Snippet이 `snippetPool`에 없는 상태.
