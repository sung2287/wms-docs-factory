# B-052: React Viewer v1 Completion Contract
**Status: Draft (Freeze Candidate)**

## 1. 아키텍처 위계 (Layer Hierarchy)
- **Rendering Layer (React):** 본 문서가 다루는 영역으로, 시스템의 상태를 화면에 투영하는 역할에 국한된다.
- **Immutable Core/Adapter:** `src/core` 및 `src/adapter`의 모든 기존 계약은 불변(Immutable)이며, React 계층은 제공된 인터페이스만을 소비한다.

## 2. 상태 경계 (State Boundary)
### 2.1 Server/Business State (Core Owned)
- 문서 내용, 트리 위계, 스냅샷 등 비즈니스 데이터는 Core가 소유한다.
- React 계층은 이를 'Read-only'로 취급하거나, 정의된 Adapter Command를 통해서만 변경을 요청한다.

### 2.2 UI/Ephemeral State (React Owned)
- 노드 접힘(Collapse), 사이드바 노출 여부, 현재 선택 테마 등은 React 계층이 관리한다.
- 이 상태는 비즈니스 데이터 모델에 포함되지 않으며 `localStorage`를 통해 영속화된다.

## 3. API 사용 규범 (API Usage)
- **기존 계약 준수:** 새로운 저장 API나 통신 계약을 생성하지 않는다. 기존 `save`, `update` 등의 메서드만 호출한다.
- **통신 제약:** 새로운 HTTP endpoint, Adapter handler, 또는 통신 계약을 생성하지 않는다.
- **Snapshot/Conflict 투명성:** 본 UI 완성 작업은 Snapshot 생성 로직이나 Conflict 비교 알고리즘에 어떠한 영향도 주지 않는다. UI 상태 변화는 데이터 무결성 검증 범위 밖이다.

## 4. 금지 사항 (Prohibitions)
- **Core 수정 금지:** React 컴포넌트 내부 구현을 위해 `src/core` 또는 `src/adapter` 코드를 수정하는 행위는 엄격히 금지된다.
- **로직 결합 금지:** 저장 정책(Autosave 등)을 React 생명주기에 결합하여 임의로 트리거하거나 정책을 변경하는 행위 금지.

## 5. 데이터 흐름 (Data Flow)
- React Viewer는 Adapter로부터 전달받은 상태를 UI에 투영하며, 사용자 인터랙션은 기존 Adapter의 Command 메서드를 호출하는 방식으로만 처리한다.

## 6. UI Normative Alignment
- React Viewer 구현은 PRD-049 및 PRD-051 Contract의 MUST / MUST NOT 규칙을 상위 UI 계약으로 간주한다.
- React 계층은 해당 규칙을 위반하는 시각적/상호작용적 변경을 허용하지 않는다.
- 본 PRD-052는 049/051의 시각적·상호작용적 계약을 충실히 구현하는 범위에 한정된다.
