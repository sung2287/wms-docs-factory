# [B-041] Snapshot Conflict Contract

## 1. Domain Concepts
- **Snapshot**: 워크스페이스 노드의 상태를 기록한 불변(Immutable) 데이터 단위.
- **base_snapshot_id**: 클라이언트가 편집을 시작할 때 참조한 스냅샷 식별자.
- **head_snapshot_id**: 시스템 내 저장된 해당 노드의 가장 최신 스냅샷 식별자.
- **Stale Save**: `base_snapshot_id`와 `head_snapshot_id`가 불일치하는 상태에서의 저장 시도.
- **Conflict**: Stale Save 감지로 인해 저장이 거부된 상태.
- **Override Intent**: 충돌 발생 시 확인된 특정 `head_snapshot_id`를 명시적으로 무시하고 자신의 편집본을 새 스냅샷으로 생성하려는 사용자 의도.

## 2. State Invariants
- **Immutability**: 생성된 모든 Snapshot은 수정, 삭제, 교체가 불가능하다.
- **Single Head**: 특정 시점에 특정 노드의 유효한 `head`는 단 하나만 존재한다.
- **Safety Guard**: 저장 요청 시 검증 대상 ID가 현재의 `head_snapshot_id`와 일치하지 않으면 어떠한 데이터 변경도 허용하지 않는다.

## 3. Conflict Detection Rule
- 저장 엔진은 요청의 `base_snapshot_id`와 영속성 계층의 `head_snapshot_id`를 비교한다.
- 불일치 시 엔진은 즉시 `Conflict` 상태를 반환하고 트랜잭션을 중단한다.

## 4. Override Rule (Re-verification Required)
- 사용자가 Override를 요청할 때도 서버는 **현재의 `head_snapshot_id`를 다시 조회**해야 한다.
- **Double-check**: 사용자가 Conflict 화면에서 인지하고 승인한 `head_snapshot_id`와 저장 시점의 최신 `head_snapshot_id`가 일치하는 경우에만 신규 Snapshot 생성을 허용한다.
- **Re-conflict**: 만약 사용자가 확인한 `head` 버전조차 그 사이 다른 작업에 의해 갱신되었다면(2차 레이스 컨디션), 재차 `Conflict`를 반환해야 한다.
- 이 모든 검증 과정은 반드시 **단일 트랜잭션** 내에서 수행되어야 한다.

## 5. Atomicity
- `head` 조회(잠금 포함), 버전 비교, 신규 Snapshot 생성, `head` 포인터 갱신은 원자적으로 수행된다.

## 6. Non-Goals
- 자동 병합(Auto-merge) 및 필드 단위 부분 저장 금지.
- 엔진 레벨의 텍스트 차이점 분석 기능 제공 금지.

---

## Revision Note (v1.2)
- Override 요청 시 발생할 수 있는 레이스 컨디션을 방어하기 위해 '인지된 Head'에 대한 재검증 정책을 추가함.
- 트랜잭션 내 `FOR UPDATE`를 통한 잠금 조회 및 불일치 시 재충돌(Re-conflict) 반환 로직을 명문화함.
