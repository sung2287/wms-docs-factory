# PRD-049: Writing UI Minimal Document Mode
**Status: Draft**

## 1. Objective
"블록 에디터"의 파편화된 느낌을 제거하고, 하나의 완성된 "문서(Canvas)"에서 글을 쓰는 듯한 몰입형 UX를 제공한다. ChatGPT의 안정적인 레이아웃과 Apple의 미세한 깊이감을 벤치마킹하여, 미니멀하면서도 고급스러운 저작 환경을 구축한다.

## 2. Background
현재 PRD-045/046을 통해 구현된 문단(Paragraph) 기반 편집 시스템은 기능적으로는 훌륭하나, 시각적으로 각 문단이 독립된 '카드'처럼 보여 장문의 글을 작성할 때 흐름이 끊기는 인상을 준다. 이를 개선하여 '문서 중심'의 인터페이스로 전환할 필요가 있다.

## 3. In Scope
- **Document Canvas:** 전체 문서 영역의 시각적 정의 (Floating 효과, Spacing 중심 레이아웃).
- **Paragraph Interaction:** Hover 시에만 노출되는 최소화된 컨트롤러 (Drag handle, Delete).
- **Sidebar & Theme Toggle:** 글로벌 UI 바를 통한 사이드바 제어 및 테마(Light/Dark/System) 전환.
- **Save Status:** 저대비(Low contrast) 디자인의 상태 표시바.

## 4. Out of Scope
- 데이터 저장 로직, 스냅샷, 컨플릭트 관리 등 Core Engine 수정.
- 문단 내부의 Rich Text 편집 기능 고도화.
- 새로운 트리 엔진 데이터 구조 도입.

## 5. UX Rules & Visual Principles
### 5.1 Document Canvas
- **Floating Effect:** 문서 전체 Canvas에만 미세한 그림자와 살짝 둥근 모서리를 적용하여 배경 위에 떠 있는 느낌을 준다.
- **No Block Cards:** 개별 문단 블록에 테두리, 배경색(기본 상태), 그림자를 적용하는 것을 금지한다. 오직 여백(Vertical Spacing)으로만 구분한다.

### 5.2 Paragraph Interaction (Minimalist Style)
- **Idle State:** 텍스트 외의 어떤 UI 요소(번호, 박스, 버튼)도 노출하지 않는다.
- **Hover State:** 
    - 좌측: `⋮⋮` 드래그 핸들 노출.
    - 우측: `X` 삭제 버튼 노출.
    - 배경: 아주 미세한 Tint(3~5%) 적용 가능.
- **Action:** Up/Down 버튼을 제거하고 드래그 앤 드롭을 주 동작으로 삼는다. 삭제는 즉시 수행된다.

### 5.3 Sidebar & Theme Toggle
- **Global UI Bar:** 사이드바 토글과 테마 스위치는 문서 내부가 아닌 상단 글로벌 바에 배치한다.
- **Focus Mode:** 사이드바가 닫히면 Canvas는 화면 중앙에 정렬되며 고정 폭을 유지한다.
- **Sidebar Depth System:** 
    - Sidebar는 Document Canvas와 동일한 디자인 언어(radius, tone family, low contrast system)를 공유해야 한다.
    - Sidebar는 동일한 depth system 안에 포함되되, Canvas보다 한 단계 낮은 depth로 정의한다.
    - Sidebar는 Canvas보다 더 강한 그림자(shadow)나 대비를 가져서는 안 된다.
    - Light/Dark 모드 모두에서 이 depth 위계는 유지되어야 한다.

### 5.4 Theme System
- OS 설정을 감지하되, 사용자의 수동 선택(Light/Dark)을 최우선으로 적용한다.
- 사용자의 테마 선택 상태는 기억되어야 한다.

## 6. Acceptance Criteria
- 사용자가 문단 위로 마우스를 올리기 전까지는 일반 워드 프로세서와 같은 깔끔한 화면이 유지되는가?
- 사이드바를 접었을 때 문서 캔버스가 흔들림 없이 중앙 정렬을 유지하는가?
- 다크 모드와 라이트 모드 전환 시 저대비 원칙(눈의 피로도 감소)이 지켜지는가?

## 7. Risks & Non-goals
- 과도한 애니메이션은 오히려 편집 반응성을 떨어뜨릴 수 있으므로 '미세함'을 유지해야 한다.
- 기존 PRD-045/046의 데이터 계약을 유지하는 범위 내에서 UI 레이어만 수정한다.
