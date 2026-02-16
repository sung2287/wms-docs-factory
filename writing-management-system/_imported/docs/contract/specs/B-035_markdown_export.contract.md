# [B-035] Markdown Export Contract (v1)

## 1. Node Filtering & Integrity
1. **Target Filtering**: `external_key != null`인 노드만을 내보내기 대상으로 삼는다.
2. **v1 Structural Assumption**: v1 시스템에서는 `external_key == null`인 그룹핑 노드가 존재하지 않음을 전제로 하며, 방어적 로직으로서 여전히 NULL 체크를 수행한다.

## 2. Round-Trip Guarantee Clause
1. **Scope Definition**: 본 내보내기 결과물에 대한 Round-trip 보장 범위는 **"PRD-035(v1) Export" → "PRD-034(v1) Mode A Create-only"** 경로로 한정한다.
2. **Hierarchy Exclusion**: 파일 시스템의 디렉토리 계층 보존 및 복구는 v1의 범위를 벗어나며(Out-of-scope), 오직 `external_key`와 본문 데이터의 정합성만을 보장한다.

## 3. Read-only Integrity
1. 본 공정은 영구 저장소의 상태를 변경하지 않는 **Read-only** 작업이다.
2. 내보내기 수행 중 또는 수행 직후 어떠한 형태의 스냅샷(Snapshot)도 생성하지 않음을 보장한다.

## 4. Format Determinism
1. YAML Frontmatter의 필드 순서는 UTF-8 사전식 순서로 고정하여 직렬화한다.
2. 동일한 Workspace 스냅샷에서 수행된 내보내기는 바이트 단위로 동일한 파일셋을 생성해야 한다.
