# B-005: Decision / Evidence Engine Contract

## 1. Data Integrity Invariants (Prohibitions)
- **No Overwrite**: 기존 Decision 레코드의 필드를 직접 수정하는 것을 금지한다.
- **No Independent Evidence**: `decisionRef`가 없는 Evidence 저장을 시도할 경우 즉시 거부한다.
- **No Summary**: `summary` 필드 사용 및 대화 요약 데이터 저장 시도를 엄격히 금지한다.
- **No Root Mutation**: 기존 Decision 체인의 `root_id`를 변경하는 행위를 금지한다.
- **No Cross-Chain Link**: `previous_version_id`가 다른 `root_id`를 가리키는 링크를 금지한다.
- **Root Identity Rule**: 최초 버전(version=1)은 `root_id = id` 를 만족해야 한다.
- **Scope Integrity Rule**: `scope`는 런타임에서 허용된 도메인 목록에 한해 저장 가능하다. 허용되지 않은 scope 값은 저장 단계에서 즉시 거부한다.

## 2. Schema Contract
- **Decision**: `id`, `root_id`, `version`, `text`, `strength` (enum), `scope` (string), `is_active` (boolean), `created_at`.
- **Evidence**: `id`, `content` (string), `decision_ref` (uuid, **NOT NULL**), `timestamp`.
- **Anchor**: `id`, `hint` (string), `target_ref` (uuid), `type` (enum).

## 3. Hierarchical Retrieval Contract (LOCK)
Retrieval 엔진은 아래 계층적 로딩 단계를 순차적으로 수행 및 병합해야 한다:
1. `is_active=true` AND `scope='global'` AND `strength='axis'`
2. `is_active=true` AND `scope='current_domain'` AND `strength='axis'`
3. `is_active=true` AND `scope='current_domain'` AND `strength='lock'`
4. `is_active=true` AND `scope='current_domain'` AND `strength='normal'`

- Retrieval은 단일 SQL ORDER BY 최적화 방식으로 대체할 수 없으며, 단계별 로딩 후 병합 구조를 유지해야 한다.

## 4. Immediate Persistence Contract
- `PersistDecision` Step은 저장 즉시 물리적 커밋을 완료하고 다음 사이클에서 조회가 가능해야 한다.

## 5. Failure Semantics
- 모든 Write 및 DB 무결성 오류는 **Fail-Fast** 한다.
- Retrieval 결과 없음은 정상이나, 알고리즘 내부 예외는 **Fail-Fast** 한다.
