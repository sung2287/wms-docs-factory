# [B-040] Markdown Body Sync Contract

## 1. Domain Model: Sync Operation
- **Identity Anchor**: `external_key` (Exact String Match).
- **Target Field**: `snippet.body` (Only).
- **Normalization Rule**: LF-normalization + Trailing whitespace removal.

## 2. Core Constraints & Validation Rules (Fail-Fast)
1. **UPDATE_BODY Only**: 본 계약은 오직 전체 본문 덮어쓰기만을 허용한다.
2. **Exact Identity Matching**: 
   - `external_key`는 Case-sensitive하게 비교한다.
   - 자동 보정(Trim, Correction)은 허용되지 않으며, 매칭 실패 시 즉시 작업을 중단(Fail-Fast)하고 롤백한다.
3. **1:1 Mapping Integrity**: 파일 집합과 대상 노드 집합이 완벽히 일치해야 한다 (누락/초과 금지).

## 3. Determinism 조건 (Change Detection)
변경 감지는 다음 **Canonical Normalization**을 거친 후 수행한다.
1. **Normalization**:
   - 모든 줄바꿈을 LF(`
`)로 통일.
   - 각 행의 끝 공백(Trailing whitespace) 제거.
   - UTF-8 인코딩 고정.
2. **Comparison**: 정규화된 본문 데이터가 기존 데이터와 **Byte-equal**이면 "변경 없음"으로 판정한다.
3. **Sequence**: 파일 처리 순서는 Natural Numeric Sort로 고정하여 결과의 재현성을 보장한다.

## 4. Snapshot Rules
1. **Conditional Creation**: 변경 감지 로직에 의해 단 하나라도 본문이 변경된 경우에만 **단 1개**의 스냅샷을 생성한다.
2. **Creation Prohibition**: 모든 본문이 기존과 동일(Byte-equal)할 경우 스냅샷 생성을 엄격히 금지한다.
3. **Fixed Message**: Snapshot Message는 `"Markdown Body Sync"`로 고정한다.

## 5. Forbidden States / Evolutions
- **Structural Mutation**: ADD, REMOVE, MOVE, REKEY 노드 행위 절대 금지.
- **Spec Mutation**: `design_spec` 필드 수정 절대 금지.
- **Review State Mutation**: **`review_required` 플래그는 어떠한 경우에도 변경하지 않고 불변(Invariant)을 유지한다.**
- **Partial Merge**: 단락 단위 병합 또는 지능형 텍스트 병합 진화 금지.

## 6. Atomicity (Transaction)
- 전체 파일 집합의 본문 업데이트와 스냅샷 생성은 단일 트랜잭션 내에서 원자적으로 완료되어야 한다. 일부 파일만 업데이트된 상태로 커밋되는 것을 금지한다.
