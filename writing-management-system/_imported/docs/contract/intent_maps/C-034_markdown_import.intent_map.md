# [C-034] Intent Map: Markdown Bulk Import

## 1. Intent Summary
대량의 마크다운 파일로부터 새로운 Workspace를 생성하고, 파일명이나 메타데이터에 포함된 정보를 구조적 초기 권위로 활용하는 도구의 설계 의도를 정의한다.

## 2. Fixed Policies (고정 정책)
- **Structural Authority**: v1에서 파일명(또는 내부 `external_key`)은 일회성 구조적 권위(One-time structural authority)로 작용한다. 생성 후에는 시스템 내부 Snapshot이 SSOT가 된다.
- **Flat Topology**: 파일 시스템의 폴더 계층은 입력 편의를 위한 장치일 뿐이며, 시스템 내부 구조(SSOT)로 흡수하지 않는 Flat Topology를 유지한다.
- **Identity Separation**: `lineage_id`는 내부 정체성 앵커이며, `external_key`는 논리적 주소를 나타내는 내비게이션 키(Navigation Key)로 분리 운영한다.
- **Create-only Scope**: v1은 신규 생성을 위한 Create-only 도구로 한정한다. 이름 변경(Rename)이나 인덱스 재부여(Re-index)에 대한 강건성 확보는 v1 범위에서 제외한다.

## 3. Forbidden Evolutions (금지된 진화)
- 기존 Workspace의 본문을 업데이트하거나 동기화하는 행위 (해당 기능은 PRD-040/039 영역으로 위임).
- 폴더 구조를 기반으로 중간 그룹핑 노드를 자동 생성하여 Flat 원칙을 깨는 행위.

## 4. Core & Sandbox Boundary
- **Core**: 파일 매핑 엔진, `lineage_id` 생성, 원자적 생성 트랜잭션.
- **Sandbox**: 파일 시스템의 물리적 경로 및 폴더 구성 방식.

## 5. Future Expansion
- 기존 Workspace와의 구조적 동기화(Sync) 기능은 v2 이후로 연기한다.

## 6. Test Constitution v1.7 준수 의도
중복된 `external_key` 파일이 입력될 때 시스템이 정확히 Fail-Fast 하며 롤백을 수행하는지 검증한다.
