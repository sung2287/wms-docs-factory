# PRD-046: Notion-like Paragraph Drag Handle + Live Reorder (Writing UX v1)

## 1. Objective
본 문서는 PRD-045(Paragraph Block Editor)의 사용자 경험을 고도화하기 위해, 현대적인 문서 저작 도구(Notion 등)에서 제공하는 "단락 단위 드래그 앤 드롭" 인터페이스 사양을 정의한다. 

- **UI 레이어 혁신**: 기존의 단일 문자열 편집 방식을 유지하면서도, UI상에서는 단락을 자유롭게 재배치할 수 있는 물리적 조작감을 제공한다.
- **모델 불변성**: 데이터 모델, 저장 엔진, 스냅샷 전략 등 시스템의 코어 로직은 변경하지 않고 오직 UI 표현 및 인터페이스 동작만 확장한다.

## 2. In Scope (LOCKED)

### 2.1 Drag 범위 및 대상
- **단일 블록 이동**: 한 번에 하나의 단락 블록(Paragraph)만 이동할 수 있다.
- **Snippet 내부 한정**: 드래그는 현재 편집 중인 단일 섹션(Snippet) 내부로 제한되며, 다른 섹션으로의 이동은 허용하지 않는다.
- **Paragraph Only**: 현재 정의된 단락 블록만을 대상으로 하며, 향후 추가될 특수 블록 타입은 고려하지 않는다.

### 2.2 Interaction Rules
- **Handle 기반 드래그**: 드래그 시작은 단락 좌측에 위치한 드래그 핸들(⋮⋮)을 통해서만 가능하다.
- **텍스트 선택 보호**: 단락 본문(텍스트 영역) 드래그 시에는 기존의 텍스트 선택(Selection) 기능이 우선하며, 드래그 앤 드롭 이동이 트리거되지 않는다.
- **Drop 시점의 Mutation**: 드래그 중(Move)에는 내부 데이터의 순서가 변경되거나 `isDirty`가 발생하지 않는다. 오직 드롭이 완료(Drop)되어 순서가 확정된 시점에만 단락 배열의 상태를 갱신(Mutation)한다.
- **Undo 정합성**: 1회의 드롭은 1회의 데이터 변경으로 간주하며, 이는 단일 Undo/Redo 스택 단위가 된다.

### 2.3 Visual Rules (Notion-like Feel)
- **문서형 UI**: 평상시에는 카드나 박스 형태의 경계선이 보이지 않는 순수 문서 형태를 유지한다.
- **Hover 상태 변화**: 마우스 커서가 특정 단락 위에 위치할 때만 다음 요소가 노출된다.
    - 드래그 핸들 (⋮⋮)
    - 삭제 버튼 (🗑️ 또는 X)
- **Drag 중 시각 피드백**:
    - **Live Reorder**: 단락이 이동함에 따라 주변 단락들이 CSS Transform을 통해 실시간으로 밀려나며 위치를 비워준다.
    - **Drop Indicator**: 드롭 시 삽입될 위치를 선(Line) 형태로 명확히 표시한다.
    - **Ghost Effect**: 드래그 중인 블록은 반투명한 `DragOverlay` 형태로 커서를 따라다닌다.

### 2.4 Dirty / Save Policy Alignment
- **PRD-042 정합**: 드롭 완료 후 단락 배열이 변경되면 `join()`을 통해 `rawText`를 생성하고, 기존 `lastSavedNormalizedText`와 다를 경우 Auto-save(2초) 프로세스를 트리거한다.
- **Snapshot 일관성**: 순서 변경 결과로 생성된 `rawText`는 신규 스냅샷으로 기록되며, 이는 PRD-041의 Conflict 감지 대상에 포함된다.
- **Dirty 판단 기준 명확화**: Reorder는 단락 내부 텍스트 변경이 아닌 “배열 순서 변경”이지만, join(blocks) 결과 rawText가 달라질 경우 이는 텍스트 변경과 동일하게 Dirty 상태로 간주한다. 즉, Dirty 판단의 기준은 “사용자 입력 유형”이 아니라 normalize(join(blocks))의 최종 결과값이다.

## 3. Out of Scope (v1 명시적 차단)
- **멀티 블록 이동**: 복수 단락을 동시에 선택하여 이동하는 기능.
- **키보드 접근성**: 키보드 단축키를 이용한 블록 순서 변경 (v2 고려).
- **ARIA Reorder**: 보조 공학 기기를 위한 실시간 순서 변경 안내.
- **Virtualization**: 수천 개의 단락이 포함된 문서에 대한 가상화 렌더링.
- **Cross-snippet Drag**: 트리 구조의 다른 노드로 단락을 이동하는 행위.
- **Mobile 최적화**: 모바일 환경을 위한 터치 기반 드래그 핸들링 및 별도 UX.

## 4. Non-Functional Constraints
- **Stable Keys**: 단락 렌더링 시 React `key`는 배열 인덱스가 아닌, 세션 내에서 고유하고 안정적인 ID(stable id)를 기반으로 유지해야 한다.
- **Focus Management**: 드래그 앤 드롭이 완료된 후, 이동된 블록의 포커스 상태나 커서 위치가 사용자 기대에 맞게 복원되어야 한다. Drop 완료 직후, 이동된 블록은 사용자 입력 연속성을 보장하기 위해 논리적으로 동일한 블록에 포커스가 복원되어야 하며, 포커스 복원은 DragOverlay 제거 이후 실행되어야 한다.
- **No Core Modification**: Tree Engine, Snapshot API, Database Schema 등 코어 로직에 대한 수정을 절대 금지한다.
- **Technology Constraint**: `@dnd-kit` 라이브러리를 사용하여 구현하며, `react-beautiful-dnd` 사용은 금지한다.

## 5. Policy Alignment

본 PRD는 다음 기존 정책들과 완벽하게 정합되어야 하며, 상충 시 코어 정책이 우선한다.

- **PRD-045 (Paragraph Model)**: 데이터 저장 시 단일 `rawText` 문자열로 직렬화되는 정책을 준수한다.
- **PRD-042 (Auto-save)**: 블록 순서 변경 확정 후 2초 비활동 시 자동 저장을 수행하는 정책을 계승한다.
- **PRD-030 (Dirty Status)**: `normalize(join(blocks))` 결과가 기존과 다를 때만 Dirty로 간주하는 기준을 유지한다.
- **PRD-041 (Conflict)**: 순서 변경 후 저장 시 서버 헤드와 충돌할 경우 PRD-043의 비교 UI로 전환되는 흐름을 유지한다.
- **Reorder 범위 경계**: 본 PRD의 Reorder는 Snippet 내부 UI 배열 재정렬에 한정되며, Tree Engine(PRD-012) 또는 TOC 구조(PRD-020)의 노드 이동과는 무관하다. 따라서 Tree sibling 정수 재정렬 정책에는 영향을 주지 않는다.

## 6. Acceptance Criteria
1. 단락 좌측의 `⋮⋮` 핸들을 통해서만 드래그가 시작되는가?
2. 드래그 중 주변 단락들이 유연하게 밀려나며 삽입 위치를 보여주는가?
3. 드롭 완료 전까지는 자동 저장(Auto-save)이 트리거되지 않는가?
4. 단락 순서를 바꾼 후 저장된 결과물이 `rawText`상에서 단락 순서가 바뀐 채로 정확히 기록되는가?
5. 단락 내부의 텍스트를 드래그할 때 텍스트 선택 기능이 방해받지 않는가?
6. 단락 순서를 변경한 뒤 join(blocks)의 normalize 결과가 기존과 동일한 경우, Dirty 상태가 발생하지 않는가?