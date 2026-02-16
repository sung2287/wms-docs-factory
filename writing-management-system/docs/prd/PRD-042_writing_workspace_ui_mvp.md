# [PRD-042] Writing Workspace UI (MVP)

## 1. Objective
인간 집필자가 워크스페이스 구조를 탐색하고 본문을 작성/관리할 수 있는 최소 기능의 UI 사양을 정의한다.

## 2. In Scope
- 2-Pane 레이아웃 (Tree Explorer / Section Editor)
- 상태 기반 필터링 및 탐색
- 수동 저장 및 명시적 상태 전환 흐름

## 3. Out of Scope
- 자동 저장(Auto-save) 기능
- AI 집필 보조 및 프롬프트 인터페이스

## 4. UI 구성 사양

### 4.1 Left Pane: Tree Explorer
- **Hierarchy**: `external_key`와 `title`을 결합하여 트리 구조 표시.
- **Node Interaction**: Collapse/Expand 동작 지원.
- **Status Indicator**: `writing_status` 및 `review_required` 상태 표시.
- **Filter Tabs**: All / To Write / To Review 탭 지원.

### 4.2 Right Pane: Section Editor
- **Header**: 현재 노드의 메타데이터 표시.
- **Editor Area**: 마크다운 기반의 본문 편집 영역.
- **Footer**:
    - **Save 버튼**: 현재 내용을 저장하고 신규 스냅샷 생성. `writing_status`는 변경하지 않음 (초안 저장 허용).
    - **Mark as Completed 버튼**: 집필 완료를 선언하는 명시적 액션.

## 5. 핵심 Workflow (상태 관리 분리)
1. **Save (Draft)**: 사용자가 집필 중 `Save` 클릭 시 `snippet.body`가 저장되며 신규 스냅샷이 생성된다. 이 단계에서 `writing_status`는 변하지 않는다.
2. **Completion**: 사용자가 `Mark as Completed` 클릭 시:
    - `writing_status`가 `completed`로 전환된다.
    - 해당 노드의 `review_required`는 `false`로 초기화된다 (인간의 최종 확정).
    - 이 모든 변화는 단일 스냅샷으로 기록된다.

## Revision Note (v1.1)
- 저장(Save)과 완료(Completion) 액션을 분리하여 초안 저장이 가능한 유연한 집필 흐름을 확보함.
- 집필 완료 시 `review_required` 플래그가 해제되는 정책을 추가함.
