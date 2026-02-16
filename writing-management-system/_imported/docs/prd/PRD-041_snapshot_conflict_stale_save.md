# [PRD-041] Snapshot Conflict & New Snapshot Policy

## 1. Objective
스냅샷 기반 시스템에서 복수의 세션이 동일 노드를 편집할 때 발생할 수 있는 데이터 충돌을 방지하고, 스냅샷 불변성(Immutability) 원칙을 준수하며 데이터 무결성을 보호한다.

## 2. In Scope
- Stale Save 및 Conflict 발생 조건 정의
- 저장 시점의 스냅샷 버전 비교 로직
- 충돌 발생 시 시스템 상태 전이 및 사용자 대응 절차
- 데이터 무결성 원칙 고정

## 3. Out of Scope
- 자동 병합(Auto-merge) 기능
- 필드 단위 부분 저장(Partial Save)
- 실시간 협업(OT/CRDT) 엔진 구현

## 4. 핵심 정책: Optimistic Locking & New Snapshot
시스템은 낙관적 잠금 메커니즘을 사용하여 변경 사항을 검증하며, 모든 결과는 새로운 스냅샷 생성으로 귀결된다.

### 4.1 Stale Save 정의
사용자가 편집을 시작한 시점의 `base_snapshot_id`가 저장 시점의 `head_snapshot_id`와 일치하지 않는 경우, 이를 'Stale Save' 시도로 간주하고 저장을 차단한다.

### 4.2 Conflict 상태 전이표

| 현재 상태 | 이벤트 | 조건 | 전이 후 상태 | 비고 |
| :--- | :--- | :--- | :--- | :--- |
| **Editing** | Save Request | `base == head` | **Success** | 신규 스냅샷 생성 및 헤드 갱신 |
| **Editing** | Save Request | `base != head` | **Conflict** | 저장 차단, 사용자 알림 발송 |
| **Conflict** | **Override Intent** | 사용자 승인 | **Success** | **기존 head를 무시하고 신규 스냅샷 생성** |
| **Conflict** | Refresh | 사용자 승인 | **Discarded** | 편집 내용 폐기, 최신 데이터 로드 |

## 5. 데이터 무결성 원칙
1. **Snapshot Immutability**: **Snapshot은 Immutable하다.** 어떤 경우에도 기존 생성된 snapshot을 수정하거나 삭제하지 않는다.
2. **Override as New Snapshot**: Override는 기존 snapshot을 덮어쓰는 것이 아니라, **기존 head를 history에 유지한 채 새로운 snapshot을 생성하여 head를 교체하는 행위**이다.
3. **Atomic Comparison**: 버전 비교와 신규 스냅샷 생성은 단일 트랜잭션 내에서 원자적으로 수행되어야 한다.

## Revision Note (v1.1)
- "Force Overwrite" 용어를 "Override Intent" 및 "신규 스냅샷 생성"으로 재정의하여 스냅샷 불변성 원칙과의 모순을 제거함.
- 어떤 상황에서도 기존 스냅샷은 수정/삭제되지 않으며 이력(History)으로 보존됨을 명문화함.
