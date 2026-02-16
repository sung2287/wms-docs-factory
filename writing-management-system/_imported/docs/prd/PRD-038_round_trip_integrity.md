# [PRD-038] Workspace Round-Trip Integrity Guarantee

## 1. Problem Statement
데이터의 외부 추출(Export)과 재유입(Import) 과정에서 발생할 수 있는 미세한 정보 유실이나 구조적 변이는 시스템의 신뢰성을 근본적으로 훼손한다. 특히 v1 아키텍처에서 정의한 `external_key` 기반의 플랫 토폴로지와 본문 데이터가 환경에 관계없이 완벽하게 대칭을 이루는지 물리적으로 증명할 수 있는 보증 계층이 필요하다.

## 2. Objective
본 PRD는 Workspace의 데이터를 마크다운으로 내보낸 후 다시 가져왔을 때, 원본과 동일한 구조와 내용을 유지하는지 검증하는 **"읽기 전용 무손실 보증 계층(Lossless Guarantee Layer)"**을 정의한다. 본 기능은 데이터의 수정, 복구, 또는 차이점 제안을 목적으로 하지 않으며, 오직 정합성 여부를 판정하여 보고하는 데 집중한다.

## 3. In Scope
- Workspace 스냅샷 데이터와 가져오기 결과물 간의 위상(Topology) 정합성 검증
- 본문(Snippet Body)의 의미적 동등성 검증 (B-040 정규화 기준)
- 검증 결과 보고서(Integrity Report) 생성

## 4. Out of Scope
- 불일치 발생 위치에 대한 원본 데이터 자동 복구
- 구조 변경(PRD-039)과의 연동 및 분석
- 사용자 인터페이스를 통한 시각적 Diff 노출
- 본문 외 메타데이터(Review State 등)의 복구 검증

## 5. Verification Path (고정 경로 선언)
검증은 반드시 다음의 고정된 단방향 경로를 통해서만 수행되어야 하며, 다른 모드와의 조합은 허용하지 않는다.
- **Path**: `PRD-035 (v1 Markdown Export)` → `PRD-034 (Mode A Create-only Import)`

## 6. Comparison Rules
검증 엔진은 아래 항목에 대해서만 정합성을 판정한다.
- **external_key set equality**: 원본과 대상의 `external_key` 집합이 1:1로 완벽히 일치해야 한다.
- **parent-child topology equality**: 각 노드의 부모-자식 관계가 동일하게 형성되어야 한다.
- **snippet.body equality**: 
    - 비교 전 반드시 **B-040(Markdown Body Sync)**을 SSOT로 참조하여 Canonical Normalization을 수행한다.
    - 정규화된 결과물이 바이트 단위로 일치(Byte-equal)해야 한다.
- **lineage_id existence**: 모든 노드는 `lineage_id`를 보유해야 한다. 단, 값의 동일성(Equality)은 검증 대상에서 제외한다.
- **Exclusion**: 파일 시스템의 폴더 계층 구조(Folder Hierarchy)는 비교 및 보증 범위에서 제외한다.

## 7. Determinism Requirement
- 모든 데이터 정렬은 **Natural Numeric Sort**를 사용한다.
- 운영체제나 파일 시스템의 반복 순서(Iteration Order)에 절대 의존하지 않는다.
- 동일한 입력 스냅샷에 대해 생성되는 검증 결과(IntegrityReport)는 항상 바이트 단위로 동일해야 한다.

## 8. Failure Semantics (Fail-Fast)
검증 엔진은 엄격한 **Fail-Fast** 원칙을 따른다.
- **Immediate Abort**: 첫 번째 불일치(Mismatch) 발견 즉시 검증을 중단한다.
- **Report Content**: v1에서는 불일치 내역(diff)을 최대 1건만 기록한다.
- **Strict Pass**: PASS 판정은 모든 검증 항목이 오차 없이 완전 일치할 때만 허용한다. 부분적 성공(Partial Success)은 무조건 FAIL로 간주한다.

## 9. Cleanup & Mutation Rules
- **No Side Effects**: 본 검증은 원본 Workspace를 절대 수정하지 않는다. (Read-only)
- **No Snapshot**: 원본 Workspace에 어떠한 스냅샷이나 메타데이터도 생성하지 않는다.
- **Mandatory Cleanup**: 검증을 위해 생성된 임시(Temporary) Workspace 및 디렉토리는 검증 리포트 발행 직후 즉시 물리적으로 삭제한다.

## 10. v1 Explicit Defer
아래 기능은 v1 범위에서 제외하며 v2 이후로 연기한다.
- 다중 불일치 내역의 누적(Diff accumulation) 및 상세 분석
- 영향도 시각화(Impact visualization) 대시보드
- 구조적 자동 복구(Structural auto-recovery) 엔진
- PRD-039와 연계된 차이점 기반 자동 복구 제안 로직

## 11. Test Constitution v1.7 적용 의도
테스트 헌법 v1.7에 의거하여, 본 보증 계층은 다양한 환경(Linux/Windows/macOS)에서 동일한 마크다운 파일셋에 대해 일관된 검증 결과를 도출하는지 확인하는 **환경 독립적 결정론 테스트**를 최우선으로 수행한다. 특히 줄바꿈 및 공백 정규화가 정합성 판정에 미치는 경계값 테스트를 강제한다.
