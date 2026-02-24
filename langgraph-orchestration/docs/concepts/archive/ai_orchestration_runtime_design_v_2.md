# AI Orchestration Runtime – MVP 설계 문서 (v1 + Philosophy Add-on)

> 목적: 이 문서 **한 장만**으로
> - 철학(방향)이 고정되고
> - 이후 PRD를 설계할 때 필요한 기본 힌트(결정 기준)가 바로 보이도록 한다.
>
> 원칙: **전략은 사람이 결정**하고, **시스템은 실행·기억·주입을 담당**한다.

---

# 0. 철학 (짧게, 변경 금지)

## 0.1 우리는 “감독/통제 시스템”을 만들지 않는다
- 기본 동작은 **항상 진행**이다.
- 정보가 부족하면 **UNAVAILABLE로 표시**하고, 가능하면 **추가 수집/전환**으로 해결한다.
- 차단/종료는 예외 상황에서만 사용한다.

## 0.4 HOLD Strategy (LOCK)

- Core Runtime은 어떤 경우에도 실행을 차단하지 않는다.
- HOLD는 Policy Layer의 개념이다.
- Runtime은 HOLD 신호를 "표시"할 수는 있으나, 실행을 중단하지 않는다.
- 실제 차단은 승인/merge/prd:close 단계에서만 발생한다.

Mode별 HOLD 전략 (Policy 예시):

```yaml
mode:
  writing:
    hold_strategy: warn_only
  coding:
    hold_strategy: warn_and_block_on_commit
```

Core는 이 전략을 해석하지 않으며, 상태만 전달한다.

## 0.2 로직과 정책을 분리한다 (핵심)
- **Core 로직(엔진)**: 고정. 실행 흐름을 “돌리는” 역할만 한다.
- **Policy/Workflow(정책)**: 문서(파일)로 정의. 사람이 수정해서 워크플로우를 바꾼다.

## 0.5 Terminology Clarification (LOCK)

시스템은 다음 두 축을 엄격히 분리한다:

1. **Phase (실행 단계)**:
   - "어떤 종류의 작업을 수행 중인가"를 나타냄.
   - 예: design, implement, diagnose, review.
   - 워크플로우 라우팅, 문서 주입, 실행 동작을 제어함.
   - **Decision 검색 범위를 결정하지 않음.**

2. **Domain (적용 범위 / Scope)**:
   - "작업이 시스템의 어느 영역에 적용되는가"를 나타냄.
   - 예: runtime, wms, coding, ui, global.
   - Decision의 `scope` 필드와 직접 매핑됨.
   - **Decision 검색 필터링에만 사용됨.**

Phase는 행동의 맥락(Behavioral Context)이며, Domain은 의미적 적용 경계(Semantic Applicability)이다. Phase가 바뀐다고 해서 Domain이 자동으로 바뀌지 않는다.

## 0.3 Core에 도메인 하드코딩 금지
- 도메인 문자열/경로/정책/템플릿을 Core에 박지 않는다.
- 교체 가능한 **Domain Pack**으로 분리한다.

---

# 1. 최상위 목표

## 1.1 우리가 만드는 것

이 프로젝트는 “코드 작성 AI”가 아니라:

> 🔧 도메인 중립적인 AI 오케스트레이션 런타임

을 만드는 것이다.

- 모드 기반 실행
- 세션 기억 유지
- 필요한 문서만 주입
- 과거 결정 검색
- 도메인 교체 가능

---

# 2. 핵심 설계 원칙 (변경 금지)

## 2.1 전략은 사람이 한다
- 절차 구성
- 모드 선택
- 정책 결정

## 2.2 시스템은 실행기다
- 모드 라우팅
- 문서 번들 로딩
- 기억 저장/검색
- 프롬프트 조립

## 2.3 Core와 Domain은 반드시 분리

### Core Engine (고정)
- GraphState
- Mode Router
- Session Store
- DocBundle Loader **프레임워크**
- Retrieval Engine **프레임워크**
- PromptAssemble **프레임워크**
- LLM Client

