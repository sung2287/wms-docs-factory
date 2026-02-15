# PRD-020: TOC/Tree 연결 최소치 — Node 1:1 ↔ Snippet 링크 + TOC 순서 출력

---

## 1. 목적 (Purpose)

PRD-016~019에서 고정된 Snippet 중심 구조를 유지한 상태에서,
Tree(TOC)와 Snippet을 최소 수준으로 연결한다.

이 PRD의 목표는 다음 두 가지다:

1. TreeNode가 Snippet을 1:1로 참조할 수 있게 한다.
2. Viewer에서 TOC 순서대로 Snippet을 출력할 수 있게 한다.

※ SnippetPool의 기존 동작(PRD-016/018/019)은 변경하지 않는다.

---

## 2. 범위 (Scope)

### 2.1 데이터 모델 확장

- TreeNode에 다음 필드를 추가한다:

```
linkedSnippetId?: string
```

- 의미:
  - 해당 노드가 연결된 Snippet의 ID
  - 선택적(optional) 필드 (없을 수 있음)
  - 하나의 Snippet이 여러 Node에 연결되는 것을 허용한다 (재사용 가능)
  - 역참조는 허용하지 않는다 (Snippet → Node 금지)


### 2.2 Viewer 확장 (탐색기형)

Viewer는 탐색기(Explorer)형 레이아웃을 제공한다.

- 좌측 패널: Tree 탐색
  - 트리 구조를 표시한다.
  - 번호(자동 생성 번호)를 함께 표시한다.
  - 어떤 노드든 본문(Snippet)이 있을 수도, 없을 수도 있다.
    - 예: “1장”, “1절”, 최하위 노드도 작성 전이면 비어 있을 수 있다.

- 우측 패널: 선택 노드 본문 뷰
  - 좌측에서 선택한 노드의 linkedSnippetId를 통해 Snippet을 조회한다.
  - Snippet이 존재하면 kind별 최소 스타일로 렌더한다.
  - Snippet이 없거나(미연결) / dangling이면 placeholder를 표시한다.

※ ‘TOC 순서대로 전체 문서 일괄 출력’은 이 PRD의 범위가 아니다.


### 2.3 번호(넘버링) 표시

- 좌측 Tree 표시에서 자동 번호를 렌더한다.
- 번호 생성 로직은 기존 Tree Numbering 규칙(이미 고정된 규칙/렌더러)을 재사용한다.
  - (정확한 모듈/함수는 구현 단계에서 현재 코드베이스 기준으로 연결)


### 2.4 Dangling 처리

- TreeNode가 참조하는 linkedSnippetId가 존재하지 않을 경우(삭제됨 등):

  - 저장/로드는 실패하지 않는다.
  - 검증 에러로 차단하지 않는다.
  - 우측 패널 본문 뷰에서 다음과 같이 표시한다:

```
"삭제된 내용입니다"
```

- 본 PRD 범위에서는 Snippet 삭제 시 TreeNode의 linkedSnippetId를 자동 정리(cleanup)하지 않는다.
- 장기적으로 orphan 참조 정리 또는 Dangling 노드 관리 기능은 별도 PRD로 다룬다.

또는 노드에 본문이 아예 연결되지 않은 경우(미작성/미연결)는:

```
"내용이 없습니다"
```

(문구는 구현에서 고정)


### 2.5 Tree 상태 표시 (UX 보완)

- 좌측 트리에서 각 노드의 상태를 시각적으로 구분할 수 있어야 한다.
  - Snippet 연결됨
  - Snippet 미연결
  - Dangling (삭제된 참조)
- 구체적 아이콘/스타일은 구현 단계에서 결정하되,
  "연결 여부를 클릭 없이 식별 가능"해야 한다.


### 2.6 Snapshot 정책

- PRD-017 snapshot 구조를 변경하지 않는다.
- tree / snippetPool은 기존 구조를 유지한다.
- 링크 정보는 tree 내부(linkedSnippetId)에 포함된다.


---

## 3. 성공 기준 (Success Criteria)

1. Node에 Snippet 연결 후 Save → Load 시 링크 유지
2. TOC 순서 변경 시 Viewer TOC 모드 출력 순서 즉시 반영
3. Snippet 삭제 후 Viewer에서 placeholder 정상 표시
4. 기존 Viewer v1 동작이 깨지지 않음


---

## 4. 비범위 (Out of Scope)

- Workspace 다중 관리
- Publish / Strict Validation
- Snippet ↔ Node 자동 동기화 로직
- RAG / 검색 / 의미 분석
- Dangling 저장 차단 정책


---

## 5. 불변 선언 (Invariants)

1. SnippetPool은 SSOT가 아니다.
2. Tree는 구조의 SSOT이다.
3. 참조 방향은 Tree → Snippet 단방향이다.
4. Viewer v1 동작은 변경하지 않는다.
5. Snapshot 스키마는 변경하지 않는다.


---

## 6. 구현 순서 (Minimal Risk Order)

1. TreeNode 모델 확장
2. Core에서 Tree → Snippet resolve 함수 작성
3. Viewer TOC 모드 렌더 구현
4. Dangling 처리 추가
5. UI 토글/라우트 연결


---

## 7. 테스트 요구사항 (Intent 고정)

- Node ↔ Snippet 1:1 연결 테스트
- Save → Load 링크 무결성 테스트
- TOC reorder → 출력 순서 반영 테스트
- Dangling degrade 테스트
- Viewer v1 회귀 테스트

- 재사용 시나리오 테스트 추가:
  - 하나의 Snippet을 두 개 이상의 Node에 연결했을 때
    - Snippet 내용 수정 시 모든 연결 노드에 동일하게 반영되는지
    - 특정 Node에서 연결 해제 시 다른 Node에는 영향이 없는지

- resolve 로직은 선택된 Node 기준으로만 동작해야 하며,
  불필요한 전체 Snippet 순회가 발생하지 않음을 확인한다.


## 8. 결정 사항 (Locked Decisions) 결정 사항 (Locked Decisions)

### 8.1 Node 생성 시 Snippet 자동 생성 여부

- 자동 생성하지 않는다.
- Node는 기본적으로 "빈 노드"로 생성된다.
- Snippet은 별도 버튼을 통해 명시적으로 생성/연결한다.
- 하나의 Node에 Snippet은 0 또는 1개 연결 가능하다.
- Snippet은 메모/콘텐츠 블록 개념이며, 전역적으로 복수 생성 가능하다.


### 8.2 Snippet 생성 방식

- Snippet은 버튼을 통해 생성한다.
- 여러 개 생성 가능하다.
- 특정 Node에 연결할지 여부는 명시적 동작으로 수행한다.


### 8.3 Tree UX 구조

- Tree는 VSCode 탐색기와 유사한 구조를 따른다.
- 자동 정렬은 하지 않는다.
- Node 위치는 수동으로 조절 가능해야 한다.
- 정렬 기준은 시스템이 강제하지 않으며, 사용자의 명시적 이동 조작을 따른다.


---

## 9. 완료 정의 (Definition of Done)

- 테스트 PASS
- Reviewer 판정 기록
- prd:close 성공
- main 병합 완료

---

End of PRD-020
 완료 정의 (Definition of Done)

- 테스트 PASS
- Reviewer 판정 기록
- prd:close 성공
- main 병합 완료

---

End of PRD-020

