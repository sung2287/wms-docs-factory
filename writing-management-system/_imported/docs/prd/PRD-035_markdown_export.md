# [PRD-035] Markdown Export (v1)

## 1. Objective
Workspace의 본문 콘텐츠와 메타데이터를 마크다운 파일 형태로 추출하며, PRD-034(Mode A)를 통한 완벽한 복구(Round-trip) 기반을 제공한다.

## 2. Design Principles
1. **Flat Export Model**: v1 내보내기는 모든 파일을 단일 디렉토리에 플랫하게 생성한다. 디렉토리 계층 구조를 통한 그룹화는 지원하지 않는다.
2. **Address Stability**: 파일명은 `external_key`를 포함하여 식별 가능해야 하며, 이는 PRD-034 Mode A의 매핑 키가 된다.
3. **Export Filter**: `external_key`가 할당된 노드(Section)만을 대상으로 하며, 시스템 내부의 임시 그룹핑 노드 등은 제외한다.

## 3. Round-trip Guarantee (Strict)
1. **Scope**: 본 PRD의 Round-trip 보장은 **"PRD-035 Flat Export" → "PRD-034 Mode A Import"** 조합에 대해서만 성립한다.
2. **Non-Goal (Folder Hierarchy)**: 원본 파일이 위치했던 디렉토리 계층 구조의 보존은 v1 범위에 포함되지 않는다.
3. **Constraint**: Export 시점의 `external_key`와 본문 데이터가 동일하게 복구되는 것에 집중한다.

## 4. Export Specification
- **파일명 규칙**: `{external_key}_{title}.md` (예: `1.1.1_서문.md`)
- **메타데이터**: 파일 상단 YAML Frontmatter에 `external_key`를 명시적으로 포함하여 파일명 변경 시에도 복구를 보장한다.
- **Grouping Status**: v1에서 폴더 기반의 Grouping Node가 존재하지 않으므로, 모든 Export 대상은 실제 콘텐츠를 가진 노드로 한정된다.

## 5. Success Criteria
1. 지정된 범위의 노드들이 마크다운 파일로 누락 없이 추출된다.
2. **Export된 파일을 다시 Import(PRD-034 Mode A)했을 때, Workspace의 `external_key` 구조와 본문 내용이 원본과 동일하게 유지된다.**
3. 폴더 구조는 비교 및 보존 대상에서 제외됨이 명확히 확인된다.
