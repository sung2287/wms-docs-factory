# [C-038] Intent Map: Workspace Round-Trip Integrity

## 1. Intent Summary
본 문서는 시스템의 내보내기(Export)와 가져오기(Import) 공정이 데이터 손실 없이 완벽하게 대칭을 이루는지 검증하는 '보증 레이어'의 설계 의도를 정의한다. Round-trip integrity는 시스템의 상태를 변경하지 않는 읽기 전용 검증 프로세스이며, 외부 유산 데이터와 시스템 내부 데이터 간의 정합성 신뢰도를 물리적으로 증명하는 것을 목적으로 한다.

## 2. Fixed Policies (고정 정책)
- **Validation Path**: 검증 경로는 반드시 `PRD-035(v1 Export)` -> `PRD-034(v1 Mode A Create-only Import)` 조합으로 고정한다.
- **Comparison Authority**: 
    - **Structure**: `external_key`를 기반으로 한 트리 위상(Topology)이 완벽하게 일치해야 한다.
    - **Body**: B-040과 동일한 정규화(LF, Trailing Whitespace 제거, UTF-8)를 거친 후 바이트 단위(Byte-equal)로 비교한다.
- **Identity Scope Clarification**: Round-trip integrity comparison does not require equality of lineage_id values. However, all nodes must possess a lineage_id. lineage_id is an internal identity anchor and not part of structural or body equality comparison.
- **V1 Exclusion**: 파일 시스템의 폴더 계층 구조 보존 여부는 v1 비교 범위에서 제외한다.
- **Ephemeral Infrastructure**: 검증을 위해 생성된 임시(Temporary) Workspace는 검증 종료 및 리포트 생성 즉시 반드시 물리적으로 삭제되어야 한다.

## 3. Forbidden Evolutions (금지된 진화)
- **Partial Success Acceptance**: 구조만 일치하거나 본문만 일치하는 '부분 성공'을 합격으로 간주하는 행위는 절대 금지한다.
- **Environmental Dependency**: 비교 로직이 실행 환경(OS, 파일 시스템 특성 등)에 따라 다른 결과를 도출하도록 방치하는 행위는 금지한다.
- **Side Effect Generation**: 검증 과정 중에 원본 Workspace의 스냅샷을 생성하거나 메타데이터를 수정하는 등 흔적을 남기는 행위는 금지한다.

## 4. Core & Sandbox Boundary
- **Core**: 비교 알고리즘(Comparison Rules), 결정론적 판정 엔진(Determinism), 결과 리포트 스키마(Report Schema).
- **Adapter**: 파일 시스템 I/O(Read/Write), 임시 Workspace 영속성 제어(Persistence).

## 5. Future Expansion (명시적 Defer)
- **Impact Analysis**: 불일치 발생 위치를 시각화하거나 요약하는 보고서 고도화 기능.
- **Structural Diff Integration**: PRD-039(구조적 변경)와의 연동을 통한 자동 복구 제안 기능은 v2 이후로 연기한다.

## 6. Test Constitution v1.7 준수 의도
테스트 헌법 v1.7에 따라, 본 검증 엔진은 입력 데이터의 미세한 공백 차이가 정규화 규칙에 의해 걸러지는지, 그리고 불일치 시 즉각적으로 Fail-Fast가 발생하는지를 검증하는 단위 테스트를 반드시 포함해야 한다.
