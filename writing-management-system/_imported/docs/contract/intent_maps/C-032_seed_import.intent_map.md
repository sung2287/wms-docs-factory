# Intent Map: Seed Import

## 1. Intent Summary
외부 유산 데이터를 시스템의 규격(Workspace)으로 결정론적으로 변환한다. 시스템 내부 식별자(UUID)가 아닌 외부 키(external_key)를 통한 정체성 수립을 보장한다.

## 2. Fixed Policies
- **Structural Consistency**: 엑셀의 순서와 계층은 시스템의 `order_int`와 트리 위상으로 고정된다.
- **One-time Transition**: 초기 생성 이후 데이터의 SSOT는 Workspace로 이전된다.

## 3. Forbidden Evolutions
- UUID의 불변성을 보장하려는 시도 (시스템 내부 세부사항에 대한 과도한 의존).
- 비결정론적 알고리즘(예: 랜덤 샘플링, 비정렬 탐색)을 기반으로 한 키 생성.
