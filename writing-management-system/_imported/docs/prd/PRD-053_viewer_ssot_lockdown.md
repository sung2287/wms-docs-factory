# PRD-053: Viewer SSOT Lockdown
**Status: Draft (Freeze Candidate)**

## 1. 개요 (Objective)
생산용(Production) UI 환경에서 "Viewer Renderer"를 단일 App Shell 기반으로 고정(Lockdown)한다. 레거시 및 중복 렌더러의 확산을 구조적으로 차단하고, UI 표현 계층의 단일 진실 공급원(SSOT)을 확립하여 유지보수 효율성을 극대화한다.

## 2. 정의 (Definitions)
- **Viewer Renderer:** 문서(Document Canvas)와 트리(Tree Explorer)를 렌더링하는 핵심 본체(React App Shell + Canvas + Explorer)를 의미한다.
- **Renderer vs Skin:** Viewer Renderer는 단일 SSOT 렌더링 엔진을 의미하며, Skin(State/Product)은 동일 Renderer 위에 얹히는 UI 구성/제어 레이어이다. Skin은 허용되지만, 독립적인 렌더링 로직 복제 또는 동급 Viewer 생성은 금지된다.
- **Feature Page/Route:** `/workspaces`, `/settings` 등 Viewer Renderer 본체를 포함하지 않는 보조 기능 화면을 의미한다. (추가 허용)
- **SSOT Rule:** 모든 문서/트리 렌더링은 반드시 정의된 SSOT Renderer를 재사용해야 하며, 이와 동일하거나 유사한 기능을 수행하는 동급 Renderer의 신규 생성은 엄격히 금지된다.

## 3. 범위 (In Scope)
### 3.1 엔트리포인트 정리 및 격리
- 현재 존재하는 모든 Viewer 관련 엔트리포인트(Legacy HTML/JS 등)를 목록화하고 Prod/Dev 용도로 분류한다.
- 생산(Production) 환경의 진입점을 PRD-052에서 완성된 React Viewer 1개로 고정한다.
- 레거시 Viewer는 개발 전용(dev-only)으로 격리하거나 물리적으로 제거한다.

### 3.2 라우팅 및 재사용 원칙
- 새로운 기능 화면(Feature Route) 추가는 허용하되, 해당 화면에서 문서/트리 렌더링이 필요할 경우 반드시 SSOT Renderer를 컴포넌트로 호출해야 한다.
- Renderer 본체를 복제하거나 별도의 렌더링 로직을 구축하는 행위를 금지한다.
- **진입 정책:** Product Viewer는 기본 진입점으로 고정한다. State Viewer는 개발/디버그 목적에 한해 접근 가능하도록 제한한다 (예: dev-only route 또는 query flag 기반).

### 3.3 CI 가드레일 설계
- "새로운 Viewer Renderer 생성" 또는 "핵심 렌더링 로직 복제"를 감지하고 차단하기 위한 정적 분석 규칙(Static rule)을 설계한다.

### 3.4 허용 및 금지 예시 (Allowed vs Forbidden)
| 구분 | 허용 (Allowed) | 금지 (Forbidden) |
| :--- | :--- | :--- |
| **화면 추가** | `/dashboard` 등 보조 기능 페이지 추가 | `/alt-editor` 등 독자적 렌더러를 가진 편집기 추가 |
| **컴포넌트** | SSOT Renderer를 임포트하여 다른 화면에 배치 | `DocumentCanvas` 로직을 복사하여 새 컴포넌트 생성 |
| **진입점** | 확정된 메인 App Shell을 통한 접근 | `legacy_viewer.html` 등을 생산용으로 노출 |
| **Skin/Mode** | 동일 Renderer를 사용하는 UI Skin 추가 (예: State Viewer, Product Viewer), 모드 플래그 또는 라우트 분기를 통한 Skin 선택, 상태 표시용 UI 확장 (배지, 디버그 정보 등) | Renderer 로직을 복제하여 새로운 Viewer 엔트리포인트를 만드는 행위, 동일 역할을 수행하는 별도 Document Renderer 생성 |

## 4. 제외 범위 (Out of Scope)
- PRD-052에서 정의된 UI 기능의 추가 또는 변경.
- 핵심 엔진(Core) 및 어댑터(Adapter) 계약의 수정.
- 저장, 스냅샷, 충돌(Conflict) 정책의 변경.
- 자동 마이그레이션 로직 구현 또는 UI 리디자인.

## 5. 수락 기준 (Acceptance Criteria)
- 생산용 엔트리포인트가 React Viewer 1개로 제한되었음을 확인한다.
- 레거시 뷰어는 개발 모드에서만 접근 가능하거나 제거되었는가?
- 신규 Renderer(유사 기능) 추가 시 CI 파이프라인에서 정적 규칙에 의해 차단되는가?
- 새로운 Feature Route 추가가 SSOT Rule을 위반하지 않는 범위 내에서 자유로운가?
- **PRD-053 브랜치 기준 `src/core` 및 `src/adapter` 디렉토리에 변경(diff)이 전혀 없는가?**

## 6. 리스크 및 대응 (Risks & Mitigations)
- **과차단 리스크:** CI 규칙이 너무 엄격하여 일반 UI 컴포넌트 추가를 방해할 수 있으므로, "Renderer"의 정의를 명확히 하여 규칙을 세밀하게 조정한다.
- **경로 혼동:** 개발 전용 경로가 운영 환경에 노출되지 않도록 환경 변수 기반의 게이트(Gate)를 철저히 관리한다.

## 7. 정합성 및 드리프트 방지
- Skin 분리는 SSOT Renderer를 확장하는 전략이며, 렌더링 책임을 분산시키는 구조 변경이 아니다.
- 어떠한 경우에도 두 개 이상의 동급 Viewer Renderer를 허용하지 않는다.
