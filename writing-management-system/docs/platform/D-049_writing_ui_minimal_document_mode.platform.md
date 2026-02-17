# D-049: Writing UI Minimal Document Mode Platform
**Status: Draft**

## 1. Responsibilities (Screen Components)
각 UI 영역의 책임을 명확히 분리한다.

### 1.1 Global UI Bar (System Logic)
- **책임:** 시스템 제어.
- **기능:** 사이드바 토글 버튼, 테마(Light/Dark/System) 선택 UI 포함.
- **제약:** 문서 내용(Canvas)에 직접적으로 영향을 주지 않으며, 전역 상태(Global State)만 관리한다.

### 1.2 Sidebar (Tree Explorer)
- **책임:** 트리 탐색 및 문서 선택.
- **상태:** `open` | `closed`.
- **전이:** 글로벌 바의 토글 이벤트에 따라 표시 여부를 결정한다.

### 1.3 Document Canvas (Container)
- **책임:** 글쓰기 영역의 시각적 컨테이너.
- **스타일:** 배경으로부터 떠 있는 형태 (`box-shadow`), 중앙 정렬 레이아웃 (`margin: auto`).
- **제약:** 고정된 최대 폭(Fixed Max Width)을 가져야 한다.

### 1.4 Paragraph Block (Editable Unit)
- **책임:** 개별 문단 편집 및 인터랙션.
- **이벤트:** `mouseenter` (Hover UI 노출), `mouseleave` (Hover UI 숨김), `click` (삭제 이벤트 발생).

## 2. Event Flows & State Transitions
- **Sidebar Toggle:** `GlobalBar.Button` 클릭 → `SidebarState` 변경 → `CanvasLayout` (Centered/Standard) 반영.
- **Theme Change:** `GlobalBar.ThemeSelect` → `ThemeMode` 변경 → 시스템 `body` 혹은 `root` 클래스 업데이트 → 전체 컬러 팔레트 스위칭.
- **Paragraph Hover:** `Paragraph.onMouseEnter` → `ParagraphState = hover` → 드래그 핸들 및 삭제 버튼 렌더링.
- **Paragraph Delete:**
    - `Paragraph.onDeleteClick` → 즉시 `PRD-045/046` 기반 삭제 명령 호출 → UI에서 제거.
    - Delete 동작은 단일 상태 변경 단위로 간주된다.
    - 이는 Drag & Drop의 Drop 이벤트와 동일한 변경 단위 정책을 따른다.
    - Delete는 hover 상태에서만 발생할 수 있다.

## 3. Testing Points (Visual & State Verification)
- **Layout Consistency:** 사이드바가 열리고 닫힐 때 문서 캔버스의 폭이 변하지 않고 중앙에 고정되는지 확인한다.
- **Hover Responsiveness:** 문단 위로 마우스를 빠르게 이동할 때 `hover` UI(드래그 핸들, 삭제 버튼)가 지연 없이 나타나고 사라지는지 확인한다.
- **Theme Persistence:** 브라우저를 새로고침한 후에도 사용자가 선택한 테마(Light/Dark)가 유지되는지 검증한다.
- **Visual Hygiene:** `idle` 상태에서 문단 주위에 불필요한 테두리나 박스가 전혀 없는지 시각적으로 확인한다.

## 4. Implementation Guidelines (Implementation Independent)
- 어떤 프레임워크나 라이브러리를 사용하더라도, 위에서 정의한 '계약(B 문서)'과 '상태 전이(D 문서)'를 충실히 준수해야 한다.
- 테마 시스템은 OS 기본 설정을 감지할 수 있어야 하며, 수동 선택이 항상 우선순위를 가진다.
