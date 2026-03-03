# Policy System Reboot Design Canvas v2 — 적합성 검토 보고서

**검토일**: 2026-03-03  
**대상 문서**: `policy_system_reboot_design_canvas_v_2.md`  
**이전 검토**: `policy_system_reboot_design_v1_review.md` (2026-03-03)

---

## 0. 총평

> [!IMPORTANT]
> v1 검토 피드백이 **정확하게 반영**되었다.
> 기존 레포 계약(CORE_INVARIANTS, Hook Class Split, next-session effect model)과의 충돌이 모두 해소되었으며,
> 새로 추가된 **UX Soft-Denial Principle (§10)** 은 Master Blueprint의 비차단 철학과 잘 어울리는 좋은 확장이다.

| 평가 항목 | v1 판정 | v2 판정 | 변화 |
|:--|:--|:--|:--|
| 역할 분리 원칙 (§1) | ⚠️ | ✅ | Engine → Orchestrator/Graph/PlanExecutor 매핑 완료 |
| 정책 표현 3계층 (§2) | 🆕 | 🆕 ✅ | 유지 (변경 없음, 정합 판단 동일) |
| 정책 센터 (§3) | ⚠️ | ⚠️ → ✅ | PRD-036/037 범위와 공존 가능하도록 조정됨 |
| 자연어 변환 (§4) | ❌ Determinism 충돌 | ✅ | compiled_rule SSOT + 저장 시점 확정으로 해결 |
| 실행 루프 (§5) | ✅ | ✅ | next-session effect model 명시 |
| 정책 0개 상태 (§6) | ✅ | ✅ | 유지 |
| 즉시 적용 (§7) | ✅ | ✅ | 유지 |
| BLOCK 분류 (§8) | ⚠️ Hook Class 충돌 | ✅ | Safety Hook / Guardian Hook 분리 명시 |
| 실행 계획 (§9) | ⚠️ | ⚠️ | 유지 (기존 PRD 매핑 여전히 필요) |
| UX Soft-Denial (§10) | — | 🆕 ✅ | 신규 추가. 좋은 방향 |
| 성공 기준 (§11) | ✅ | ✅ | Soft-Denial 반영으로 확장됨 |

---

## 1. v1 피드백 반영 상세 확인

### ✅ [해결됨] 역할 분리 용어 매핑 (§1.1)

**v1 문제**: "Engine"이라는 단일 용어가 레포의 Orchestrator/Graph/PlanExecutor 다계층 구조를 모호하게 만들었다.

**v2 수정**:
```
Engine (레포 용어로는 단일체가 아님):
- Orchestrator → Graph(runGraph) → PlanExecutor(executePlan/plan.executor.ts) 계층이
  합쳐서 "흐름 엔진" 역할을 수행
```

**판정**: ✅ 정합. 레포의 실제 계층 구조를 정확히 참조하고 있다.

---

### ✅ [해결됨] Guardian 결과 유형 (§5)

**v1 문제**: MISSING_POLICY / AMBIGUOUS 등 새 유형이 기존 `ValidatorFinding` (ALLOW/WARN/BLOCK) 계약과 충돌.

**v2 수정**:
```
기본 타입은 ALLOW/WARN/BLOCK을 유지하고,
필요한 경우 BLOCK/WARN에 메타데이터(예: reasonCode, recommendedActions)를 부가하는 방식으로 확장
```

**판정**: ✅ 정합. 기존 `ValidatorFinding` 인터페이스에 optional 필드를 추가하는 방식은 **PRD-022/031의 CLOSED 계약을 깨지 않으면서** 표현력을 확장할 수 있는 가장 안전한 경로다.

> [!TIP]
> 구현 시 `ValidatorFinding` 타입에 `reasonCode?: string`, `recommendedActions?: string[]` 같은 optional 필드를 추가하면 된다.  
> 기존 validator들은 이 필드를 생략하면 되므로 하위 호환성이 유지된다.

---

### ✅ [해결됨] Determinism 충돌 (§4.2)

**v1 문제**: LLM 기반 자연어 파싱의 비결정론성이 CORE_INVARIANTS §6과 충돌.

**v2 수정**:
```
저장 시점에 생성된 compiled_rule을 그대로 영구 저장(SSOT)하고,
실행은 항상 저장된 compiled_rule만 사용
```

**판정**: ✅ 해결됨. 이 모델에서:
- LLM 파싱은 **정책 초안 생성 시점에만** 1회 실행
- 저장된 `compiled_rule`이 SSOT → 이후 실행은 **항상 결정론적**
- 동일 `compiled_rule` + 동일 Pin = 동일 결과 → **CORE_INVARIANTS §6 준수**

추가로 §4.3에서 "compiled_rule은 UI에서 편집 불가(읽기 전용)"을 명시한 것도 좋다. 사용자가 `compiled_rule`을 직접 조작할 경로를 원천 차단함으로써 SSOT 무결성을 보장한다.

---

### ✅ [해결됨] BLOCK 분류 (§8)

**v1 문제**: Non-overridable BLOCK이 Guardian에서 발생할 수 있다는 암시가 System Runtime Hook Class Split LOCK에 위반.

