# [PRD-040] Markdown Body Sync

## 1. Objective
본 PRD는 기존 Workspace의 트리 구조나 디자인 명세(DesignSpec)를 일절 변경하지 않고, 마크다운 파일 집합을 소스로 하여 특정 노드들의 본문(`snippet.body`)만을 원자적으로 업데이트(Overwrite)하는 기능을 정의한다.

## 2. Design Principles
1. **Body-only Sync**: 오직 본문 데이터만 교체하며, 노드의 추가/삭제/이동 등 구조적 변경은 엄격히 금지한다.
2. **Structural Immutability**: 동기화 과정에서 `external_key`, `lineage_id`, `order_int`, `design_spec` 등 구조 및 명세 관련 필드는 절대 변경되지 않는다.
3. **Fail-Fast Integrity**: 동기화 대상 마크다운 파일과 기존 Workspace 노드 간의 매핑이 완벽하지 않을 경우(누락 또는 초과), 작업을 즉시 중단한다.
4. **Conservation of Review State**: 본문 동기화는 `review_required` 상태에 영향을 주지 않는다. (디자인 변경이 아니므로 기존 리뷰 상태를 유지한다.)

## 3. Scope & Constraints

### 3.1 허용 범위 (In Scope)
- **UPDATE_BODY**: 기존 노드의 `snippet.body` 전체를 마크다운 파일의 내용으로 교체.

### 3.2 금지 범위 (Out of Scope / Forbidden)
- **Structural Changes**: ADD node, REMOVE node, MOVE, REKEY.
- **Spec Changes**: `UPDATE_SPEC` (DesignSpec 수정).
- **Partial Merge**: 단락 단위 병합 또는 지능형 텍스트 병합.
- **Snapshot Merge**: 여러 스냅샷의 본문을 병합하는 행위.

## 4. Identity Anchor & Mapping
1. **Primary Anchor**: `external_key`를 기준으로 마크다운 파일과 노드를 매칭한다.
2. **Secondary Validation**: 내부적으로 `lineage_id`를 대조하여 노드의 정체성을 검증한다.
3. **Mapping Rule**: 마크다운 파일 집합과 대상 Workspace의 동기화 대상 노드는 반드시 **1:1 매핑**되어야 한다.
   - `external_key`가 존재하지 않는 파일이 있는 경우 실패.
   - 파일에 대응하는 노드가 Workspace에 없는 경우 실패.

## 5. Execution Rules & Determinism
1. **Deterministic Order**: 파일 처리 순서는 파일명의 **Natural Numeric Sort** 기준을 따른다.
2. **Atomic Transaction**: 모든 본문 업데이트와 스냅샷 생성은 하나의 트랜잭션으로 묶이며, 부분 성공은 허용되지 않는다.
3. **Change Detection**:
   - 기존 본문과 입력 데이터가 모든 대상 노드에서 동일한 경우, 스냅샷을 생성하지 않고 종료한다.
   - 단 하나의 노드라도 본문 변경이 감지된 경우에만 새로운 스냅샷을 생성한다.
4. **Snapshot Message**: 생성된 스냅샷의 메시지는 `"Markdown Body Sync"`로 고정한다.

## 6. Non-Goals
- **Structural Diff**: 구조 변경을 수반하는 재유입(PRD-039의 영역).
- **DesignSpec Update**: 디자인 명세의 동시 수정.
- **Merge UI / Conflict Resolution**: 충돌 해결을 위한 사용자 인터페이스 또는 수동 병합 도구 제공.

## 7. Success Criteria
1. 모든 대상 노드의 `snippet.body`가 마크다운 내용으로 정확히 교체된다.
2. **`snapshot_count`가 1 증가하며 메시지가 정확히 기록된다 (변경 사항이 있을 경우).**
3. `review_required` 상태를 포함한 모든 구조적 필드가 변경 전과 동일하게 유지된다.
4. **동일한 Workspace 스냅샷과 동일한 마크다운 집합을 입력했을 때, 결과 스냅샷의 해시(의미적 동등성)가 동일함이 보장된다.**

## 8. Determinism & Validation 강화

### 8.1 Body Change Detection Rule
스냅샷 생성 여부를 결정하는 본문 변경 감지는 다음 정규화 규칙을 거친 후 수행한다.
1. **LF Normalization**: 모든 줄바꿈 문자는 LF(`\n`)로 통일하여 비교한다.
2. **Trailing Whitespace Removal**: 각 행의 끝에 있는 불필요한 공백을 제거한다.
3. **Encoding**: 모든 본문은 UTF-8 인코딩을 기준으로 처리한다.
4. **Byte-equal Comparison**: 위 정규화 과정을 거친 본문 데이터가 기존 데이터와 **Byte-equal**인 경우, 변경이 없는 것으로 간주하여 스냅샷 생성을 엄격히 금지한다.

### 8.2 Strict Key Matching Rule
마크다운 파일과 기존 노드를 매칭할 때 다음의 엄격한 규칙을 적용하며, 위반 시 즉시 작업 전체를 중단(Fail-Fast)한다.
1. **Exact String Match**: `external_key`는 문자열 단위로 완벽하게 일치해야 한다.
2. **Case-sensitivity**: 대소문자를 엄격히 구분한다.
3. **No Correction**: 입력된 키에 대해 자동 트림(Auto-trim), 공백 보정, 오타 수정 등을 절대로 수행하지 않는다.
4. **Mismatch Handling**: 단 하나의 파일이라도 매칭에 실패하거나, 노드에 매칭되지 않는 파일이 존재할 경우 프로세스를 즉시 종료하고 롤백한다.

### 8.3 Review State Invariance
본문 동기화 작업은 시스템의 디자인적 설계 변경이 아니므로 다음 상태를 보존한다.
1. **Review Required Status**: `review_required` 플래그는 동기화 전의 값을 그대로 유지한다. (본문이 바뀌어도 리뷰 필요 여부를 강제로 변경하지 않는다.)
2. **DesignSpec Immutability**: `design_spec` 필드는 어떠한 경우에도 수정되지 않으며, 조상으로부터의 상속 구조 또한 변하지 않는다.
