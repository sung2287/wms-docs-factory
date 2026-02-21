# D-053: Viewer SSOT Lockdown Platform Notes
**Status: Draft (Freeze Candidate)**

## 1. 진입점 관리 (Entry Point Logic)
- **Production Path:** `index.html` 및 메인 번들러의 진입점을 React App Shell로 고정한다.
- **Dev-only Paths:** 레거시 뷰어 접근은 특정 환경 변수(`VITE_DEV_LEGACY=true`)가 활성화된 경우에만 라우팅 엔진에서 허용되도록 게이트를 구축한다.
- **Skin Management:** Product Viewer는 기본 진입점으로 고정하며, State Skin은 query flag 또는 dev-only route를 통해 선택 가능하도록 한다. 두 Skin은 동일한 `src/view/react-viewer/shell` 구조를 재사용해야 한다.

## 2. 라우팅 및 컴포넌트 재사용 (Routing Schema)
- **SSOT Wrapper:** PRD-052에서 정의된 `src/view/react-viewer/shell` (App Shell) 및 해당 하위 구조(Canvas, Explorer)를 SSOT Renderer로 간주하며, 문서/트리 렌더링이 필요한 모든 화면은 해당 구조를 재사용해야 한다.
- **Isolation:** 보조 화면(Feature Routes)은 별도의 디렉토리로 격리하되, 내부에서 독자적인 Canvas나 Explorer 로직을 구현하는 행위를 정적 도구로 감시한다.
- **Skin Logic:** Skin 분리는 엔트리포인트 복제가 아닌, 동일 App Shell 내부 분기 로직으로 처리되어야 한다.

## 3. CI 가드레일 구현 지침 (CI Guardrail Implementation)
- **Directory Guard:** `src/view/react-viewer` 외부에서 문서/트리 렌더링 본체(App Shell, Canvas, Explorer)를 신규 정의하거나 복제하는 행위를 감지·차단하는 정적 분석 규칙을 설계한다.
- **Symbol Check:** `DocumentCanvas`, `TreeExplorer`, `App Shell` 등의 핵심 심볼이 `src/view/react-viewer` 이외의 장소에서 Export되는 것을 금지한다.

## 4. 배포 및 빌드 정책 (Build Policy)
- `npm run build` 수행 시, 개발 전용 레거시 자산이 최종 번들에 포함되지 않도록 빌드 도구(Vite/Webpack 등)의 Alias 또는 Define 플러그인을 설정한다.
- **Environment Gate:** 개발 전용 State Skin은 production 빌드에서 비활성화 가능하도록 환경 게이트를 둘 수 있다. 단, Renderer 본체는 항상 단일 구조로 유지된다.

## 5. 불변성 확인 (Immutability Enforcement)
- 본 플랫폼 설계는 `src/core` 및 `src/adapter`에 대한 코드 수정을 수반하지 않는다.
- 기존의 모든 API 통신 및 이벤트 구독 방식은 SSOT Renderer 내부에서 일관되게 처리된다.
