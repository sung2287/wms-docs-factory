# Contract: Seed Import & Initial Mapping

## 1. Identity & Structure Determinism
Seed Import의 결과물인 Workspace는 다음 요소에 대해 결정론적(Deterministic)이어야 한다.
1. **external_key**: 엑셀의 계층 구조와 볼륨 인덱스를 기반으로 사전에 정의된 알고리즘에 의해 생성된다.
2. **order_int**: 엑셀 내의 물리적 행 순서를 기반으로 생성된다.
3. **Tree Topology**: 노드 간의 부모-자식 관계는 입력 데이터의 구조적 선언과 1:1 대응해야 한다.

## 2. Semantic Equality
Snapshot의 결정론은 "의미적 동등성"을 의미한다.
- 내부 식별자인 UUID는 매 실행마다 달라질 수 있으나, 시스템의 동작과 데이터 정체성에 영향을 주지 않는 세부 구현 사항으로 간주한다.
- `external_key`가 동일한 노드의 모든 속성(Spec, Body)이 동일하다면 두 Snapshot은 동등하다.

## 3. Mapping Invariants
- **Volume Identity**: 파일명에서 추출된 볼륨 인덱스는 유일해야 한다.
- **Node-Snippet 1:1**: 모든 노드는 대응하는 Snippet을 가져야 하며, 리프 노드는 마크다운 본문을 포함해야 한다.

## 4. Validation & Failure
- 어떠한 정합성 오류(중복 키, 매핑 누락 등)라도 발견될 경우, 전체 프로세스는 원자적으로 중단되며 데이터는 유지되지 않는다.
