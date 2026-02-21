# B-053: Viewer SSOT Lockdown Contract
**Status: Draft (Freeze Candidate)**

## 1. Renderer SSOT Rule (최상위 계약)
본 계약은 WMS UI 아키텍처의 무결성을 보장하기 위한 최상위 규범이며, 모든 시각적 표현 계층 구현에 우선한다.

- Renderer는 단일 SSOT 렌더링 엔진을 의미하며, State/Product와 같은 UI Skin은 동일 Renderer 위에 얹히는 표현 계층으로 간주한다.
- Skin은 허용되나, Renderer 로직의 복제 또는 독립적인 동급 렌더러 생성은 금지된다.
- **MUST:** 모든 문서 본문 및 트리 위계의 시각적 표현은 `PRD-052`에서 확정된 SSOT Renderer(React App Shell)를 통해서만 수행되어야 한다.
- **MUST NOT:** 기존 SSOT Renderer와 기능적으로 중복되는(문서/트리 렌더링) 동급의 렌더링 엔진 또는 쉘을 신규로 생성할 수 없다.
- **MUST NOT:** SSOT Renderer를 재사용하지 않는 별도 Viewer Shell 또는 Canvas 정의는 금지된다.
- **MAY:** SSOT Renderer 본체를 포함하지 않는 순수 기능 페이지(Feature Routes: 예: 설정, 워크스페이스 관리 등)는 자유롭게 추가할 수 있다.

## 2. 엔트리포인트 무결성 (Entry Point Integrity)
- **Production Single Entry:** 생산 환경에서의 진입점은 React 기반 SSOT Shell로 단일화되어야 한다.
- **Legacy Isolation:** 레거시 코드 및 실험적 뷰어의 호출은 개발(Dev) 및 테스트 환경으로만 국한되며, 생산 빌드 결과물에는 포함되지 않아야 한다.

## 3. 아키텍처 경계 (Architecture Boundary)
- **Immutable Core/Adapter:** 본 Lockdown 작업은 `src/core` 및 `src/adapter`의 어떠한 인터페이스나 로직도 변경하지 않는다.
- **State SSOT:** 렌더러가 통합되더라도 데이터 상태의 SSOT는 여전히 Core/Adapter가 담당하며, 렌더러는 이를 투영하는 역할에 충실해야 한다.

## 4. 가드레일 계약 (Guardrail)
- 프로젝트의 정적 분석 시스템은 `src/view` 내의 특정 핵심 컴포넌트(Canvas, Explorer)의 정의 위치와 사용처를 감시하여, 승인되지 않은 Renderer의 확산을 자동으로 차단해야 한다.
