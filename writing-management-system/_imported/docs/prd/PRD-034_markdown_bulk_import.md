# [PRD-034] Markdown Bulk Import (v1)

## 1. Objective
본 PRD는 대량의 마크다운 파일 집합으로부터 새로운 Workspace를 자동 생성하고, 초기 상태를 스냅샷(Snapshot #1)으로 기록하는 일회성 생성 도구의 사양을 정의한다.

## 2. Design Principles
1. **Create-only Policy**: v1 임포터는 오직 신규 Workspace 생성을 위해서만 작동한다. 기존 Workspace에 대한 수정, 덮어쓰기, 동기화는 지원하지 않는다.
2. **Flat Structural Model**: 폴더 구조는 파일 검색을 위한 편의 수단일 뿐, 시스템 내부의 계층 구조(SSOT)로 흡수하지 않는다.
3. **Internal Identity Anchoring**: 모든 노드는 생성 시점에 고유한 `lineage_id`를 내부적으로 자동 할당받아 향후 PRD-039 계열의 구조 변경 모델과 호환성을 가진다.
4. **Atomic Creation**: Workspace 생성부터 스냅샷 기록까지의 모든 과정은 원자적 트랜잭션으로 수행된다.

## 3. Import Modes (Creation Only)

### 3.1 Mode A: Key-based Create
- 파일명 또는 메타데이터(YAML Frontmatter)의 `external_key`를 추출한다.
- 추출된 `external_key`를 기반으로 새로운 Workspace의 트리 구조를 형성하고 본문을 채운다.
- 유효한 `external_key`가 없는 파일은 생성 대상에서 제외하거나 에러 처리한다.
- **Mode A Key Uniqueness Rule**: 추출된 `external_key`는 exact string match 기준으로 유일해야 한다. 중복 `external_key`가 발견될 경우 즉시 Fail-Fast 하며 Workspace 생성은 롤백된다. 모든 비교는 case-sensitive로 수행하며, 자동 보정(trim, normalization, auto-increment 등)은 일절 허용하지 않는다.

### 3.2 Mode B: Discovery Create
- 특정 디렉토리 내의 파일 목록을 기반으로 플랫(Flat)한 트리 구조를 자동 생성한다.
- 파일 계층은 무시하며 모든 파일은 동일 레벨 또는 지정된 루트 하위에 배치된다.
- **external_key 자동 생성 규칙**:
  1. `external_key`는 **결정론적 숫자 시퀀스(Deterministic Numeric Sequence)** 기반으로 생성한다.
  2. 생성 및 할당 순서는 **내추럴 숫자 정렬(Natural Numeric Sort)**을 통한 `order_int` 할당 순서로 고정한다.
  3. **생성되는 `external_key` 형식은 단일 레벨 숫자 패턴 `"<n>"` (예: "1", "2", "3", ...)을 따른다.**
     - 뎁스(Depth)는 항상 1로 고정된다 (Flat).
     - 도트 표기법(`.`)을 통한 계층 구조는 생성하지 않는다.
     - 숫자 앞의 0(Zero-padding)은 허용하지 않는다.
     - `external_key`는 양의 정수의 문자열 표현이어야 한다.
  4. 동일한 마크다운 집합이 주어질 경우, `external_key`는 어떠한 상황에서도 항상 동일하게 생성되어야 한다.
  5. 파일 시스템의 물리적 순서, 운영체제(OS) 의존 정렬, 병렬 처리 순서 등 비결정론적 요소에 영향을 받아서는 안 된다.
  6. `external_key` 생성은 입력 파일 집합에 대해 항상 동일한 결과를 반환하는 **순수 함수(Pure Function)**로 정의되어야 한다.

## 4. Determinism & Transaction
1. **Deterministic Mapping**: 동일한 파일셋과 규칙이 주어지면 생성되는 `external_key` 구조와 본문 데이터는 항상 동일해야 한다.
2. **Auto-generated external_key values in Mode B must be reproducible under identical input conditions.**
3. **Internal Lineage Generation**: 모든 노드에 대해 고유한 `lineage_id`를 내부적으로 생성하며, 이는 외부 입력에 의존하지 않는다.
4. **Snapshot #1**: 생성 완료 직후 자동으로 `snapshot_count = 1`인 초기 스냅샷을 생성한다.
5. **Full Abort**: 생성 과정 중 하나라도 실패할 경우, 생성 중인 Workspace 및 관련 데이터를 모두 삭제하고 롤백한다.

## 5. Non-Goals
v1 범위에서 다음 기능은 명시적으로 제외한다.
- **Existing workspace update**: 기존 Workspace에 노드 추가 또는 본문 수정.
- **Partial body overwrite**: 특정 노드의 본문만 선택적으로 덮어쓰기.
- **Structural diff**: 기존 구조와 입력 파일 간의 차이 분석.
- **Re-import**: 기존 데이터를 무시하고 다시 가져오기.
- **Synchronization**: 파일 시스템과 Workspace 간의 실시간/수동 동기화.
- **Snapshot merge**: 서로 다른 스냅샷 간의 병합.
- **Folder grouping**: 디렉토리 구조를 기반으로 중간 계층 노드를 자동 생성하는 행위.

## 6. Success Criteria
1. 지정된 마크다운 소스로부터 새로운 Workspace가 성공적으로 생성된다.
2. **생성된 Workspace의 `snapshot_count`는 정확히 1이어야 한다.**
3. 모든 생성 노드는 고유한 `lineage_id`를 내부적으로 보유한다.
4. 생성된 트리 구조는 폴더 그룹핑이 없는 플랫(Flat)한 위상을 가진다.
5. **PRD-035(v1)로 내보낸 파일을 소스로 사용할 경우, 원본과 동일한 구조와 본문을 가진 새로운 Workspace가 재생성(Round-trip)된다.**
