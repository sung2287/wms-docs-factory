# D-051: Writing Workspace UI Polish Pack Platform
**Status: Draft**

## 1. Responsibilities (Screen Components)
각 UI 영역의 책임을 명확히 분리한다.

### 1.1 Centralized Theme Tokens (Registry)
- **책임:** 모든 스타일 토큰 정의 및 CSS 변수 배포.
- **기능:** JSON 기반 테마 정의 파일을 통해 테마 토큰 로드.
- **제약:** 렌더러 부트스트랩 단계에서 CSS 변수를 `:root`에 주입한다.

### 1.2 Document Canvas & Paragraphs (Editor)
- **책임:** 문단 자동 높이 조절 및 스크롤바 제어.
- **구현:** `Auto-grow Textarea` 기법을 사용하여 텍스트 길이에 따라 `height` 속성을 조절한다.
- **제약:** 개별 Paragraph의 `overflow` 속성은 `hidden`으로 강제하며, 전역 Canvas 영역에서만 스크롤이 발생하도록 한다.

### 1.3 Tree Explorer & Collapse (Navigation)
- **책임:** 트리 노드 상태 관리 및 드래그 핸들 가시성 제어.
- **구현:** 
    - 노드 접힘 상태는 워크스페이스별로 구분된 키(`wms_v1_tree_collapse_<workspaceId>`)를 사용하여 `localStorage`에서 관리한다.
    - `<workspaceId>`는 현재 활성 워크스페이스 컨텍스트에 대응하며, 이를 통해 워크스페이스 간 UI 상태 충돌을 방지한다.
    - 버전 접두사(`v1`)는 향후 데이터 마이그레이션 안정성을 위해 유지한다.
    - Collapse는 단순 CSS display:none 처리 방식이 아니라, 렌더 단계에서 조건부로 children을 출력하지 않는 방식으로 구현한다. 이 방식은 DOM 기반 reorder 계산과의 충돌 가능성을 방지하기 위함이다.
    - Hover 시 CSS Selector를 통해 드래그 핸들(`opacity` or `display`)을 노출한다.

### 1.4 Workspace Divider (Layout Splitter)
- **책임:** 좌측 트리와 우측 문서 사이의 동적 구분선 시각화.
- **구현:** 
    - 마우스 이벤트를 감지하여 리사이징(Resizing) 중일 때만 색상을 변경한다.
    - 구분선 영역에 `hover` 가상 클래스를 적용하여 시각적 피드백을 제공한다.

## 2. Event Flows & State Transitions
- **Paragraph Resize:** `Paragraph.onInput` → 콘텐츠 높이 계산 → `textarea.style.height` 업데이트 → Canvas 스크롤바 동적 반영.
- **Tree Collapse Toggle:** `Node.ChevronClick` → `TreeCollapseState` 업데이트 → `localStorage` 저장 → 리액티브하게 하위 노드 렌더링 여부 결정.
- **Divider Interaction:**
    - `Divider.onMouseEnter` → `DividerVisibility = hover` → 시각적 하이라이트.
    - `Divider.onMouseDown` → `DividerVisibility = resizing` → 드래그 피드백 유지.
    - `Divider.onMouseUp` → `DividerVisibility = hidden`.
- **Theme Switch:** `ThemeAction` → CSS Variables 일괄 업데이트 → 전역 다크 모드 가독성 즉시 반영.

## 3. Testing Points (Visual & State Verification)
- **Auto-grow Integrity:** 장문의 텍스트 입력 시 개별 문단에 스크롤바가 생기지 않고 전체 캔버스가 부드럽게 스크롤되는지 확인한다.
- **Collapse Persistence:** 특정 노드를 접은 후 브라우저를 새로고침했을 때 해당 노드가 여전히 접힌 상태인지 검증한다.
- **Minimalist Tree Visuals:** 트리 탐색기에서 Up/Down 버튼이 사라졌는지, 그리고 드래그 핸들이 Hover 시에만 나타나는지 시각적으로 확인한다.
- **Dark Mode Readability:** 다크 모드 전환 시 텍스트와 배경 간의 대비가 충분한지(WCAG 기준 등) 확인하고, 하드코딩된 색상 누락 여부를 점검한다.
- **Scrollbar Consistency:** 커스텀 스크롤바가 라이트/다크 모드 각각의 디자인 톤에 맞게 변화하는지 확인한다.

## 4. Implementation Guidelines (Implementation Independent)
- **Themed Scrollbars:** `::-webkit-scrollbar` 및 Firefox의 `scrollbar-width`, `scrollbar-color` 속성을 활용하여 구현한다.
- **CSS Variables:** 모든 컴포넌트는 `--wms-bg-primary`, `--wms-text-main` 등 표준화된 변수명을 사용하여 테마 시스템에 결합되어야 한다.
- **localStorage Namespace:** `localStorage` 키는 `wms_v1_`과 같은 네임스페이스를 사용하여 충돌을 방지한다.
- **Layout Performance:** 
    - 문단 높이 조절 시 브라우저의 리플로우(Reflow)가 빈번하게 발생할 수 있으므로, 성능 최적화(Efficient layout calculation)를 고려한다.
    - Height synchronization must be performed using requestAnimationFrame-based measurement to minimize layout thrashing.
    - Debounce-based resizing is NOT permitted, as it degrades typing responsiveness.
