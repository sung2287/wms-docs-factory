# Policy System Reboot Design Canvas v3 — 최종 적합성 검토 보고서

**검토일**: 2026-03-03  
**대상 문서**: `policy_system_reboot_design_canvas_v_3.md`  
**이전 검토**: v1 리뷰 (2026-03-03), v2 리뷰 (2026-03-03)

---

## 0. 총평

> [!IMPORTANT]
> **v3은 모든 검토 피드백이 반영된 최종 정합 상태이다.**
> 기존 레포 아키텍처 계약(CORE_INVARIANTS, Hook Class Split, next-session effect model, Determinism)과의
> 충돌이 전부 해소되었으며, PRD 시리즈로 분해하여 구현을 시작할 수 있는 상태이다.

---

## 1. v2 → v3 변경 추적

### ✅ [반영됨] §10.2 Layer 0 — FailFast / UX 경계 명확화

**v2 리뷰 권장사항**:
> Layer 0에 "시스템 내부적으로는 Core Safety Contract 위반 시 FailFastError가 발생하며(변경 없음), UX 레이어에서 이를 변환하는 것이 이 원칙의 범위이다" 추가를 고려.

**v3 반영 (L186-187)**:
```
시스템 내부적으로는 Core Safety Contract 위반 시 FailFastError가 발생한다(변경 없음).
UX 레이어에서 이 에러를 사용자 친화적 재프레이밍 메시지로 변환하는 것이 본 원칙의 범위이다.
```

**판정**: ✅ Core 동작 불변성과 UX 레이어 책임 경계가 명확해졌다.

---

### ✅ [반영됨] §9 Phase 2 — 기존 PRD 완료 사실 반영

**v2 리뷰 권장사항**:
> Phase 2의 "Guardian 실행 판정 통일 + Intervention 루프 연결"은 이미 PRD-034/035에서 완료됨. Phase 2를 조정 필요.

**v3 반영 (L162-165)**:
```
Phase 2:
- ValidatorFinding에 reasonCode / recommendedActions 메타데이터 확장
- Policy Center ↔ Guardian 등록 시점 검증 연동
- (기존 Intervention 루프는 PRD-034/035에서 완료됨 — 재구현 불필요)
```

**판정**: ✅ 이미 완료된 작업을 재구현하는 낭비를 방지하고, 실제로 필요한 신규 작업만 남겼다.

---

## 2. 전 항목 최종 정합 상태

| § | 항목 | v1 | v2 | v3 | 비고 |
|:--|:--|:--|:--|:--|:--|
| 0 | 목적/문제 정의 | ✅ | ✅ | ✅ | — |
| 1 | 역할 분리 원칙 | ⚠️ | ✅ | ✅ | v2에서 해결 |
| 2 | 정책 표현 3계층 | 🆕 | 🆕 | 🆕 | 신규 기능, 계약 충돌 없음 |
| 3 | 정책 센터 | ⚠️ | ✅ | ✅ | v2에서 해결 |
| 4 | 자연어 변환 | ❌ | ✅ | ✅ | v2에서 Determinism 해결 |
| 5 | 실행 루프 | ✅ | ✅ | ✅ | — |
| 6 | 정책 0개 상태 | ✅ | ✅ | ✅ | — |
| 7 | 즉시 적용 | ✅ | ✅ | ✅ | — |
| 8 | BLOCK 분류 | ⚠️ | ✅ | ✅ | v2에서 해결 |
| 9 | 실행 계획 | ⚠️ | ⚠️ | ✅ | **v3에서 해결** |
| 10 | UX Soft-Denial | — | ⚠️ | ✅ | **v3에서 경계 명확화** |
| 11 | 성공 기준 | ✅ | ✅ | ✅ | — |

---

## 3. 구현 진입 준비도

| 준비 항목 | 상태 |
|:--|:--|
| 아키텍처 계약 정합성 | ✅ 충돌 없음 |
| 기존 PRD와의 경계 | ✅ 명확 (Phase 2에서 기 완료분 명시) |
| SSOT 정의 | ✅ compiled_rule = SSOT 확정 |
| Determinism 보장 | ✅ 저장 시점 확정 모델 |
| Hook Class 계약 | ✅ Safety / Guardian 분리 준수 |
| UX-Core 경계 | ✅ FailFast 불변 + UX 변환 레이어 분리 |

---

## 4. 다음 단계 권장

이 캔버스를 기반으로 **3개 PRD로 분해**하여 순차 구현을 시작할 수 있다:

| PRD | 범위 | Phase |
|:--|:--|:--|
| **PRD-037** | Policy Center API + 정책 0개 fallback + 정책 CRUD 엔드포인트 | Phase 1 |
| **PRD-038** | Policy Expression Layer (raw_text / compiled_rule / metadata 스키마 확장 + NLP 파서) | Phase 1 |
| **PRD-039** | ValidatorFinding 메타데이터 확장 (reasonCode / recommendedActions) + 등록 시점 Guardian 검증 | Phase 2 |

### PRD 작성 우선순위 제안

```
PRD-037 (API/독립 진입점) → PRD-038 (표현 계층) → PRD-039 (Guardian 확장)
```

PRD-037이 먼저인 이유: 정책 센터 UI와 API가 없으면 나머지 기능(자연어 파싱, Guardian 연동)의 진입점이 존재하지 않는다.

---

## 5. 최종 판정

> **v3 Design Canvas는 현재 레포의 모든 아키텍처 계약과 완전히 정합하며,
> PRD 시리즈로 분해하여 구현을 시작할 수 있는 상태이다.**
>
> 추가 검토 라운드 없이 구현 단계로 진입 가능하다.

---

*End of Review*
