# Intent Map: DesignSpec Governance

## 1. Intent Summary
디자인 명세(DesignSpec)를 시스템의 상태 전이를 결정하는 '법적 근거'로 정의한다. 모든 명세는 비교 전 정규화 과정을 거쳐 기술적 편차(순서, null 표현 등)에 의한 오작동을 차단한다.

## 2. Fixed Policies
- **Strict Equality**: 변경 판정은 인간의 직관이 아닌 정규화된 데이터의 Deep Equality를 기준으로 한다.
- **Ordered Accumulation**: 누적 필드의 병합 결과는 입력 순서와 무관하게 정렬 기준(UTF-8)에 의해 결정론적으로 수렴한다.
- **Design Triggers Review**: 명세의 변경은 반드시 완료된 작업물의 검토 상태로 전이된다.

## 3. Forbidden Evolutions
- 정규화되지 않은 원본(Raw) 데이터를 기준으로 변경을 판정하는 로직.
- 특정 저장소 엔진(JSONB 등)의 최적화 기능에 의존한 비교 수행.

## 4. Core & Sandbox Boundary
- **Core**: 정규화 엔진, 결정론적 병합 알고리즘, 상태 전이 트리거.
- **Sandbox**: 개별 프로젝트의 특수 제약 사항(Constraints) 정의.
