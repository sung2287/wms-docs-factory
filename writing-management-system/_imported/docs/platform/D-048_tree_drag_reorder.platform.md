# D-048: Tree Drag UX Platform Design

## 1. Library & Sensors
- **Core Library**: `@dnd-kit/core` 및 `@dnd-kit/sortable`.
- **Sensors**: `PointerSensor`를 기본으로 하되, 미세한 클릭과 드래그를 구분하기 위해 `activationConstraint: { distance: 5 }`를 적용한다.

## 2. Visual Implementation
- **DragOverlay**: 드래그 중인 노드를 포털(Portal) 레이어에 렌더링하여 컨테이너 잘림 현상을 방지한다.
- **Drop Indicator**: 노드 사이의 삽입 지점에 수평 선(Line)과 불릿(Bullet)을 표시한다.
- **Live Reorder**: 주변 노드들은 CSS `transition: transform`을 통해 실시간으로 위치를 조정한다.

## 3. Lifecycle & Integration
- **onDragEnd**:
    1. 동일 부모 내 이동인지 검증.
    2. 코어 엔진의 `reorderSiblings(tree, nodeId, newIndex)` 호출.
    3. 반환된 새로운 `TreeState`를 전역 스토어에 반영.
- Core API 호출은 반드시 기존 TreeState를 입력으로 하는 pure function 호출이어야 한다.
- 반환된 새로운 TreeState만 전역 스토어에 반영할 수 있다.
- Core API가 에러(Result Err)를 반환할 경우 상태 반영을 중단하고 UI를 원상복구한다.
- **Focus Restoration**: 드롭 완료 후 이동된 노드의 텍스트 영역 또는 노드 컨테이너에 포커스를 복원하여 키보드 연속성을 유지한다.

## 4. Key Management
- 모든 트리 노드는 `node.id`를 React `key`로 사용하며, 재정렬 중에도 컴포넌트의 Identity를 유지해야 한다.
