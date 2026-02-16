# [B-038] Workspace Round-Trip Integrity Contract

## 1. Domain Model: Verification Path
- **Source Context**: 원본 Workspace의 특정 Snapshot.
- **Export Artifact**: PRD-035(v1) 규격으로 내보내진 마크다운 파일셋.
- **Verification Target**: 내보내진 파일셋을 PRD-034(Mode A)로 읽어 들여 생성한 **임시(Temporary) Workspace**.
- **Integrity Report**: 검증 결과(성공/실패 내역 및 불일치 지점)를 담은 읽기 전용 문서.

## 2. Core Constraints & Validation Rules (Fail-Fast)
검증 엔진은 다음 항목이 완벽하게 일치하지 않을 경우 즉시 **Fail-Fast**하며 에러 리포트를 생성한다.
1. **Key-Topology Match**: 원본과 임시 Workspace의 `external_key` 집합이 1:1로 대응해야 하며, 트리 위상(부모-자식 관계)이 동일해야 한다.
2. **Body Equality**: 동일한 `external_key`를 가진 노드 간의 `snippet.body`가 바이트 단위로 일치해야 한다.

### 2.1 Canonical Comparison Rule
1. Body equality comparison must apply the same canonical normalization rules defined in B-040_markdown_body_sync.contract.md prior to performing byte-level comparison.
2. Canonical normalization includes:
   - Line ending normalization to LF (`\n`)
   - Removal of trailing whitespace
   - UTF-8 encoding enforcement
   - No additional formatting or transformation
3. Only after normalization may byte-level equality comparison be executed.
4. Fail-fast must still emit an Integrity Report before temporary workspace cleanup.

3. **Identity Requirement**: 모든 노드는 내부적으로 고유한 `lineage_id`를 보유해야 한다. (단, 신규 생성된 임시 Workspace의 `lineage_id` 값 자체는 원본과 다를 수 있으나 "존재함"은 필수 조건이다.)
4. **v1 Exclusion**: 파일 시스템의 폴더 계층 구조는 비교 대상에서 제외한다.

## 3. Determinism 조건
1. **Environment Agnostic**: 검증 결과는 운영체제, 파일 시스템 순서, 인코딩 환경에 의존하지 않아야 한다.
2. **Pure Comparison**: 검증 로직은 입력된 두 데이터 셋(원본 스냅샷, 내보내기 파일)에 대해 항상 동일한 합격/불합격 판정을 내리는 순수 함수로 동작한다.

## 4. Snapshot & Persistence Rules
1. **Read-only Verification**: 본 계약은 원본 Workspace를 수정하지 않는 읽기 전용 검사이다.
2. **Temporary Cleanup**: 검증을 위해 생성된 임시 Workspace 데이터는 검증 종료(리포트 생성) 직후 물리적으로 완전히 삭제되어야 한다.
3. **No Snapshot**: 원본 Workspace에 어떠한 스냅샷도 생성하지 않는다.

## 5. Forbidden States / Forbidden Evolutions
- **Partial Integrity**: 본문은 일치하나 키 구조가 다른 상태(또는 그 반대)를 "성공"으로 간주하는 행위 금지.
- **Lineage Collision**: 검증 과정 중 `lineage_id` 중복이 발생하는 상태 금지.

## 6. Atomicity (Transaction)
- 검증 파이프라인(Load -> Import -> Compare -> Report -> Cleanup)은 단일 검증 세션 내에서 원자적으로 관리되어야 하며, 중간 단계의 잔재 데이터가 남아서는 안 된다.
