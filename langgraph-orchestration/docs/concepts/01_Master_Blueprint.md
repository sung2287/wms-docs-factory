# **🚀 [Master Blueprint] AI 장기기억 저술 SaaS & 메타 팩토리 아키텍처**

이 문서는 LangGraph 시스템의 상위 컨텍스트(Anchor Blueprint)이다.
새로운 설계 제안은 본 문서의 방향을 침해하지 않는 범위 내에서만 허용된다.
본 문서에 명시된 원칙은 PRD 및 구현 문서보다 상위 개념으로 간주된다.

## **I. Core Identity & Non-Negotiables (철학 및 핵심 가치)**

본 시스템은 "99%의 대중에게 창작의 환상을, 1%의 설계자에게 시스템 통제권을" 제공하는 것을 본질로 하며, 어떠한 경우에도 타협할 수 없는 다음의 원칙을 따른다.

*   **시스템의 실체**: 완벽한 결과물은 단일 AI의 지능이 아니라, 백엔드에 설계된 **'결정론적 메타 파이프라인(LangGraph)'**에서 나온다. 사용자는 대화만 하지만, 시스템은 의도를 정해진 스키마에 채워 넣어 세계관을 직조한다.
*   **[LOCK-1] SSOT 분리 선언**: 승격(Promote)되는 대상은 오직 'Workflow Bundle(컨텍스트 스펙)'뿐이다. 유저 데이터(원문/기억/세션)는 번들과 물리적/논리적으로 완전히 격리된다.
*   **Runtime의 본질**: 런타임은 기본적으로 실행기(Executor)이며 데이터 평면(Data Plane)이다. 시스템은 기본적으로 비차단(Non-blocking) 원칙을 고수한다. 정책은 실행을 제안하거나 경고할 수 있으나, Core가 아닌 정책이 직접 실행을 중단시키지 않는다. (상세 계약은 02 참조)
*   **기억의 SSOT 정의**: 
    *   **Decision**: 의미(Meaning)의 SSOT이며, 운영 DB에 저장되는 버전 관리된 규칙이다.
    *   **Anchor**: 네비게이션 전용(Navigation-only) 힌트이다. (상세는 03 참조)
*   **The Fuel Gauge Principle**: 엔진의 복잡한 내부는 은닉하되, AI의 기억 선명도와 판단 근거는 투명하게 노출하여 사용자에게 통제감을 부여한다. (상세는 IV 섹션 참조)
*   **윤리적 방어망**: 우리는 관계나 글쓰기를 파는 것이 아니라, '의사결정 증폭기'로서 사고의 흔적을 관리하고 결정을 내리기 쉽게 돕는 도구를 제공한다.

---

## **II. System Architecture Overview (Builder ↔ Runtime)**

워크플로우 설계(Control Plane)와 실제 서비스(Data Plane)를 분리하여 운영 안정성과 확장성을 확보한다.

*   **투트랙 아키텍처**: 설계 앱(Builder)에서 깎고 테스트한 결과를 제품 엔진(Runtime)으로 밀어 넣는 **승격 파이프라인(Promotion Pipeline)** 구조를 가진다.
*   **Workflow Bundle**: 프롬프트, 정책, 루브릭을 하나로 묶은 배포 단위이다.
*   **Core-enforced Fallback**: 정책의 판단이 실패하거나 불확실할 때, 시스템은 정책이 아닌 Core의 안전 계약을 따른다.
*   **Guardian Loop**: 실행 전/후에 정책 정합성을 점검하여 시스템 무결성을 실시간으로 수호한다. (상세는 02 참조)

---

## **III. Cognitive & Memory Architecture**

단일 AI의 한계를 극복하기 위해 Planner-Worker 구조와 계층적 메모리 모델을 채택한다.

*   **Planner-Worker & Judge**: 고성능 AI(디렉터)가 지시하고 가성비 AI(워커)가 증거를 수집하며, 판사 AI가 검수를 대행하는 구조이다.
*   **3층 메모리 시스템 (Memory Hierarchy)**: 
    *   **① Policy Memory (Invariant)**: 시스템 불변 규칙 (Decision).
    *   **② Structural Memory (Relational)**: 개체 간 위계와 의존성 (Knowledge Graph).
    *   **③ Semantic Memory (Context Recall)**: 유사 맥락 탐색 (Evidence/Anchor).
*   **Anchor의 역할**: Semantic 레이어에 속하는 네비게이션 힌트이며, 상위 메모리 계층의 로딩 규칙을 절대 우회하지 않는다. (상세는 03 참조)

---

## **IV. Product Surface (UI/UX as Structural Expression)**

UI는 단순 프론트엔드 설계가 아니라, LangGraph의 구조 철학이 사용자에게 드러나는 표면 레이어이다. 따라서 UI 구조는 기능이 아니라 시스템 철학의 표현으로 간주한다.

*   **Tri-State Layout**: [네비게이터 - 메인 액션 - 상태 스트립]의 3단 구성을 통해 시스템 구조를 시각화한다.
*   **Project-Folder 세션 구조**: 세션이 특정 프로젝트의 기억과 정책 범위를 상속받도록 하여 의도 중심 인터페이스를 구현한다.
*   **연료 게이지 시각화**: AI의 기억 선명도와 판단 근거(Telemetry)를 투명하게 노출한다.

---

## **V. Expansion & Strategic Roadmap Intent**

*   **전문가 → 대중 확장**: 전문가용 런타임에서 정교한 '정책'과 '관계' 데이터를 수집하여 번들을 고도화하고, 이를 대중용 비서 엔진으로 이식하여 '딸깍' 수준의 품질을 보장한다.
*   **글로벌 확장**: 코어 수정 없이 도메인별/국가별 전용 '번들'을 제작하여 배포하는 전략을 취한다. (상세는 04 참조)

---
*Last Updated: 2026-02-24 (Philosophy Anchor)*
