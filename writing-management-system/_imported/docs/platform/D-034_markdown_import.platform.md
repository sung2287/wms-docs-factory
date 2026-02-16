# Platform: Markdown Bulk Import

## 1. Application Flow
- **v1 Flat Topology Policy**: 
  Folder hierarchy is not materialized as structural nodes in the Workspace. Only external_key-based hierarchy is constructed. Folder structure is considered scanning convenience only.

1. **File Scanner**: 지정된 경로를 재귀적으로 탐색하여 마크다운 파일 목록을 확보한다.
2. **Identity & Key Extractor**: 파일명 또는 YAML Frontmatter에서 `external_key`를 추출한다.
3. **Discovery Generator (Mode B)**: `external_key`가 없는 경우, 내추럴 숫자 정렬 순서에 따라 단일 레벨(`"<n>"`) 키를 자동 생성한다.
4. **Hierarchy Integrity Checker**: 모든 노드가 올바른 부모 키 구조를 가지고 있는지, 중복된 키는 없는지 검증한다.
5. **Entity Transformer**: 마크다운 본문을 `Snippet` 엔티티로 변환하고, 각 노드에 `lineage_id`를 할당한다.
6. **Persistence**: Workspace, Nodes, Snippets를 원자적으로 저장한다.
7. **Finalization**: `"Initial Markdown Import"` 메시지와 함께 초기 Snapshot을 생성한다.

## 2. Key Uniqueness Rule (Mode A)
- 추출된 `external_key`에 대해 Case-sensitive하게 유일성을 검사하며, 충돌 시 즉시 Fail-Fast 한다.

## 3. Determinism
- **Deterministic File Sorting**: File scan results must be sorted using **natural numeric sort** before processing. No reliance on underlying filesystem order is permitted.
- **OS/FS Agnostic Integrity**: Sorting and mapping must be deterministic across different operating systems and file systems to ensure consistent Workspace creation.
- **Pure Function Logic**: `external_key` 생성 및 노드 매핑 로직은 입력 파일 집합이 동일할 경우 항상 동일한 결과를 반환하는 순수 함수로 동작해야 한다.
