# [C-035] Intent Map: Markdown Export

## 1. Intent Summary
Workspace의 데이터를 외부로 추출하여 집필 및 보관의 유연성을 제공하며, 특정 조건하에서의 완벽한 라운드트립(Round-trip) 안정성을 확보한다.

## 2. Fixed Policies (고정 정책)
- **Round-trip Stability**: 라운드트립 보장은 오직 **"PRD-035(v1) Export → PRD-034(v1) Mode A Create-only Import"** 조합에 대해서만 성립한다.
- **Hierarchy Out-of-scope**: 파일 시스템의 폴더 계층 구조 보존은 v1 범위에서 명시적으로 제외(Out-of-scope)한다.
- **Read-only Integrity**: 본 공정은 시스템 상태를 변경하지 않으며, 스냅샷을 생성하지 않는다.
- **Deterministic Serialization**: YAML Frontmatter 및 본문의 직렬화는 사전식 정렬을 포함한 결정론적 규칙을 따른다.

## 3. Forbidden Evolutions (금지된 진화)
- 내보내기 시점에 원본 데이터를 변형하거나 포맷을 재구성하는 비가역적 행위.
- `external_key`가 없는 노드를 내보내기에 포함하여 라운드트립 정합성을 해치는 행위.

## 4. Core & Sandbox Boundary
- **Core**: 데이터 직렬화 규칙, 내보내기 필터링 로직.
- **Sandbox**: 로컬 파일 시스템의 저장 위치 및 파일명 인코딩 방식.

## 5. Future Expansion
- 폴더 구조를 포함한 계층적 내보내기는 v2 이후로 연기한다.

## 6. Test Constitution v1.7 준수 의도
Export된 파일셋을 다시 Import 했을 때, 원본과 바이트 단위로 동일한 본문(정규화 후)이 복구되는지 검증한다.
