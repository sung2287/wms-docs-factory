# Policy System Reboot Design v1 — 적합성 검토 보고서

**검토일**: 2026-03-03  
**대상 문서**: `policy_system_reboot_design_v_1.md`  
**참조 문서**: REPO_MAP, CORE_INVARIANTS, EXIT_CRITERIA, EVIDENCE_MAPS, Master Blueprint, System Runtime, PRD-008/022/033/034/035/036

---

## 0. 총평

> [!IMPORTANT]
> 디자인 v1의 **방향성(목적 §0)**은 현재 시스템이 실제로 겪고 있는 문제를 정확히 짚고 있다.
> 그러나 현 레포는 이미 PRD-033~036을 통해 상당 부분 같은 목표를 향한 구현이 완료된 상태이며,
> v1의 일부 제안은 **기존 아키텍처 계약(CORE_INVARIANTS)과 충돌**하거나, 이미 해결된 문제를 재설계하려 한다.

| 평가 항목 | 판정 |
|:--|:--|
| 목적/문제 정의 | ✅ 정확. 현재 시스템의 핵심 문제를 잘 짚음 |
| 역할 분리 원칙 (§1) | ⚠️ 부분 정합. 기존 계약과 용어 불일치 |
| 정책 표현 계층 (§2) | 🆕 신규 개념. 기존 시스템에 없던 구조 |
| 정책 센터 (§3) | ⚠️ 기존 PRD-033/036과 중복/충돌 |
| 자연어 변환 (§4) | 🆕 신규 기능. 기존에 없는 NLP 파싱 레이어 |
| 실행 루프 (§5) | ✅ 원칙적으로 정합. 세부 구현 방식은 조정 필요 |
| 정책 0개 상태 (§6) | ✅ 좋은 개선. 현재 미정의 영역 |
| 즉시 적용 원칙 (§7) | ✅ 기존 "next-session effect model"과 일치 |
| BLOCK 분류 (§8) | ⚠️ 기존 Hook Class Split Contract와 부분 충돌 |
| 실행 계획 (§9) | ⚠️ 이미 구현된 PRD와 겹침 |

---

## 1. 역할 분리 원칙 (§1) — ⚠️ 부분 정합

### 일치하는 부분
- Guardian은 판정만 수행하고 실행 흐름을 제어하지 않는다 → **CORE_INVARIANTS §3 Authority Boundaries와 일치**
- Engine이 Guardian 결과를 해석하여 InterventionRequired를 생성한다 → **PRD-022/034의 구현과 일치**
- UI는 판단 로직을 포함하지 않는다 → **PRD-034 §5.G UI Minimal Exposure Rule과 일치**

### 충돌 또는 불일치
- v1에서 "Engine"이라 부르는 엔티티는 현재 레포에서 **`executePlan` (plan.executor.ts)** + **`runGraph` (graph.ts)** 조합에 해당한다. 단일 "Engine" 개념으로 치환하면 기존 계층 구조(Orchestrator → Graph → PlanExecutor)가 모호해진다.
- v1의 Guardian 결과 유형 중 **MISSING_POLICY / AMBIGUOUS**는 현재 시스템에 정의되어 있지 않다. 기존에는 `ValidatorFinding` (ALLOW/WARN/BLOCK) 3종만 존재한다.

> [!WARNING]
> Guardian의 결과 유형을 확장하려면 `ValidatorFinding` 타입, `plan.executor.ts#runValidators`, Guardian Audit 스키마를 모두 수정해야 한다. 이는 PRD-022/031의 CLOSED 계약에 대한 사후 수정에 해당하므로 별도 PRD가 필요하다.

---

## 2. 정책 표현 3계층 (§2) — 🆕 신규 개념

v1이 제안하는 `raw_text → compiled_rule → metadata` 3계층 구조는 현재 시스템에 존재하지 않는 **완전히 새로운 모델**이다.

### 현재 시스템의 정책 표현

```
modes.yaml → PolicyInterpreter (PRD-008) → NormalizedExecutionPlan → PlanHash
                                           └─ validators/postValidators (Guardian YAML Wiring, PRD-030)
```

- 정책은 **YAML 선언 기반** (`modes.yaml`, `pack.json`)
- `PolicyInterpreter`가 YAML → `ExecutionPlan`으로 정규화
- `compiled_rule` 같은 중간 구조체는 없음
- 자연어 원문(`raw_text`)은 **현재 시스템에 전혀 존재하지 않는 개념**

### 적합성 판단

이 계층을 도입하려면:
1. `PolicyInterpreter` (PRD-008 LOCK-3 정규화 경계)를 확장하거나 새 레이어를 추가해야 함
2. 새 스토리지 스키마 필요 (SQLite `policy_registry` 테이블에 `raw_text`, `compiled_rule` 컬럼 추가)
3. PlanHash 계산에 어떤 계층이 입력이 되는지 명확히 해야 함

> [!TIP]
> 기존 `policy_registry` 테이블 + `PolicyRegistrationRequest` 구조 위에 `raw_text` / `compiled_rule` 필드를 확장하는 방식이 가장 침습이 적다. 다만, **SSOT는 반드시 compiled_rule(= 기존 NormalizedExecutionPlan 호환 구조)**임을 명시해야 CORE_INVARIANTS §2 Hash Separation과 충돌하지 않는다.