### Domain Pack (교체 가능)
- mode_docs.yaml
- policy/*.yaml
- prompts/*.md
- Memory 스키마
- 출력 포맷 정의

❗ Core에 도메인 문자열/경로/정책/템플릿 하드코딩 금지

---

# 3. 시스템 전체 구조

```
User Input
   ↓
DetectMode
```

## Mode Strategy 원칙 (LOCK)

- 기본 모드 전환은 엔진이 자동 판단한다.
- 이는 전략 변경이 아니라 실행 흐름 최적화에 해당한다.
- 전략은 사람이 정의한 Mode 구조 자체를 의미한다.
- 세션 중 모드 이동은 전략 변경이 아니다.

### UI 요구사항

- 현재 활성 모드를 항상 UI 상단에 표시한다.
- 사용자는 언제든 수동으로 모드를 변경할 수 있다.
- 수동 전환은 자동 판단을 덮어쓴다.
- 수동 전환은 세션 상태에 기록된다.

예시:

```
Current Mode: design
[Change Mode]
```

```
   ↓
LoadDocsForMode
```
   ↓
ContextSelect
   ↓
PromptAssemble
   ↓
LLMCall
   ↓
MemoryWrite
```

---

# 4. MVP 단계별 로드맵 (PRD 설계 힌트)

## MVP-0: 문서 고정 (현재 단계)
- 설계 원칙 확정
- Core/Domain 분리 고정
- Bundle-first 전략 확정


## MVP-1: 세션 상태 + 모드 라우터

### 목표
- 세션 재실행 시 상태 유지
- 키워드 기반 모드 전환
- 레포 스캔 재주입 방지

### 필수 필드

```ts
interface GraphState {
  mode: string;          // Phase/Mode
  currentDomain: string; // Decision Scope
  repoScanVersion?: string;
  docBundle?: DocBundle;
}
```

Runtime은 명시적인 Domain 값(`currentDomain`)을 유지해야 한다. 이 값은 Phase와 독립적이며, Retrieval 시 필터링 기준으로 사용된다.

### 세션 저장 위치 (고정)

```
ops/runtime/session_state.json
```

- git commit 제외
- .gitignore 포함


## MVP-2: Bundle-first 문서 주입

### 목표
- 모드 진입 시 필수 문서 누락 방지
- 문서 전체가 아닌 섹션 슬라이스만 주입

### mode_docs.yaml 구조

```yaml
modes:
  design:
    required:
      - path: docs/...
        slices: ["## Section A"]
    optional:
      - path: docs/...
        slices: ["## Section B"]
```


## MVP-3: Letta Anchor Retrieval

### 목표
- Runtime은 자체 Summary를 저장하지 않는다.
- 장기 대화 압축은 Letta Anchor 시스템이 담당한다.
- 필요 시 Anchor를 통해 Evidence 또는 Decision 원문을 탐색한다.
- Retrieval은 Anchor → Evidence/Decision 확인 흐름을 따른다.

### Retrieval 규칙 (LOCK)

1. `global + axis` 로드 (최우선)
2. `currentDomain + axis` 로드
3. `currentDomain + lock` 로드
4. `currentDomain + normal` 로드
5. Anchor → Evidence/Decision 탐색

### Anchor Hierarchy Compliance (LOCK)

Anchor-based retrieval MUST NOT bypass Decision hierarchical loading rules.

- Anchor may suggest relevant Decision or Evidence.
- However, final Decision set MUST still respect:
    axis → lock → normal priority ordering.
- Anchor-triggered fetch does not override Domain filtering.
- Anchor never elevates a lower-strength Decision above higher-strength ones.

Anchor functions as a navigation hint only, not a priority override mechanism.

Decision 계층적 로딩(Hierarchical Loading)은 순수하게 Domain(`scope`)을 기준으로 작동한다. Retrieval은 단일 `ORDER BY`로 축소되지 않으며, 단계별 로딩 후 병합 구조를 유지한다. Anchor를 통한 탐색 결과 역시 이 계층 구조를 준수해야 한다.

Decision은 즉시 활성 상태로 반영된다. 수정은 versioned 방식으로 처리된다. Runtime은 Decision 변경을 차단하지 않는다.

### Domain Default Policy (LOCK)

- `currentDomain` MUST be explicitly maintained by Runtime.
- If `currentDomain` is NOT set for the current session/turn:
  - Retrieval MUST load only:
      - `global + axis`
  - Domain-specific Decisions MUST NOT be loaded.
- Runtime MUST NOT implicitly derive Domain from Phase.
- Domain changes may occur only via explicit user action or policy instruction.

This rule prevents accidental Phase→Domain coupling and arbitrary fallback behavior.

## Domain vs Phase Separation (LOCK)

- Domain은 작업 종류이며 수동 전환 기본.
- Phase는 작업 단계이며 자동 전환 기본.
- Phase는 Domain을 유도하지 않는다.
- Domain 변경은 명시적 입력만 허용.
- Domain 변경 시 StatePatch로 영속화 필수.
- currentDomain unset 시 global + axis만 로딩.

### Decision Scope 정의 (정합성 보강)

Decision은 scope를 가진다.

- global
- runtime
- wms
- coding
- ui
- 기타 서브도메인

Retrieval 시:

1. global + strength=axis
2. current domain + axis
3. current domain + lock
4. current domain + normal

global + axis는 모든 도메인에 적용된다.
strength는 실행 차단과 무관하며, 설계 고정 강도만 의미한다.


## MVP-4: 영속 저장 + 인덱싱

- SQLite 도입
- BM25 또는 역색인


## MVP-5: 토큰/비용 관측

- 프롬프트 구성요소별 토큰 추정
- 모드별 기본 토큰 예산

---

# 5. Bundle-first 전략 고정

## 왜 RAG가 아니라 Bundle-first인가?

- 필수 규칙 누락 방지
- 예측 가능성 확보
- 구현 난이도 낮음

## 확장 방향

최종 구조는:

> Bundle (필수) + RAG (보조)

---

# 6. 모드/페이즈 전환 규칙 (유연 전환 핵심)

이 시스템은 작업 진행 중에도 **키워드로 쉽게 전환**할 수 있어야 한다.

## 6.1 Hard Trigger (즉시 전환)
- "커밋해"
- "지금 실행"

→ 즉시 모드/페이즈 전환

## 6.2 Soft Trigger (전환 후보 제시)
- "커밋 필요할까?"

→ 점검 후 사용자 확정


## 6.3 정책(Workflow)은 문서로 바꾼다
- 트리거 키워드
- 전환 대상 모드/페이즈
- 해당 모드에서 로딩할 문서 번들

은 **정책 파일로 정의**되어야 하며,
사람이 문서를 수정해서 워크플로우를 바꿀 수 있어야 한다.

---

# 7. 장기 전환 가능성

이 엔진은 Domain Pack 교체만으로:

- 코드 작성용
- 조직 운영용
- 감사 시스템
- 문서 설계 시스템

으로 전환 가능.

조건:
- Core 수정 금지
- Domain Pack 교체만 수행

---

# 8. Decision Log

- Session state 위치 고정: ops/runtime/session_state.json
- Core/Domain 분리 LOCK
- 정책/워크플로우는 문서로 변경 가능해야 함

## Session State와 Decision의 구분 (LOCK)

- session_state.json은 런타임 상태 복구용 캐시이다.
- Git에 커밋하지 않는다.
- 의미 SSOT가 아니다.

Decision과 Evidence는 다음 원칙을 따른다:

- 운영 DB에 저장된다.
- Git에 자동 저장되지 않는다.
- Session state와 분리된 저장소를 사용한다.
- versioned 방식으로 이력을 유지한다.

즉,

- Session state = 실행 상태 (ephemeral)
- Decision/Evidence = 의미 SSOT (persistent)
- Git = 코드 및 정책 정의

이 세 영역은 서로 침범하지 않는다.

---

# 9. 현재 목표

> 지금은 "완전 자율 AI"가 아니라
> "돌아가는 오케스트레이션 런타임 MVP"를 만드는 단계다.

정책/거버넌스 고도화는 MVP 이후 진행한다.

---

# 10. 멀티모달 확장 대비 (MVP 최소 설계만 반영)

> 원칙: 지금은 LLM(텍스트)만 구현한다.
> 단, 나중에 이미지/TTS/STT로 확장 가능하도록 인터페이스만 열어둔다.

## 10.1 입력 추상화 (확장 가능 구조)

MVP에서는 텍스트만 처리하지만, 입력을 string으로 고정하지 않는다.

```ts
type InputEvent =
  | { type: "text"; text: string }
  // future:
  // | { type: "image"; imageUrl: string }
  // | { type: "audio"; audioUrl: string }
```

현재 구현 범위:
- type === "text"만 처리

## 10.2 모델 호출 추상화

ModelCall은 특정 모델에 종속되지 않는다.

```ts
interface ModelRequest {
  modelType: "llm"; // future: "image" | "tts"
  payload: unknown;
}
```

MVP 범위:
- modelType === "llm"만 구현

## 10.3 출력(Artifact) 추상화

현재는 텍스트 결과만 저장하지만, 구조는 확장 가능하게 둔다.

```ts
interface ModelOutput {
  type: "text"; // future: "image" | "audio"
  content: string;
}
```

---

> 요약: 멀티모달은 지금 구현하지 않는다.
> 단, 입력/모델호출/출력 인터페이스를 타입 기반으로 설계해
> Core 수정 없이 확장 가능하도록 최소 구조만 반영한다.

---

END
