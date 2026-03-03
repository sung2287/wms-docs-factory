# Policy System Reboot Design Canvas (v1)

## 0. 목적
현재 정책 시스템은 다음 문제로 인해 실질적으로 작동하지 않는 상태이다:
- 정책 등록이 실행 플로우(step)에 종속되어 독립적으로 동작하지 않음
- Guardian 판정과 Engine 개입 루프가 하나의 사이클로 연결되어 있지 않음
- 정책 0개 상태에서 합법 상태 정의가 없어 크래시 발생
- UI가 흐름을 재개시키는 장치가 아니라 중단시키는 장치로 동작

목표는 다음과 같다:
1. 정책 등록을 독립 기능으로 분리
2. 자연어 기반 정책 UX 확립
3. Guardian–Engine–UI를 하나의 실행 루프로 연결
4. 즉시 적용 UX를 제공하되 시스템 안정성 유지

---

## 1. 전체 구조 개요

### 1.1 역할 분리 원칙

Guardian:
- 정책 및 인바리언트 판정만 수행
- OK / CONFLICT / MISSING_POLICY / AMBIGUOUS 반환
- 실행 흐름 제어하지 않음

Engine:
- 실행 흐름 관리
- Guardian 결과를 해석
- InterventionRequired 상태 생성
- 사용자 응답을 받아 재개

UI:
- Engine 신호 표시
- 사용자 선택 전달
- 판단 로직 포함하지 않음

---

## 2. 정책 표현 계층 구조

정책은 항상 3계층 구조로 저장한다:

1. raw_text (사용자 자연어 원문)
2. compiled_rule (시스템 실행용 구조)
3. metadata (version, active, scope, timestamps 등)

실행 시 SSOT는 compiled_rule이다.
사용자에게는 raw_text만 노출한다.

---

## 3. 정책 등록 – 독립 기능 설계

### 3.1 정책 센터 (독립 진입점)

기능:
- 정책 목록 조회
- 새 정책 생성
- 정책 편집 (자연어 수정)
- 정책 활성/비활성
- 정책 테스트(선택적)

등록은 실행 실패의 부산물이 아니라 독립 기능이다.

### 3.2 등록 흐름

1. 사용자 자연어 입력
2. Parse → compiled_rule 생성
3. Guardian이 정책 자체 검증
   - 형식 유효성
   - 과도한 범위 여부
   - 기존 정책과 충돌/중복 여부
4. 통과 시 저장
5. 즉시 적용 (다음 입력부터)

---

## 4. 자연어 ↔ 시스템 언어 변환

### 4.1 Parse 단계
자연어를 다음과 같은 슬롯 구조로 정규화:
- scope
- action (allow / deny / require / prefer)
- target
- strength (always / default / once)
- exceptions

### 4.2 Validate 단계
Guardian이 compiled_rule을 검사:
- 논리 모순 여부
- 기존 정책과 관계
- 위험한 설정 여부

자연어는 신뢰하지 않으며 항상 재컴파일한다.

---

## 5. 실행 루프 통합 구조

실행 사이클:

1. 사용자 입력
2. Engine 실행 계획 생성
3. Guardian 정책 평가
4. Guardian 결과 반환
   - OK
   - CONFLICT
   - MISSING_POLICY
   - AMBIGUOUS
5. Engine이 결과 해석
   - OK → 계속 진행
   - 나머지 → InterventionRequired
6. UI 모달 표시
7. 사용자 선택
8. Engine 재개

Guardian은 판정만 하고, UI는 표시만 하며, Engine만 흐름을 제어한다.

---

## 6. 정책 0개 상태 정의

policyCount == 0 인 경우 가능한 합법 액션은:
- REGISTER (새 정책 생성)
- RUN_WITHOUT_POLICY (이번만 진행)

수정/확인(overwrite)은 노출하지 않는다.

이 상태는 오류가 아니라 정상 상태로 정의한다.

---

## 7. 즉시 적용 원칙

정책 저장 후:
- 다음 사용자 입력부터 새 정책 적용
- 현재 진행 중인 턴은 소급 변경하지 않음

각 실행은 정책 버전 스냅샷을 고정한다.

---

## 8. BLOCK 분류 원칙

BLOCK은 두 종류로 구분:

1. Non-overridable BLOCK
   - 안전/치명 인바리언트
   - 진짜 중단

2. Overridable BLOCK
   - 정책 충돌
   - 사용자 선택으로 해결 가능

Engine은 이를 구분하여 처리한다.

---

## 9. 최소 단계 실행 계획

Phase 1:
- 정책 센터 UI 구축
- 자연어 → compiled_rule 변환
- 정책 자체 검증 루프 확립

Phase 2:
- Guardian 실행 판정 결과를 표준 신호로 통일
- Engine Intervention 루프 연결

Phase 3:
- 트리거 안정화
- 정책 테스트 기능 추가

---

## 10. 성공 기준

시스템이 다음을 만족하면 1단계 성공으로 간주:

1. 정책 0개 상태에서 오류 없이 등록 가능
2. 등록 직후 다음 입력에 정책 적용
3. 충돌 시 모달 표시 후 선택하면 실행 재개
4. 정책 없이도 항상 실행 가능 (fallback 존재)

---

End of Canvas v1

