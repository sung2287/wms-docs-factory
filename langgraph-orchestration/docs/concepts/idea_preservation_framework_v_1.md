# Idea Preservation Framework v0.1

## 1. 문제 정의

프로젝트(개발 / 도서 설계 등) 진행 중 다음과 같은 문제가 반복적으로 발생한다:

- 대화 중 핵심 아이디어가 정리되지 않은 채 PRD만 생성됨
- PRD에는 "무엇을 한다"만 남고 "왜 그렇게 했는지"는 사라짐
- 작은 결정(구조, 범위, 제외 사항 등)이 문서화되지 않아 휘발됨
- 새 세션에서 동일 질문이 반복됨
- 방향성이 미묘하게 흔들림

즉, 문제는 메모리 부족이 아니라 **결정과 근거의 보존 실패**이다.

---

## 2. 목표

복잡한 레이어를 늘리지 않으면서도 다음을 달성한다:

1. 중요한 대화 원문을 보존할 수 있다
2. 설계 결정이 휘발되지 않는다
3. PRD가 어디서 나왔는지 역추적 가능하다
4. 새 세션에서도 방향성이 유지된다
5. 장기(10년 스케일)에서도 검색 비용이 폭증하지 않는다

---

## 3. 최소 구조: 저장 타입 2개

복잡도를 줄이기 위해 저장 타입은 단 2개만 둔다.

### A. Evidence (근거 스냅샷)

정의:
- 나중에 그대로 확인/인용/검증해야 하는 대화 구간

용도:
- 책 설계의 핵심 발상
- 설계 논쟁의 중요한 비교 구간
- "왜 이렇게 하기로 했는지"가 잘 드러난 부분

특징:
- 원문 일부 또는 구간 단위 저장
- 요약 레이어와 분리
- 증거/근거 역할

---

### B. Decision (결정 고정)

정의:
- 앞으로 계속 적용해야 하는 선택 또는 규칙

예시:
- v1은 Flat 구조로 간다
- 멀티모달은 MVP 범위에서 제외
- Core에 도메인 하드코딩 금지
- 3부 구성은 고정한다

Decision은 "한 줄 결론" 형태로 유지한다.

---

## 4. 강도(strength) 속성

레이어를 추가하지 않고, Decision에 강도 속성만 부여한다.

- normal : 일반 결정
- LOCK   : 쉽게 바꾸지 않는 고정 규칙
- AXIS   : 설계 축 / 철학 수준의 방향 고정

이로써 Design Axis / Decision Lock / 일반 결정을 하나의 구조로 통합한다.

## Decision Scope (LOCK)

Decision은 다음 scope를 가진다:

- global
- runtime
- wms
- coding
- ui
- 기타 서브도메인

### 규칙

- global + strength=axis 는 모든 도메인에 적용된다.
- 도메인 scope Decision은 해당 영역에서만 적용된다.
- strength는 실행 차단과 무관하며, 설계 고정 강도만 의미한다.

우선순위:

axis > lock > normal

## Decision Persistence Model (LOCK)

- Decision은 SAVE_DECISION 선택 즉시 DB에 영구 저장된다.
- 세션 종료 시점까지 대기하지 않는다.
- 다음 턴부터 Retrieval 대상이 된다.

### Decision 수정 규칙

Decision 수정은 overwrite 방식이 아니다. 수정 시 새로운 version이 생성된다.

이전 version은 비활성화(isActive=false)되며, 이력은 유지된다.

### Version 구조 개념

Decision {
  id: string
  version: number
  previousVersionId?: string
  text: string
  strength: normal | lock | axis
  scope: global | runtime | wms | coding | ui | ...
  isActive: boolean
  createdAt: timestamp
}

### 강도 의미

- strength는 실행 차단을 의미하지 않는다.
- 설계 고정 강도만을 의미한다.

우선순위:

axis > lock > normal

### Runtime과의 관계

Decision의 strength (normal / LOCK / AXIS)는 설계 방향 고정 수준을 의미한다.

이는 Runtime의 실행 차단을 의미하지 않는다.

- LOCK = 쉽게 변경하지 않음
- AXIS = 철학 수준 고정

Runtime은 이를 위반해도 실행을 중단하지 않으며, 위반 여부는 최종 승인 단계에서 통제된다.

---

## 5. 운영 흐름

### 평소 대화
- Letta는 대화를 압축 요약 카드로 유지 (맥락 알람용)
- 원문 전량 검색은 하지 않는다

### 중요 구간 발생 시
- 사용자가 트리거로 명시
  - SAVE_EVIDENCE
  - SAVE_DECISION

### PRD 작성 직전
- 아이디어가 가장 응축된 시점
- 필요한 Evidence와 Decision을 고정
- 이후 PRD 생성

PRD는 결과물이고,
Evidence는 근거,
Decision은 적용 규칙이다.

---

## 6. 도서 설계에의 적용

이 구조는 도서 설계에도 그대로 적용 가능하다.

Evidence:
- 책의 핵심 메시지가 정리된 대화 구간
- 독자 정의에 대한 중요한 합의
- 차별점이 명확히 드러난 설명

Decision:
- 서술 톤 고정
- 구성 방식 고정
- 반복 사용할 비유 결정
- 구조적 분할 고정

AXIS 수준 Decision은 책의 철학을 정의한다.

---

## 7. 철학적 정합성

이 프레임워크는 다음 원칙을 따른다:

- 전략은 사람이 한다
- 시스템은 보존과 상기만 한다
- 자동 추측으로 분류하지 않는다
- 저장 타입은 최소화한다
- 복잡도보다 지속 가능성을 우선한다

---

## 8. 핵심 요약

문제는 "기억"이 아니라 "결정과 근거의 휘발"이다.

해결은 레이어를 늘리는 것이 아니라,

Evidence / Decision 두 타입으로 단순화하고
Decision에 강도(strength)를 부여하는 것이다.

이 구조는:
- 개발 시스템
- 설계 아키텍처
- 도서 집필
- 장기 프로젝트 운영

모두에 적용 가능하다.

### Memory 타입 확정 (LOCK)

이 시스템의 장기 메모리는 다음 3종으로 제한한다:

- Decision
- Evidence
- Anchor

Summary 타입은 장기 저장 구조로 사용하지 않는다.
대화 압축은 Anchor 시스템이 담당한다.

---

END

