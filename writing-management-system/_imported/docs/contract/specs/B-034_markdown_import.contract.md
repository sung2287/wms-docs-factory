# [B-034] Markdown Bulk Import Contract (v1 Create-only)

## 1. Identity & Structural Scope
1. **Internal Identity**: 모든 노드는 생성 시점에 외부 입력에 의존하지 않는 고유한 `lineage_id`를 내부적으로 자동 생성한다.
2. **v1 Topology Restriction**:
   - 폴더 구조를 트리 노드로 흡수하지 않는다.
   - `external_key == null` 인 그룹핑 노드(Folder grouping node)는 생성하지 않는다.
   - 모든 노드는 실제 콘텐츠를 가졌거나 명시적으로 정의된 엔티티여야 한다.

## 2. Import Modes (Creation Only)

### 2.1 Mode A: Key-based Create
- **Key Uniqueness Rule**:
  - 파일 시스템 내의 모든 `external_key`는 **Exact String Match** 기준으로 유일해야 한다.
  - 중복 발견 시 즉시 작업을 중단(Fail-Fast)하고 전체 생성을 롤백(Rollback)한다.
  - 비교는 **Case-sensitive**로 수행하며, 자동 보정(Trim, Normalization 등)은 일절 허용하지 않는다.

### 2.2 Mode B: Discovery Create
- **external_key Format**: `"<n>"` (양의 정수 문자열)
- **Constraint**: Depth는 항상 1로 고정되며, 도트 표기법 및 Zero-padding을 금지한다.
- **Pure Function Identity**: `external_key` 생성 로직은 입력 파일 집합에 대해 항상 동일한 결과를 반환하는 순수 함수여야 하며, OS/파일시스템의 정렬 순서에 영향을 받지 않아야 한다.

## 3. Deterministic Parent Auto-Creation
1. 상위 노드(Parent) 자동 생성 시, 형제 노드 간의 순서는 `external_key`의 **Natural Numeric Sort** 결과에 따라 `order_int`를 할당한다.
2. 파일 처리 순서는 시스템 환경과 무관하게 파일명의 사전식 정렬을 우선 적용한 뒤 처리를 시작한다.
