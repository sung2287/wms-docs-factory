# 아키텍처 설계: LangGraph 기반 AI CLI 오케스트레이션

본 문서는 LangGraph를 오케스트레이터로 사용하여 Gemini CLI와 Codex CLI를 각각 '조사/문서화'와 '구현/실행' 에이전트로 분리하고 운영하는 아키텍처를 정의합니다.

## 1. 전체 개요

### 1.1 도입 배경 및 필요성
복잡한 소프트웨어 개발 환경에서 단일 AI 에이전트가 조사와 구현을 동시에 수행할 경우, 충분한 근거 없이 코드를 수정하거나 조사 내용을 누락한 채 구현에 착수하는 '판단 오염' 및 '환각(Hallucination)' 현상이 발생하기 쉽습니다. 이를 방지하기 위해 **조사(Research)**와 **실행(Action)** 단계를 물리적으로 분리하고, 이를 통제하는 **중재자(Orchestrator)**가 명확한 상태 관리를 수행하는 구조가 필요합니다.

### 1.2 기존 방식의 한계
*   **판단과 실행의 혼재:** 에이전트가 스스로 판단하고 즉시 코드를 수정하면서 발생하는 예기치 못한 사이드 이펙트.
*   **근거 부족:** 최신 PRD나 레거시 코드 구조를 충분히 분석하지 않은 상태에서 "추측"에 기반한 코드 작성.
*   **상태 추적의 어려움:** 대규모 작업 시 현재 어느 단계(조사 중인지, 수정 중인지)에 있는지에 대한 전역적 가시성 부족.

---

## 2. 역할 분리 원칙

이 아키텍처는 판단 주체와 실행 주체를 엄격히 분리합니다.

| 에이전트 명칭 | 역할 (Role) | 주요 책임 (Responsibility) |
| :--- | :--- | :--- |
| **LangGraph** | **Supervisor / Orchestrator** | 전체 세션 상태 관리, 다음 단계 결정(Routing), 에이전트 간 데이터 전달. |
| **Gemini CLI** | **Research / Evidence Collector** | 레포지토리 탐색, PRD/문서 분석, 버그 원인 ‘근거 수집/분석 보고’, 수정 가이드 작성. |
| **Codex CLI** | **Implementation / Execution** | 코드 파일 수정(Replace), 테스트/타입체크 등 검증 커맨드 실행, 결과 리뷰 및 체크포인트 생성. |

*※ Gemini와 Codex 에이전트는 스스로 다음 단계를 결정하거나 서로에게 직접 명령을 내리지 않으며, 모든 명령은 LangGraph의 제어 하에 수행됩니다.*

---

## 3. 세션 기반 실행 흐름

전체 워크플로우는 LangGraph의 상태 전이(State Transition)에 따라 다음과 같이 진행됩니다.

### 3.1 워크플로우 다이어그램
```text
[User Request] 
      │
      ▼
[1. Intake & Planning (LangGraph)] ──┐
      │                              │
      ▼                              │
[2. Research Phase (Gemini CLI)]     │ (Loop if needed)
      │                              │
      ▼                              │
[3. Decision/Report (LangGraph)] ────┘
      │
      ▼
[4. Implementation (Codex CLI)] ─────┐
      │                              │
      ▼                              │ (Debug Loop)
[5. Validation & Test (Codex CLI)] ──┘
      │
      ▼
[6. Final Review (LangGraph)] ──▶ [Complete]
```

### 3.2 단계별 상세 프로세스
1.  **Intake (요청 수신):** 사용자의 요구사항을 분석하고 작업 범위를 확정합니다.
2.  **Plan/Route (판단):** 오케스트레이터가 현재 작업에 '조사'가 필요한지 '구현'이 필요한지 판단합니다.
3.  **Gemini 조사 단계:** Gemini CLI가 파일/디렉터리 탐색 및 검색 기능을 사용하여 코드와 문서를 분석하고 '수정 가이드' 또는 '원인 분석 보고서'를 작성합니다.
4.  **판단/정리 단계:** 오케스트레이터가 Gemini의 보고서를 검토하고, 구현 단계로 넘어갈 준비가 되었는지 확인합니다.
5.  **Codex 구현 단계:** 작성된 가이드를 바탕으로 Codex CLI가 파일 정밀 수정 기능을 사용하여 코드를 수정합니다.
6.  **테스트/검증 단계:** Codex CLI가 테스트/타입체크 등 검증 커맨드를 실행하고 결과를 보고합니다.
7.  **수정 루프:** 테스트 실패 시, 오케스트레이터는 다시 Gemini에게 '원인 조사'를 명령하거나 Codex에게 '재수정'을 명령합니다.

