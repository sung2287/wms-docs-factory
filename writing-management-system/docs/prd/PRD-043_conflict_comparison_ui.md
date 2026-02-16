# [PRD-043] Conflict Comparison UI (Pre-Save Comparison)

## 1. Objective
PRD-041 Snapshot Conflict 정책에 의거하여 Stale Save 발생 시 사용자가 최신 서버 버전(head)과 본인의 편집본을 시각적으로 비교하고, 데이터 유실 없이 안전한 의사결정(Override 또는 Refresh)을 내릴 수 있는 전용 비교 UI 사양을 정의한다.

## 2. In Scope
- Stale Save 감지 시 자동 전환되는 Comparison Mode 인터페이스
- 서버 최신본(head)과 사용자 편집본 간의 UI 블록 단위 시각적 차이점(Diff) 표시
- Override(신규 스냅샷 생성) 및 Refresh(편집본 폐기 및 최신본 로드) 선택 기능
- Conflict 상태에서의 사용자 액션 흐름 제어

## 3. Out of Scope
- **자동 병합(Auto-merge)**: 시스템에 의한 지능형 텍스트 결합
- **부분 병합(Partial Merge)**: 블록별 선택적 반영 또는 체크박스 기반 병합
- **3-way Merge**: 공통 조상(base)을 포함한 세 방향 비교
- **In-place Editing**: 비교 화면 내에서의 직접적인 텍스트 수정
- **Meta-data Diff**: 스냅샷 ID, 타임스탬프 등 메타데이터의 시각적 비교
- **Block Move Detection**: 블록 이동을 별도 유형으로 감지하거나 표시하지 않는다.

## 4. UI 동작 흐름 (Pre-Save Comparison Flow)

### 4.1 전환 트리거
1. 사용자가 에디터에서 `Save` 요청을 보낸다.
2. 시스템(PRD-041 엔진)이 Conflict를 감지하여 409 응답을 반환한다.
3. 에디터는 편집 모드를 중단하고 즉시 **Comparison Mode**로 전환한다.

### 4.2 화면 구성
- **경고 메시지**: 상단에 "다른 세션에서 변경이 발생했습니다. 저장 전 비교가 필요합니다." 문구를 상시 노출한다.
- **Side-by-Side View**:
    - **Left (Server Head)**: 서버에 저장된 최신 스냅샷의 본문. (읽기 전용)
    - **Right (User Draft)**: 사용자가 현재 세션에서 수정한 편집본. (읽기 전용)

### 4.3 사용자 선택 및 후속 조치
- **Override 버튼**: 사용자의 편집본을 새로운 스냅샷으로 강제 격상한다. 클릭 시 PRD-041의 Override 재검증 로직을 실행한다.
- **Refresh 버튼**: 사용자의 편집 내용을 모두 폐기하고, 서버의 최신 스냅샷(head)을 에디터로 로드하며 일반 편집 모드로 복귀한다.

## 5. Diff 규칙

1. **비교 단위**: 마크다운 줄 단위가 아닌 **UI Block Model(PRD-044)** 단위를 기준으로 비교한다.
2. **동일성 판단 기준**: 아래 두 조건이 모두 충족될 때 동일 블록으로 간주한다.
    - 블록 타입(Paragraph, Heading 등)이 동일함.
    - 정규화된 텍스트 내용(B-040 기준)이 동일함.
3. **읽기 전용 원칙**: 비교 모드에서 표시되는 모든 텍스트와 블록은 수정이 불가능한 상태(Read-only)여야 한다.
4. **Block Reordering Policy**:
    - 블록 순서 변경(Move)은 별도의 변경 유형으로 감지하지 않는다.
    - 순서가 변경된 블록은 **Removed + Added 조합**으로 계산하여 표시한다.
    - 블록 고유 식별자 기반의 이동 추적은 수행하지 않는다.
    - Diff는 위치 기반 비교를 수행하지 않으며, UI Block Model 배열 구조를 기준으로 결정론적으로 계산한다.

## 6. 시각적 표시 규칙
차이점은 블록 단위로 하이라이트 처리한다.
- **Added (Green)**: 사용자 편집본(Right)에만 존재하는 신규 블록.
- **Removed (Red)**: 서버 최신본(Left)에만 존재하고 사용자 편집본에서 사라진 블록.
- **Modified (Yellow)**: 양쪽에 모두 존재하나 내용이나 타입이 변경된 블록.

## 7. 상태 전이 모델

| 현재 상태 | 액션 | 결과 | 전이 후 상태 |
| :--- | :--- | :--- | :--- |
| **Editing** | Save | Conflict Detected | **Comparison Mode** |
| **Comparison Mode** | Override | Validation Success | **Editing (Latest Snapshot)** |
| **Comparison Mode** | Override | Validation Fail | **Comparison Mode (Update Head)** |
| **Comparison Mode** | Refresh | Discard Local Draft | **Editing (Reloaded Head)** |

## 8. 결정론 및 일관성
- **Deterministic Diff**: 동일한 두 데이터셋(Head vs Draft)에 대해 생성되는 diff 결과는 항상 동일해야 한다.
- **Single Truth**: 비교에 사용되는 서버 데이터는 반드시 Conflict 발생 시점에 수신한 `current_head_snapshot_id`를 기준으로 한다.

## 9. UX 원칙
- **Explicit Choice**: 사용자는 반드시 Override 또는 Refresh 중 하나를 명시적으로 선택해야 하며, 시스템이 임의로 결정을 내리지 않는다.
- **No Silent Actions**: 어떠한 경우에도 사용자의 인지 없이 데이터를 덮어쓰거나(Silent Overwrite) 폐기하지 않는다.

---

## Revision Note (v1.1)
- 블록 순서 변경(Move)을 별도 감지하지 않고 Removed + Added로 처리하여 Diff 해석의 복잡도를 낮추고 결정론을 강화함.
- 블록 고유 식별자 기반 추적을 배제함으로써 부분 병합(Partial Merge) 가능성을 원천 차단함.
