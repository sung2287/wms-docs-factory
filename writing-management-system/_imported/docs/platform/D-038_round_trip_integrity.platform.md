# [D-038] Platform: Round-Trip Integrity Verification Flow

## 1. Layering

- **Core**:
  - `CanonicalNormalizer`: 본문 비교 전 표준화 수행 (B-040과 공유).
  - `TopologyComparator`: 트리 구조 및 키 집합 정합성 검증.
  - `BodyComparator`: 정규화된 본문의 바이트 단위 비교.
  - `IntegrityReportGenerator`: 검증 결과 리포트 직렬화.

- **Adapter**:
  - `MarkdownExporter`: PRD-035 규격에 따른 파일 출력.
  - `TemporaryWorkspaceFactory`: 검증용 임시 워크스페이스 생성 (PRD-034 Mode A 기반).
  - `FileSystem I/O`: 파일 시스템 읽기/쓰기 및 임시 디렉토리 제어.

- **App**:
  - `RoundTripVerificationService`: 전체 검증 공정을 제어하는 오케스트레이터.

## 2. Execution Flow

1. **Load**:
   - 원본 Workspace의 Head Snapshot 데이터를 로드한다.
   - 이 과정에서 원본 데이터에 대한 어떠한 수정(Mutation)도 허용되지 않는다.

2. **Export Phase**:
   - Invoke PRD-035 Markdown Export.
   - 결과물을 임시 디렉토리에 저장한다.
   - 파일명 및 메타데이터의 직렬화는 결정론적(Deterministic)이어야 한다.

3. **Re-Import Phase**:
   - Create a temporary Workspace.
   - Invoke PRD-034 Mode A Create-only import.
   - v1 Flat Topology 정책에 따라 그룹핑 노드(Grouping Node)가 생성되지 않음을 보장한다.

4. **Topology Comparison**:
   - Compare node count.
   - Compare external_key set equality.
   - Compare parent-child relationships.
   - lineage_id equality is NOT required (모든 노드가 보유하고 있는지는 확인).
   - Fail-fast on mismatch.

5. **Body Comparison**:
   - Apply canonical normalization (as defined in B-040):
       * LF normalization
       * Trailing whitespace removal
       * UTF-8 enforcement
   - Perform byte-level comparison.
   - Fail-fast on mismatch.

6. **Report Generation**:
   - 다음과 같은 스키마를 가진 `IntegrityReport`를 생성한다:
       ```json
       {
         "status": "PASS" | "FAIL",
         "topology_diff": [],
         "body_diff": []
       }
       ```

7. **Cleanup**:
   - Delete temporary Workspace.
   - Delete temporary export directory.
   - No snapshot creation.

## 3. Determinism Requirements

- 모든 데이터의 나열 및 처리 순서에는 **내추럴 숫자 정렬(Natural Numeric Sort)**을 사용한다.
- No reliance on filesystem iteration order.
- Given identical input Snapshot, the generated report must be byte-identical.

## 4. Failure Semantics

- Partial success is forbidden.
- On first mismatch:
    - Record diff
    - Abort comparison
    - Emit FAIL report
- When status = FAIL, the IntegrityReport must contain at least one entry in either topology_diff or body_diff.
- Even in fail-fast scenarios, IntegrityReport generation must occur before cleanup.
- Original Workspace must remain unchanged.
