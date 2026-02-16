# Intent Map: Re-Import Strategy

## 1. Intent Summary
설계의 진화를 추적할 수 있는 안정적인 식별자(`lineage_id`)를 도입하여, 구조 변경과 정체성 변경을 분리한다. 모든 변경은 엄격한 우선순위에 따라 원자적으로 적용된다.

## 2. Fixed Policies
- **Anchor Over Key**: 동일성 판정의 주권은 가변적인 `external_key`가 아닌 고정된 `lineage_id`에 있다.
- **Sequential Application**: Diff 충돌 방지를 위해 선(先) 구조 변경, 후(後) 데이터 업데이트 원칙을 고수한다.

## 3. Forbidden Evolutions
- `lineage_id` 없이 `external_key`의 유사도 등으로 노드 동일성을 추정하는 로직.
- 구조 변경과 데이터 업데이트를 병렬로 처리하여 상태 일관성을 해치는 행위.
