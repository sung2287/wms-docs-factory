# PRD-042: Writing Workspace UI v1.3 (2s Auto-Save Finalized)

## 1. Objective
인간 집필자가 워크스페이스 구조를 탐색하고 본문을 작성/관리할 수 있는 최소 기능의 UI 사양을 정의한다. 본 버전은 자동 저장(Auto-Save)과 단락 블록 에디터(Paragraph Block Editor)를 통합하여 집필 경험을 최적화한다.

## 2. In Scope
- 2-Pane 레이아웃 (Tree Explorer / Section Editor)
- Paragraph Block Editor (PRD-045) 기반 본문 편집
- Auto-Save (Draft Mode) 기능
- 상태 기반 필터링 및 탐색
- 명시적 상태 전환 흐름 (Mark as Completed)
- 실시간 저장 상태 인디케이터

## 3. Out of Scope
- AI 집필 보조 및 프롬프트 인터페이스
- 다중 섹션 동시 편집 (Multi-section editing)

## 4. UI 구성 사양

### 4.1 Left Pane: Tree Explorer
- **Hierarchy**: `external_key`와 `title`을 결합하여 트리 구조 표시.
- **Node Interaction**: 
    - Collapse/Expand 동작 지원.
    - **Node Click**: 해당 노드를 즉시 선택하고 Right Pane에 에디터를 오픈한다.
- **Status Indicator**: `writing_status` 및 `review_required` 상태 표시.
- **Filter Tabs**: All / To Write / To Review 탭 지원.

### 4.2 Right Pane: Section Editor
- **Header**: 현재 노드의 메타데이터 표시.
    - **Saving...**: 자동 저장 진행 중 표시.
    - **Saved**: 저장 성공 시 1.5초간 표시 후 사라짐.
    - 인디케이터는 사용자의 타이핑을 방해하지 않아야 한다.
- **Editor Area**: **Paragraph Block Editor (PRD-045)** 기반의 편집 영역.
    - 빈 줄(blank-line) 분할 규칙에 따라 본문을 단락 블록으로 렌더링한다.
- **Editing Scope**: 에디터는 선택된 단일 섹션(Section)만을 대상으로 동작한다.
- **Footer**:
    - **Mark as Completed 버튼**: 집필 완료를 선언하는 명시적 액션. 

## 5. Auto-Save Policy (Draft Mode)
사용자의 작업 내용을 보호하기 위해 다음과 같은 자동 저장 정책을 시행한다.

### 5.1 자동 저장 트리거
- **비활동 임계값 (Inactivity Threshold)**: 사용자 입력이 중단된 후 **2초(2000ms)**가 경과하면 실행한다.
- **타이머 리셋**: 모든 키 입력(keystroke) 또는 블록 변경(mutation) 발생 시 타이머는 초기화된다.
- **조건부 실행**: 에디터가 Dirty 상태(변경사항 있음)인 경우에만 실행한다.
- **동작 방식**: 반드시 **Debounce** 방식으로 구현하며, 중복된 동시 자동 저장 호출(Concurrent calls)은 방지해야 한다.

### 5.2 스냅샷 정책
- **내용 비교**: PRD-045의 `normalize()` 규칙을 적용한 `rawText`가 마지막 저장된 스냅샷과 다를 경우에만 신규 스냅샷을 생성한다.
- **상태 유지**: 자동 저장은 `writing_status`를 변경하지 않는다.

## 6. Navigation Behavior (탐색 동작)
노드 간 이동 시 데이터 유실을 방지하기 위해 다음과 같은 절차를 준수한다.
1. 사용자가 다른 노드를 클릭한다.
2. 에디터에 저장되지 않은 변경사항(Dirty state)이 있는지 확인한다.
3. 변경사항이 있다면 **2초를 대기하지 않고 즉시 자동 저장을 실행**한다.
4. **저장 성공 시까지 탐색(Navigation)을 차단**한다.
5. 저장 성공 시에만 대상 노드의 데이터를 로드하고 화면을 전환한다.
6. 저장 실패 시 현재 노드에 잔류하며 사용자에게 에러를 알린다. (자동 전환 차단)

## 7. 핵심 Workflow (Completion Action Rule 포함)
1. **Auto-Save (Draft)**: 사용자가 집필 중 상기 정책에 따라 `snippet.body`가 자동 저장되며 신규 스냅샷이 생성된다. `writing_status`는 변하지 않는다.
2. **Completion (Mark as Completed)**: 사용자가 완료 버튼을 클릭 시:
    - **Race Condition 방지**: 에디터가 Dirty 상태이고 대기 중인 자동 저장 타이머(Debounce timer)가 있다면, 해당 타이머를 즉시 **취소(Cancel)**해야 한다.
    - **즉시 저장**: 완료 액션은 현재 블록 상태를 기반으로 **즉시 저장**을 트리거해야 한다.
    - **정규화**: 이 저장 과정에서도 PRD-045의 정규화(`normalize()`) 규칙이 적용된 `rawText`를 사용해야 한다.
    - **상태 전환**: `writing_status`가 `completed`로 전환되며, 해당 노드의 `review_required`는 `false`로 초기화된다.
    - **불변성**: 완료 처리된 저장 이후에는 어떠한 지연된(Delayed) 자동 저장 작업도 실행되어서는 안 된다.

## 8. 결정론 및 일관성
- 에디터는 PRD-045 v1.3의 규칙을 엄격히 준수하여 렌더링 및 저장을 수행해야 한다.
- 모든 스냅샷 비교 및 저장 전 처리는 `PRD-045 normalize()`를 기준으로 한다.

---

## Revision Note (v1.3)
- 비활동 임계값 용어 수정 및 2초(2000ms) 정책 확정.
- Completion 액션 시 자동 저장 타이머 취소 및 즉시 저장 강제 로직(Race Condition 방지) 추가.
- 노드 이동 시 즉시 저장 및 전환 차단 로직을 구체화함.
- "Saving...", "Saved" UI 인디케이터 요구사항을 추가함.
- 스냅샷 생성 조건을 `PRD-045 normalize()` 기반 비교로 명확화함.
