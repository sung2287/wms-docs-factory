# B-051: Writing Workspace UI Polish Pack Contract
**Status: Draft**

## 1. UI State Model
UI 상태 관리를 위한 데이터 구조를 정의한다.

- **TreeCollapseState:** `{ [nodeId: string]: boolean }` (LocalStorage 저장)
- **ThemeTokens:** JSON 기반 전역 컬러/간격/폰트 크기 정의.
- **DividerVisibility:** `hidden` (Default) | `hover` | `resizing`
- **ScrollbarStyle:** `light` | `dark` (테마에 종속)

## 2. Normative Rules
동작과 시각적 형태에 대한 강제 규범을 정의한다.

### 2.1 Paragraph Behavior (MUST)
- **MUST:** 모든 문단(Paragraph)은 내부 스크롤바를 가져서는 안 된다.
- **MUST:** 텍스트 입력 시 높이가 자동으로 늘어나는 `Auto-grow` 메커니즘을 적용해야 한다.
- **MUST:** 입력 시 레이아웃 흔들림(Layout shift)을 최소화해야 한다.

### 2.2 Tree Explorer Interaction (MUST/MUST NOT)
- **MUST NOT:** 트리 탐색기 UI에 '위(Up)/아래(Down)' 이동을 위한 별도의 버튼을 배치하지 말 것.
- **MUST:** 드래그 핸들(`⋮⋮`)은 노드에 마우스를 올린(`hover`) 상태에서만 시각적으로 노출되어야 함.
- **MUST:** 하위 노드를 접고 펼칠 수 있는 인터랙션(Toggle)을 제공해야 함.
- **MUST NOT:** 노드를 접는 행위(Collapse)가 실제 데이터 트리 구조(Canonical Tree State)를 변경해서는 안 됨.
- **MUST:** Collapse 상태는 Reorder 계산(Projected Index Determination)에 어떠한 영향도 주어서는 안 된다. Collapse는 렌더 레벨의 시각적 필터일 뿐이며, PRD-048의 형제간 이동(Sibling-only) 및 Drop-commit 정책에 영향을 주어서는 안 된다.
- **MUST:** 접힘 상태는 브라우저 새로고침 후에도 유지되어야 함 (`localStorage` 활용).
- **MUST:** 트리 순서 변경(Reorder)은 기존 PRD-048의 '형제간 이동(Sibling-only)' 및 '드롭 시 확정(Drop-commit)' 원칙을 유지해야 함.

### 2.3 Divider & Layout (MUST)
- **MUST:** 평상시 좌/우 영역 구분선(Divider)을 투명하거나 배경색과 동일하게 처리하여 보이지 않게 해야 함.
- **MUST:** 구분선 영역에 마우스를 올리거나 리사이징 시에만 시각적 피드백(색상 변경 등)을 제공해야 함.
- **MUST:** 스크롤바는 콘텐츠가 부족할 때는 보이지 않아야 하며, 필요할 때만 나타나야 함.

### 2.4 Theme & Visual (MUST)
- **MUST:** 모든 UI 색상은 중앙 집중형 테마 토큰(CSS Variables)을 통해 제어되어야 함.
- **MUST NOT:** 인라인 스타일이나 하드코딩된 색상 값을 사용하지 말 것.
- **MUST:** 다크 모드에서의 텍스트 대비(Contrast ratio)를 충분히 확보하여 가독성을 개선해야 함.
- **MUST:** 커스텀 스크롤바 스타일은 WebKit 및 Firefox 호환성을 고려하여 구현해야 함.

## 3. Dependencies / Alignment
- **PRD-048 (Tree Drag Reorder):** 트리 재정렬 로직은 수정하지 않으며, UI 표현 방식만 간소화한다.
- **PRD-049 (Minimal Document Mode):** 미니멀한 문서 작성 환경의 연장선상에서 트리 탐색기와 구분선의 UI를 다듬는다.
- **PRD-042 (Writing Workspace):** 워크스페이스 전체 레이아웃 구조 내에서 테마 토큰과 구분선 규칙을 적용한다.

## 4. Prohibitions (Forbidden UI)
- 문단 내부의 명시적인 수동 스크롤 조작 UI 금지.
- 트리 탐색기에서의 '카드' 형태 블록 디자인 금지.
- 상시 노출되는 좌/우 영역 구분선 금지.
