# [C-041] Snapshot Conflict Intent Map

## 1. Intent Summary
데이터 유실이 없는 집필 환경을 구축하기 위해 '덮어쓰기 방지'를 최상위 원칙으로 수립한다. Snapshot의 불변성을 유지하면서 다중 세션 환경에서 발생할 수 있는 데이터 경합을 안전하게 관리하고, 최종 결정권을 인간에게 부여하는 것을 목적으로 한다.

## 2. 핵심 설계 의도
- **Silent Overwrite 방지**: 사용자 A가 편집하는 동안 사용자 B가 저장했을 경우, A의 저장 시도가 B의 성과물을 조용히 지워버리는 리스크를 차단한다.
- **Snapshot 불변성 철학**: 수정(Update)이 아닌 생성(Append) 기반의 저장 구조를 고수하여 데이터의 가역성과 신뢰성을 확보한다.
- **인간 중심 제어**: 충돌 해결을 기계적인 알고리즘(Auto-merge)에 맡기지 않고, 사용자가 직접 최신 내용을 확인하고 덮어쓰거나 포기하도록 유도한다.
- **Race Condition 방어**: Override 요청 시에도 찰나의 순간에 발생하는 데이터 변경을 재검증하여 정합성을 끝까지 보호한다.

## 3. 상태 전이 다이어그램 (State Transition)

```text
[Editing]
    |
    | (Event: Save Request / Payload: base_id)
    v
[Verification Phase] (DB Lock: FOR UPDATE)
    |
    |-- (Condition: base_id == current_head) --> [Success: Create New Snapshot]
    |
    |-- (Condition: base_id != current_head) --> [Conflict State]
                                                        |
                                                        |-- (Action: Override / Payload: perceived_head_id)
                                                        |      v
                                                        |      [Re-Verification Phase] (DB Lock: FOR UPDATE)
                                                        |          |
                                                        |          |-- (Condition: perceived_head_id == current_head) --> [Success]
                                                        |          |
                                                        |          |-- (Condition: perceived_head_id != current_head) --> [Re-Conflict]
                                                        |
                                                        |-- (Action: Refresh)  --> [Discard: Reload Head]
```

---

## Revision Note (v1.2)
- Override 요청 시의 재검증(Re-Verification) 단계를 상태 전이 다이어그램에 추가함.
- 다중 사용자가 동시에 Override를 시도하는 상황에서도 최종 Snapshot이 순차적으로 올바르게 쌓이도록 설계함.
