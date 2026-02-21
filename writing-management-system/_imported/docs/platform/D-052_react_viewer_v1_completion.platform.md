# D-052: React Viewer v1 Completion Platform Notes
**Status: Draft (Freeze Candidate)**

## 1. 모듈 구조 (Module Structure - Rendering Layer Only)
React Viewer 계층은 아래의 구조를 따르며, 이는 `src/view/react-viewer` 하위의 독립적인 공간으로 제한된다.
- `src/view/react-viewer/shell/`: 전체 레이아웃 및 컨테이너 (App Shell)
- `src/view/react-viewer/canvas/`: 문서 캔버스 및 문단 렌더러 (Autogrow 포함)
- `src/view/react-viewer/explorer/`: 트리 리스트 및 노드 컴포넌트
- `src/view/react-viewer/theme/`: JSON 토큰 기반 CSS 변수 관리 시스템

## 2. 테마 토큰 관리 (Theme Management)
- **위치:** `src/view/react-viewer/theme/tokens.json`
- **적용:** 런타임 시 JSON을 파싱하여 CSS Custom Properties(`--wms-*`)를 생성하고, App Shell 최상위 DOM에 주입한다. 하드코딩된 색상 값을 배제한다.

## 3. LocalStorage 상세 (State Persistence)
- **Key Namespace:** `wms_v1_ui_state_<workspaceId>`
- **관리 범위:**
    - `collapsedNodeIds`: 접힌 트리 노드 ID 배열
    - `sidebarVisible`: 사이드바 노출 여부
    - `currentThemeMode`: 'light' | 'dark' | 'system'
- **주의:** 보안 및 정확성이 필요한 문서 본문이나 트리 위계 데이터는 절대 저장하지 않는다.

## 4. 공존 및 배포 정책 (Coexistence)
- **Legacy Coexistence:** 기존 레거시 뷰어(HTML/JS)는 현재의 경로와 로직을 유지한다. React Viewer는 별도의 렌더링 영역(App Shell)에서 실행되어 상호 간섭을 최소화한다.
- **Entry Point:** 프로젝트의 프로덕션 메인 엔트리(index.html 등)는 변경하지 않는다. React Shell은 기존 배포 구조를 변경하지 않는 범위 내에서 독립적으로 실행된다.

## 5. 성능 및 드리프트 방지
- **Auto-grow:** Textarea의 높이 계산은 `requestAnimationFrame`을 사용하여 브라우저 레이아웃 스래싱을 방지한다.
- **Core Isolation:** `src/core` 및 `src/adapter`에 대한 임포트는 오직 정의된 인터페이스로 제한하며, 내부 구현체에 대한 직접 참조를 금지한다.

### Visual Enforcement Rules
- Divider visibility behavior MUST comply with PRD-051: 기본 상태에서는 시각적으로 노출되지 않으며, Hover 또는 Resizing 상태에서만 피드백을 제공한다.
- 하드코딩된 색상 값은 금지되며, 모든 색상은 중앙 Theme Token 시스템을 통해서만 정의되어야 한다.
- UI 계층은 PRD-049의 Document Canvas 규범(문단 카드화 금지, 상시 배경색 금지 등)을 위반해서는 안 된다.