**도구별 명령/옵션의 SSOT는 아래 레퍼런스 문서를 따른다:**
- [./gemini_cli_full_reference.md](./gemini_cli_full_reference.md)
- [./codex_cli_full_reference.md](./codex_cli_full_reference.md)

---

## 4. 조사 단계의 의미: 근거 수집기(Evidence Collector)

조사 단계는 단순히 코드를 읽는 것이 아니라, 구현의 **안전성(Safety)**을 확보하는 핵심 과정입니다.

*   **PRD 조사:** 요구사항 명세서와 현재 코드의 괴리를 파악합니다.
*   **코드 리팩토링 조사:** 변경이 미칠 파급 효과(Impact Analysis)를 사전에 분석합니다.
*   **버그 원인 조사:** 로그와 코드를 대조하여 추측이 아닌 데이터에 기반한 오류 지점을 특정합니다.
*   **결과물:** Gemini는 직접 코드를 수정하지 않고, 오직 **"어디를, 왜, 어떻게 수정해야 하는가"**에 대한 기술적 근거 문서만을 생산합니다.

---

## 5. 이 구조의 장점

### 5.1 판단 오염 방지 (No Decision Pollution)
조사 에이전트(Gemini)와 구현 에이전트(Codex)가 서로 독립적인 컨텍스트를 유지함으로써, 조사 결과가 구현의 편의성에 의해 왜곡되는 것을 방지합니다.

### 5.2 근거 없는 수정 차단 (Evidence-based Action)
모든 코드 변경은 Gemini가 수집한 구체적인 근거(파일 경로, 라인 번호, 로직 분석 등)가 존재할 때만 오케스트레이터에 의해 승인됩니다.

### 5.3 확장성 및 안정성
*   **대규모 레포 대응:** Gemini의 강력한 분석 능력을 통해 대규모 코드베이스에서도 정확한 지점을 타격할 수 있습니다.
*   **자동화 이전의 안정성:** 사람이 수동으로 하던 '분석 후 수정' 과정을 AI 오케스트레이션으로 이식하여 작업의 일관성을 확보합니다.

---

## 6. LangGraph의 역할 경계 (SSOT Separation)

LangGraph는 결과물의 SSOT가 아니다. 결과물(Artifacts)의 SSOT는 각 도메인 시스템(WMS, Git/Repo 등)에 존재한다.

- **결정/근거의 SSOT (LangGraph)**: "왜 이 결정을 내렸는가?"에 대한 데이터(Decision, Evidence)를 관리한다.
- **결과물의 SSOT (Domain)**: 실제 문서(WMS)나 코드(Repo/Git)를 관리한다.

LangGraph는 결정의 맥락(Meaning)을 보존하는 데 집중하며, Decision은 다음과 같은 특징을 가진다:

- 의미 SSOT에 해당한다.
- 운영 DB에 저장된다.
- Git에 자동 저장되지 않는다.
- versioned 방식으로 변경 이력을 유지한다.

LangGraph는 3층 Memory 모델을 따른다:

- Policy Layer (Decision)
- Structural Layer (Relational Scope)
- Semantic Layer (Anchor/Evidence)

이 계층 구조는 Core Runtime의 Domain-neutral 원칙과 충돌하지 않으며,
Memory 전략은 Adapter/Policy 레벨에서 확장된다.

---

## 7. Mode Decision Boundary

LangGraph는 세션 중 모드 전환을 자동 판단할 수 있다. 이는 실행 흐름 최적화이며 전략 수립이 아니다.

전략은 다음을 의미한다:
- Mode 정의
- Workflow 구조
- Policy 구성

모드 전환 자체는 실행 레벨 라우팅에 해당한다.

UI는 항상 현재 모드를 표시해야 하며, 사용자가 수동으로 변경할 수 있어야 한다. 수동 전환은 자동 판단보다 우선한다.

---

## 8. HOLD 처리 원칙

LangGraph는 상태 관리자이며, 판단 또는 차단 권한을 가지지 않는다.

- 위험 신호는 상태로 기록한다.
- 차단 여부는 상위 거버넌스(Governor / Git / PRD Cycle)가 결정한다.
- Runtime 단계에서의 중단은 설계 철학에 어긋난다.

---
*Last Verified: 2026-02-21*
