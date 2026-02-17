# B-049: Writing UI Minimal Document Mode Contract
**Status: Draft**

## 1. UI State Model
UI 상태 관리를 위한 데이터 구조를 정의한다. (구현 시 참조)

- **SidebarState:** `open` | `closed`
- **ThemeMode:** `system` | `light` | `dark`
- **CanvasLayout:** `centered` (Focus mode) | `standard` (Sidebar open)
- **ParagraphState:** `idle` (default) | `hover` (active interaction)

## 2. Normative Rules
동작과 시각적 형태에 대한 강제 규범을 정의한다.

### 2.1 Document Canvas (MUST/MUST NOT)
- **MUST NOT:** 개별 문단(Paragraph)을 카드 형태로 디자인하거나 테두리/그림자를 부여하지 말 것.
- **MUST NOT:** Paragraph에 `border-radius`를 적용하지 말 것.
- **MUST NOT:** Paragraph에 `box-shadow`를 적용하지 말 것.
- **MUST NOT:** Paragraph에 상시 배경색(background color)을 적용하지 말 것.
- **MUST:** Floating 효과는 Document Canvas에만 허용된다.
- **MUST:** 문서 전체를 감싸는 Canvas 영역에만 `box-shadow`와 `border-radius`(미세값)를 적용하여 'Floating' 느낌을 줄 것.
- **MUST:** 사이드바가 닫혔을 때 Canvas는 화면 중앙에 정렬되어야 함.

### 2.2 Paragraph Interaction (MUST/SHOULD/MAY)
- **MUST:** 문단의 드래그 핸들(`⋮⋮`)과 삭제 버튼(`X`)은 `hover` 상태에서만 노출되어야 함.
- **MUST NOT:** 문단에 '위/아래 이동(Up/Down)' 버튼을 배치하지 말 것. (드래그가 유일한 순서 변경 동작)
- **SHOULD:** 삭제(`X`)는 즉시 수행되어야 함. (Undo/Redo는 상위 시스템 정책을 따름)
- **MAY:** `hover` 시 문단 배경에 5% 미만의 옅은 틴트(Tint)를 적용할 수 있음.

### 2.3 Global UI & Theme (MUST)
- **MUST:** 사이드바 토글 버튼과 테마 스위치 버튼은 상단 글로벌 UI 바에 위치해야 함. (문서 캔버스 내부 배치 금지)
- **MUST:** Sidebar는 Document Canvas와 동일한 디자인 시스템(반경, 톤 계열, 저대비 원칙)을 공유해야 한다.
- **MUST:** Sidebar는 Document Canvas보다 시각적으로 한 단계 낮은 depth를 가져야 한다.
- **MUST NOT:** Sidebar가 Document Canvas보다 더 강한 shadow, contrast, 또는 강조 효과를 가져서는 안 된다.
- **MUST:** `ThemeMode = system`일 때만 OS 테마를 추종해야 한다.
- **MUST:** `ThemeMode = light` 또는 `dark`가 명시적으로 선택된 경우 OS 설정을 무시해야 한다.
- **MUST:** 수동 선택이 존재할 경우, 이는 세션/리로드 이후에도 유지되어야 한다.
- **MUST:** 테마 변경 시 문서 전체 색상 팔레트가 즉각적으로 반영되어야 함.

### 2.4 Save Status (SHOULD)
- **SHOULD:** 저장 상태 표시(저장됨/저장중/Dirty)는 저대비(Low contrast) 색상을 사용하여 문서 가독성을 해치지 않아야 함.

## 3. Prohibitions (Forbidden UI)
- 개별 문단의 번호 표시 금지.
- 문단 간의 명시적인 경계선(Separator Line) 사용 금지 (여백으로 대체).
- 캔버스 내부에서의 설정 버튼 배치 금지.

## 4. Dependencies / Alignment
- **PRD-045/046 (Paragraph Editor/Drag):** 드래그 앤 드롭 및 블록 삭제 동작 계약은 유지하되, UI 요소만 미니멀화한다.
- **PRD-030 (Save UX):** 저장 상태 메시지의 시각적 '저대비' 원칙을 049에서 구체화한다.
- **PRD-042 (Writing Workspace):** 워크스페이스 구조 내에서 Canvas의 중앙 정렬(Focus mode) 규칙을 적용한다.
- **PRD-041 (Snapshot/Conflict):** UI 계층에서 충돌 알림 노출 시, 미니멀 디자인 톤을 유지한다.