---

## 3. 정책 센터 / 독립 등록 (§3) — ⚠️ 기존 PRD와 중복

### 이미 구현된 것 (PRD-033/034/036)
- **정책 등록**: `registration_executor.ts` — 단일 Registration Executor (CLI + Web 통합)
- **정책 목록 조회/활성화**: `PolicyRegistryStore.resolve()`, `resolveActivePolicy()`
- **정책 편집(수정/신규)**: PRD-034의 MODIFY_POLICY / REGISTER_POLICY 3-way 분기 완료
- **Web UI 진입점**: PRD-036에서 `/v2` Web Shell에 Policy Registry 패널 분리 완료
- **정책 비활성**: `PolicyRegistryStore.deprecate()` 구현 완료

### v1 대비 미구현 항목
- ❌ **자연어 기반 정책 생성 UX** (현재는 구조화된 YAML/interventionResponse 기반)
- ❌ **독립 진입점으로서의 정책 센터** (현재는 Intervention 흐름의 일부로만 접근 가능)
- ❌ **정책 자체 검증 (자가 테스트)** (Guardian은 실행 시점에만 동작)

> [!IMPORTANT]
> v1의 "정책 등록을 실행 실패의 부산물이 아니라 독립 기능으로" 라는 방향은 정확하다.
> PRD-036에서 Policy Registry 패널이 분리되었지만, 아직 **백엔드 전용 엔드포인트(`/api/policy/register`)가 미완성**(PRD-037 예정)이므로, 이 부분은 v1의 제안을 수용할 여지가 충분하다.

---

## 4. 자연어 ↔ 시스템 변환 (§4) — 🆕 신규 기능

현재 시스템에 **자연어 파싱을 통한 정책 생성 경로는 전혀 없다.**

v1이 제안하는 슬롯 구조 (`scope/action/target/strength/exceptions`)는 기존의:
- `DecisionScope` (PRD-035: `policy.<profile>.<mode>` strict 3 segments)
- `ValidatorFinding` (`validator_id`, `status`, `evidenceRefs` 등)

와 부분적으로 대응되지만, 완전히 다른 추상화 레벨이다.

### 적합성 판단

```
v1 제안:   [사용자 자연어] → Parse → compiled_rule → Guardian 검증 → 저장
현재 시스템: [YAML 선언] → PolicyInterpreter → ExecutionPlan → Guardian → PersistSession → Post-Run Registration
```

자연어 파싱 레이어를 추가하려면:
1. LLM 기반 NLP 파서 또는 규칙 기반 파서 구현 필요
2. `compiled_rule`을 `PolicyRegistrationRequest` 호환 구조로 변환하는 브릿지 필요
3. **Master Blueprint [LOCK-1]**: "자연어는 신뢰하지 않으며 항상 재컴파일한다"는 v1 §4.2의 원칙은 좋지만, LLM 파싱 자체의 비결정론성이 **CORE_INVARIANTS §6 Determinism**과 잠재적으로 충돌

> [!CAUTION]
> LLM 기반 자연어 → 정책 변환은 비결정론적이다. 동일 자연어 입력에 대해 동일한 `compiled_rule`이 생성됨을 보장할 수 없다.  
> 이것이 PlanHash나 PolicyHash에 영향을 주면 **CORE_INVARIANTS §6 (동일 입력 → 동일 결과)** 위반이 된다.  
> **해결책**: 자연어 파싱은 "정책 초안 생성" 용으로만 사용하고, 최종 저장 전 사용자가 compiled_rule을 확인/확정하는 UX가 필수.

---

## 5. 실행 루프 통합 (§5) — ✅ 원칙적 정합

v1의 실행 사이클 8단계는 현재 시스템의 실제 흐름과 거의 일치한다:

| v1 제안 | 현재 시스템 대응 |
|:--|:--|
| 1. 사용자 입력 | WebSubmitInput → RuntimeRunRequest |
| 2. Engine 실행 계획 생성 | PolicyInterpreter → NormalizedExecutionPlan |
| 3. Guardian 정책 평가 | runValidators (preflight) |
| 4. Guardian 결과 반환 | ValidatorFinding[] |
| 5. Engine 결과 해석 | plan.executor.ts의 BLOCK/WARN routing |
| 6. UI 모달 표시 | PolicyConflictProjection → SSE → App.tsx |
| 7. 사용자 선택 | interventionResponse (KEEP/MODIFY/REGISTER) |
| 8. Engine 재개 | 다음 run에서 policy adoption |

**핵심 차이**: v1은 "재개"라고 표현하지만, 현재 시스템은 **동일 세션을 재개하지 않고 다음 session에서 정책이 반영되는 "next-session effect model"**을 사용한다.

---

## 6. 정책 0개 상태 (§6) — ✅ 좋은 제안

현재 시스템에서 `policyCount == 0` 상태의 명시적 처리가 부족한 것은 사실이다.

