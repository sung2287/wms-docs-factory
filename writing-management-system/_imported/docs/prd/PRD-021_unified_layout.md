# PRD-021: Unified Layout v1 — Tree + Editor 통합 화면

---

## 1. 목적 (Why)

저장 시스템 정교화 이전에, 사용자 사용 흐름을 고정한다.

현재 Web Skeleton + Editor v1 + Viewer v1은 기능은 존재하지만
"관리 프로그램"으로서의 일관된 사용 흐름이 확정되지 않았다.

본 PRD는 Tree 기반 탐색과 Snippet 편집을 하나의 화면 구조로 통합하여
이후 저장 모델(PRD-024~)의 기준 UX를 확정하는 것을 목표로 한다.

---

## 2. 범위 (Scope)

### 포함

1. 2-Pane Layout 고정
   - 좌측: Tree Panel
   - 우측: Editor Panel

2. 노드 선택 시 동작 고정
   - 노드 클릭 → 우측 패널에 연결된 Snippet 표시
   - 연결이 없을 경우 placeholder UI 표시

3. 연결 상태 시각 표시 (최소 버전)
   - 연결됨
   - 미연결

4. Snippet 생성 UX 보강
   - 미연결 노드에서 "Snippet 생성" 시
   - 해당 노드의 제목(Node Name)을 Snippet의 초기 제목으로 자동 제안
   - 생성 즉시 linkedSnippetId 연결

5. 기본 레이아웃 스타일 고정
   - 좌우 분할 비율 기본값 30:70
   - 향후 Resizer(드래그 조절) 확장을 고려한 구조 유지
   - 모바일 환경 대비 좌측 패널 Collapse 가능 구조 확보
   - 좌우 분할 비율 고정 (예: 30:70)
   - 스크롤 영역 분리

---

### 제외 (Not in Scope)

- 저장 전략 변경
- 스냅샷 정책 정의
- 백업/복구 로직
- 리치 텍스트 에디터 도입
- 드래그 앤 드롭 트리 편집

---

## 3. UI 구조 정의

### 전체 구조

```
┌──────────────────────────────────────┐
│ Top Bar (향후 Save 버튼 위치 확보)   │
├───────────────┬──────────────────────┤
│               │                      │
│   Tree Panel  │    Editor Panel      │
│               │                      │
│               │                      │
└───────────────┴──────────────────────┘
```

### Tree Panel

- 계층 구조 표시
- 각 노드에 상태 아이콘 표시 (최소 2종)
- 노드 클릭 시 선택 상태 강조

### Editor Panel

노드 선택 시:

1. linkedSnippetId 존재
   - 해당 Snippet 본문 표시

2. linkedSnippetId 없음
   - "Snippet이 연결되지 않았습니다" 메시지
   - "Snippet 생성" 버튼 노출

---

## 4. 상태 흐름 정의

### 상태 관리 원칙

- 최상위 Store에 `selectedNodeId` 단일 상태를 둔다.
- Editor Panel은 `selectedNodeId`를 구독(Subscribe)한다.
- `selectedNodeId` 변경 시:
  1. TreeState에서 해당 노드 조회
  2. linkedSnippetId resolve
  3. SnippetPool에서 Snippet 로드

- TreeState는 SSOT를 유지한다.
- Editor는 선택 상태를 구독하는 구조로 구현한다.

### 렌더링 최적화 원칙

- 노드 선택 시 전체 트리를 리렌더링하지 않는다.
- 선택된 노드와 Editor Panel만 업데이트되도록 메모이제이션 전략을 적용한다.

### 기본 흐름

### 기본 흐름

1. 사용자 접속
2. 기본 Workspace 로드
3. Tree 렌더
4. 노드 선택
5. Editor Panel 렌더

### Snippet 생성 흐름

1. 미연결 노드 선택
2. "Snippet 생성" 클릭
3. Snippet 생성
4. TreeState에 linkedSnippetId 설정
5. Editor Panel 즉시 편집 가능 상태

---

## 5. 저장 시스템과의 관계

본 PRD는 저장 모델을 변경하지 않는다.

그러나 다음을 확정한다:

- "사용자는 노드를 중심으로 작업한다"
- "Snippet은 노드에 연결된 편집 단위다"
- "하나의 화면에서 탐색과 편집이 동시에 이루어진다"
- "selectedNodeId 기반 상태 흐름이 저장 단위 설계의 기준이 된다"

추가 고려:

- Editor 입력을 즉시 SnippetPool에 반영할지
- 상단 Save 버튼 클릭 시 일괄 반영할지

이 결정은 PRD-024에서 확정한다.

이는 이후 저장 단위 정의(PRD-024) 시
"Workspace 전체 저장" 또는 "변경 감지 기반 저장"을 결정하는 기준 UX가 된다.