**v2 수정**:
```
1) Safety/Integrity Hook (Core Safety Contract 영역)
   - 실행 중단(진짜 fail-fast) 권한 보유

2) Guardian/Policy Hook (ValidatorFinding 기반)
   - BLOCK이라도 "실행 중단 권한"은 없음
   - BLOCK은 InterventionRequired 전환의 근거(= 사용자 개입 필요 신호)로만 사용

따라서 "Non-overridable" 성격의 중단은 Guardian이 아니라 Safety Hook에서만 발생해야 한다.
```

**판정**: ✅ 완전 정합. `02_SYSTEM_RUNTIME.md` §1.x Hook Class Split Contract의 내용을 정확히 반영했다.

---

## 2. 신규 섹션 평가

### 🆕 §10. UX Soft-Denial Principle — ✅ 좋은 방향

이 섹션은 v1에 없던 완전히 새로운 추가이며, 세 가지 기존 원칙과 잘 맞는다:

| v2 제안 | 기존 원칙 매핑 |
|:--|:--|
| "Hard denial 대신 재프레이밍" | Master Blueprint §I: "비차단(Non-blocking) 원칙" |
| "항상 최소 1개 실행 가능 선택지" | PRD-034: KEEP/MODIFY/REGISTER 3-way 분기 |
| "Core Invariants를 직접 노출하지 않음" | Master Blueprint §IV: "연료 게이지 시각화" (내부를 은닉, 통제감 제공) |

> [!NOTE]
> Layer 0 "Core Invariants 위반 시 실행 중단이 아니라 범위 재설정 + 대안 제시"는 **UX 레벨의 표현 방식**으로는 좋지만,
> **시스템 레벨에서는 여전히 Fail-fast가 발생**한다는 점을 혼동하지 않아야 한다.
> 
> 즉:
> - Core에서는 `FailFastError`가 throw됨 (System Runtime §4.2)
> - UI에서는 이 에러를 잡아서 사용자 친화적 메시지로 변환
> - 이 두 레이어의 경계를 명확히 해야 한다.

**권장 보강**: §10.2 Layer 0에 다음 문장 추가를 고려:

```
시스템 내부적으로는 Core Safety Contract 위반 시 FailFastError가 발생하며(변경 없음),
UX 레이어에서 이를 사용자 친화적 재프레이밍으로 변환하는 것이 이 원칙의 범위이다.
```

---

### 🆕 §11. 성공 기준 4~5 — ✅ 좋은 확장

v1 대비 추가된 성공 기준:
- \#4: "정책/가디언 위반이 있어도 Hard Stop 대신 안전한 분기 제안이 표시됨"
- \#5: "Core Invariant 위반 시에도 UX는 중단이 아니라 재프레이밍 기반 안내로 전환됨"

이 기준들은 Soft-Denial Principle과 일관되며, 측정 가능하다.

---

## 3. 잔여 검토 사항 (새로 발생한 것은 아니나 여전히 유효)

### ⚠️ §2. 정책 표현 3계층 — 구현 경로 구체화 필요

v2에서 변경되지 않았으므로 v1 리뷰 의견이 그대로 유효하다:

- 현재 `policy_registry` 테이블에 `raw_text`, `compiled_rule` 컬럼을 추가하는 스키마 마이그레이션 필요
- `compiled_rule`의 정확한 포맷을 정의해야 함 (PRD-008의 `NormalizedExecutionPlan` 호환? 신규 구조?)
- PlanHash 계산에서 `compiled_rule`이 포함되는지 여부를 명시해야 함

### ⚠️ §9. Phase 실행 계획 — PRD 매핑 미갱신

Phase 2의 "Guardian 실행 판정 결과를 표준 신호로 통일" + "Engine Intervention 루프 연결"은 **이미 PRD-022/034/035에서 구현 완료**되었다. v2에서 이 사실을 반영하여 Phase 2를 조정하면 좋겠다.

제안:
```
Phase 2 (수정안):
- ValidatorFinding에 reasonCode/recommendedActions 메타데이터 확장
- Policy Center ↔ Guardian 등록 시점 검증 연동
- (기존 Intervention 루프는 PRD-034/035에서 완료됨 — 재구현 불필요)
```

---

## 4. 종합 판정

| 항목 | 판정 |
|:--|:--|
| 기존 CORE_INVARIANTS 충돌 | ✅ 없음 |
| Hook Class Split Contract 충돌 | ✅ 없음 |
| Hash Separation / Determinism 충돌 | ✅ 없음 (compiled_rule SSOT로 해결) |
| PersistSession / Post-Run Boundary 계약 충돌 | ✅ 없음 |
| Master Blueprint 철학 정합성 | ✅ 정합 (비차단 + 통제감 + 판단 분리) |
| 구현 가능성 | ⚠️ 별도 PRD 2~3개 필요 (NLP 파서, 스키마 확장, Policy Center API) |

### 최종 결론

> v2 디자인 캔버스는 **현재 레포의 아키텍처 계약과 완전히 정합**하며,
> PRD 시리즈(037~039)로 분해하여 순차 구현할 수 있는 상태이다.
> 
> 다음 단계로 **PRD-037 (Policy Center API + 정책 0개 fallback)** 작성을 권장한다.

---

*End of Review*
