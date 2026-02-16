# [B-033] Lightweight TOC Import Contract

## 1. Domain Model: TOC Node
- **node_id**: UUID (내부 식별용)
- **lineage_id**: UUID (**내부 정체성 앵커**, 생성 시 자동 할당)
- **external_key**: String (**Navigation Attribute**, Identity가 아님)
- **title**: String
- **order_int**: Integer

## 2. Internal Identity Anchoring
1. 모든 노드는 생성 시점에 고유한 `lineage_id`를 내부적으로 자동 생성한다.
2. `external_key`는 외부 주소 체계 및 계층 표현을 위한 속성일 뿐, 노드의 동일성을 판정하는 영구적 앵커가 아니다. (정체성 주권은 `lineage_id`에 있다.)

## 3. Deterministic Sorting Contract
생성된 노드들의 트리 배치 및 `order_int` 할당은 다음 우선순위에 의거하여 결정론적으로 정렬되어야 한다.
1. **Depth ASC**: 계층 깊이가 낮은 노드 우선.
2. **Natural Numeric Sort of external_key**: `external_key`를 도트(`.`) 단위 세그먼트로 분리하여 각 숫자를 비교 정렬한다. (예: `1.2` < `1.10`)
3. **Stable Tie-breaker**: 위 조건으로 정렬되지 않는 경우, 원본 입력 텍스트에서의 출현 순서(Original Input Order)를 따른다.

## 4. Snapshot Initialization
1. Workspace 생성 직후 `snapshot_count = 1`인 초기 스냅샷을 생성한다.
2. **Snapshot Message**: `"Lightweight TOC Import"` (고정 문구)