- `resolveActivePolicy(domain)`이 null/undefined를 반환할 때의 행동이 명확히 정의되어 있지 않음
- v1의 `REGISTER` / `RUN_WITHOUT_POLICY` 두 가지 합법 액션 정의는 좋은 방향

> [!NOTE]
> 이 부분은 PRD-037 또는 후속 PRD에서 "policy-less run" fallback을 명시적으로 정의하면 된다.
> 기존 CORE_INVARIANTS와 충돌하지 않는다.

---

## 7. 즉시 적용 원칙 (§7) — ✅ 완전 정합

- "다음 사용자 입력부터 새 정책 적용" = PRD-034 §7의 **next-session effect model**
- "현재 진행 중인 턴은 소급 변경하지 않음" = PRD-034의 "현재 세션의 ExecutionPlan은 절대 재계산하지 않는다"
- "각 실행은 정책 버전 스냅샷을 고정" = Session Pinning [LOCK-12]

**결론**: 이 섹션은 기존 설계와 완벽히 일치한다.

---

## 8. BLOCK 분류 (§8) — ⚠️ 기존 계약과 부분 충돌

v1의 "Non-overridable BLOCK vs Overridable BLOCK" 이원화는 다음과 충돌한다:

### 현재 시스템의 BLOCK 계층

```
System Runtime (02_SYSTEM_RUNTIME.md) §1.x Hook Class Split Contract:

1) Safety/Integrity Hook (SYNC/BLOCKING)
   - 구조 계약 위반 → Fail-fast OK
   - 실행 중단 권한 있음

2) Guardian/Policy Hook (ASYNC/NON-BLOCKING)
   - BLOCK은 실행 중단 권한 없음
   - InterventionRequired 메타데이터 기록만
```

v1의 "Non-overridable BLOCK (안전/치명 인바리언트, 진짜 중단)"은 현재 시스템의 **Safety Hook**에 해당하며, Guardian은 이를 발행할 권한이 없다. Guardian의 BLOCK은 항상 "Overridable" 성격이다.

> [!WARNING]
> v1은 Guardian이 Non-overridable BLOCK을 반환할 수 있다고 암시하지만, 이는 **System Runtime LOCK**에 위반된다.  
> Guardian/Policy Hook의 BLOCK은 실행 단계 진행을 차단하거나 Step 흐름을 단축/우회하는 근거가 될 수 없다.

**해결책**: v1의 BLOCK 분류를 Guardian 범위 내에서만 적용하되:
- Non-overridable → Safety Hook (Core Safety Contract 영역, Guardian 소관 아님)
- Overridable → Guardian BLOCK (현재 동작과 동일)

---

## 9. Phase별 실행 계획 (§9) — 기존 PRD와 매핑

| v1 Phase | 대응 PRD | 현재 상태 |
|:--|:--|:--|
| Phase 1: 정책 센터 UI + 자연어 변환 + 자체 검증 루프 | PRD-036 (UI 완료), PRD-037 (API 미완성) | **UI 부분 완료, 자연어 미시작** |
| Phase 2: Guardian 신호 표준화 + Engine Intervention 루프 | PRD-022/034/035 | **완료** |
| Phase 3: 트리거 안정화 + 정책 테스트 기능 | PRD-032 (검증 하네스), 미정 | **부분 완료** |

---

## 10. 종합 권장사항

### ✅ 수용 가능한 부분 (기존 계약 침해 없음)
1. **정책 0개 상태 명시적 정의** — 후속 PRD에 포함 가능
2. **즉시 적용 원칙** — 이미 구현된 next-session effect model과 동일
3. **정책 센터를 독립 진입점으로 격상** — PRD-037 범위에 포함 가능
4. **정책 자체 검증 루프** — Guardian을 등록 시점에도 호출하는 확장

### ⚠️ 수정 후 수용 가능한 부분
1. **역할 분리 용어** — "Engine"을 현재 아키텍처의 계층 구조(Orchestrator/Graph/PlanExecutor)에 매핑하여 재정의 필요
2. **Guardian 결과 유형 확장** (MISSING_POLICY, AMBIGUOUS) — 별도 PRD로 `ValidatorFinding` 확장 제안 필요
3. **BLOCK 분류** — Hook Class Split Contract과 일치시켜 재작성 필요

### ❌ 현재 계약과 충돌하여 주의가 필요한 부분
1. **자연어 파싱 → 정책 자동 생성** — Determinism 계약(CORE_INVARIANTS §6) 충돌 가능. 사용자 확인 단계 필수로 설계해야 함
2. **Non-overridable BLOCK in Guardian** — System Runtime Hook Class Split LOCK 위반. Guardian은 실행 중단 권한 없음

### 🔧 v1을 현 레포에 통합하기 위한 제안 PRD 범위

| PRD | 범위 |
|:--|:--|
| PRD-037 (예정) | 독립 Policy Registration API (`/api/policy/register`), 정책 0개 fallback |
| PRD-038 (신규) | Policy Expression Layer (raw_text → compiled_rule 3계층 스키마 확장) |
| PRD-039 (신규) | Natural Language Policy Parser (자연어 → 슬롯 구조 변환 + 사용자 확인 UX) |

---

*End of Review*
