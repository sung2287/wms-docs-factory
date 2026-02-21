# PRD-052: React Viewer v1 Completion
**Status: Draft (Freeze Candidate)**

## 1. 개요 (Objective)
PRD-049(Minimal Mode) 및 PRD-051(UI Polish Pack)에서 정의된 고도화된 UI/UX 사양을 React 기반의 단일 App Shell 위에서 기술적으로 완성한다. 본 문서는 시각적 파편화를 제거하고 안정적인 렌더링 계층을 확보함으로써 차후 아키텍처 통합(PRD-053)의 토대를 마련한다.

## 2. 범위 (In Scope)
### 2.1 React App Shell 구조
- 뷰어 전용 독립적 React 컴포넌트 트리 및 레이아웃 컨테이너 구축.
- 좌측 트리(Explorer)와 우측 문서(Canvas)의 공간 분배 및 가변 레이아웃 처리.

### 2.2 DocumentCanvas 레이아웃 완성
- PRD-049 기반의 Floating Canvas 디자인 적용 (그림자, 여백, 고정 최대 폭).
- 중앙 정렬 집중 모드(Focus Mode) 인터랙션 구현.

### 2.3 Paragraph 인터랙션 고도화
- **Auto-grow:** 입력 내용에 따라 스크롤바 없이 높이가 자동 조절되는 기능.
- **Hover Affordance:** 마우스 오버 시에만 나타나는 드래그 핸들(`⋮⋮`) 및 삭제(`X`) 버튼.
- **Scroll Policy:** 개별 문단 내부 스크롤을 금지하고 문서 전체 레벨의 단일 스크롤 유지.

### 2.4 TreeExplorer UX 규칙 반영
- PRD-051 기반의 텍스트 중심 미니멀 리스트 디자인.
- 노드 접힘/펼침(Collapse/Expand) 시각적 구현 및 상태 유지.

### 2.5 UI State & Theme Token
- JSON 기반 Theme Token을 통한 컬러셋(Light/Dark) 일괄 적용.
- `localStorage`를 활용한 비즈니스 로직 외 UI 상태(접힘 상태, 사이드바 개폐 등) 관리.

### 2.6 Save Status UI Alignment
- PRD-049 Contract의 저대비(Low Contrast) 원칙을 준수한다.
- 저장 상태(Dirty / Saving / Saved)는 문서 가독성을 해치지 않는 저대비 시각 언어로 표현한다.
- 저장 상태 UI는 Document Canvas 내부가 아닌 Global UI 영역에 배치한다.
- 저장 정책(Autosave 주기, Snapshot 생성 등)은 변경하지 않는다.

### 2.7 Divider & Layout Visibility Rule
- PRD-051 Contract에 따라 좌/우 영역 구분선(Divider)은 기본적으로 시각적으로 노출되지 않아야 한다.
- Hover 또는 Resizing 상태에서만 시각적 피드백을 제공한다.
- Divider의 존재는 레이아웃 제어 요소일 뿐, UI 강조 요소가 되어서는 안 된다.

## 3. 제외 범위 (Out of Scope)
- **Viewer 통합/격리:** 기존 레거시 뷰어의 제거 또는 물리적 통합(PRD-053 영역).
- **SSOT 선언:** 데이터 소스의 단일화 선언 및 강제 적용.
- **Core/Adapter 변경:** 핵심 엔진 로직, 인터페이스 계약, 또는 데이터 흐름 수정.
- **정책 변경:** 저장(Autosave), 스냅샷(Snapshot), 충돌(Conflict) 관련 정책 일체.

## 4. 수락 기준 (Acceptance Criteria)
- 모든 문단이 입력 길이에 맞춰 높이가 자동 조절되며 내부 스크롤바가 발생하지 않는가?
- 트리 노드의 접힘/펼침 상태가 워크스페이스별로 `localStorage`에 정확히 보존되는가?
- 마우스 호버 시에만 문단 컨트롤러(핸들, 삭제)가 나타나는가?
- 테마 토큰 변경 시 인라인 스타일 수정 없이 전체 테마가 즉각 반영되는가?
- **핵심 엔진(Core) 소스코드 및 Adapter 계약에 대한 수정이 전혀 발생하지 않았는가?**
- PRD-052 구현 브랜치에서 `src/core` 및 `src/adapter` 디렉토리에 대한 파일 변경(diff)이 존재하지 않아야 한다.

## 5. 범위 침범 방지 (Drift Prevention)
- 본 PRD에 따른 모든 구현은 `src/core` 및 `src/adapter`를 수정할 수 없으며, 기존 API 인터페이스만을 소비해야 한다.
