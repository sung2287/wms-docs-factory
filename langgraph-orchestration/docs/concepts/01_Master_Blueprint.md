# **🚀 [Master Blueprint] AI 장기기억 저술 SaaS & 메타 팩토리 아키텍처**

이 문서는 LangGraph 시스템의 상위 컨텍스트(Anchor Blueprint)이다.
새로운 설계 제안은 본 문서의 방향을 침해하지 않는 범위 내에서만 허용된다.
본 문서에 명시된 원칙은 PRD 및 구현 문서보다 상위 개념으로 간주된다.

## **I. Core Identity & Non-Negotiables (철학 및 핵심 가치)**

본 시스템은 "99%의 대중에게 창작의 환상을, 1%의 설계자에게 시스템 통제권을" 제공하는 것을 본질로 하며, 어떠한 경우에도 타협할 수 없는 다음의 원칙을 따른다.

*   **시스템의 실체**: 완벽한 결과물은 단일 AI의 지능이 아니라, 백엔드에 설계된 **'결정론적 메타 파이프라인(LangGraph)'**에서 나온다. 사용자는 대화만 하지만, 시스템은 의도를 정해진 스키마에 채워 넣어 세계관을 직조한다.
*   **[LOCK-1] SSOT 분리 선언**: 승격(Promote)되는 대상은 오직 'Workflow Bundle(컨텍스트 스펙)'뿐이다. 유저 데이터(원문/기억/세션)는 번들과 물리적/논리적으로 완전히 격리된다.
*   **Runtime의 본질**: 런타임은 기본적으로 실행기(Executor)이며 데이터 평면(Data Plane)이다. 시스템은 기본적으로 비차단(Non-blocking) 원칙을 고수한다. 실행 차단은 번들 정책에 의해 발생하지 않으며, 오직 Runtime Core의 안전 계약(Fallback Contract) 범위 내에서만 제한적으로 허용된다. 정책은 실행을 제안하거나 경고할 수 있으나, Core가 아닌 정책이 직접 실행을 중단시키지 않는다.
*   **기억의 SSOT 정의**: 
    *   **Decision**: 의미(Meaning)의 SSOT이며, 운영 DB에 저장되는 버전 관리된 규칙이다.
    *   **Anchor**: 네비게이션 전용(Navigation-only) 힌트이며, 원문을 대체하거나 규칙을 우회할 수 없다.
*   **The Fuel Gauge Principle**: 엔진의 복잡한 내부는 은닉하되, AI의 기억 선명도와 판단 근거는 투명하게 노출하여 사용자에게 통제감을 부여한다. (상세는 IV 섹션 참조)
*   **윤리적 방어망**: 우리는 관계나 글쓰기를 파는 것이 아니라, '의사결정 증폭기'로서 사고의 흔적을 관리하고 결정을 내리기 쉽게 돕는 도구를 제공한다.

---

## **II. System Architecture (Builder ↔ Runtime)**

워크플로우 설계(Control Plane)와 실제 서비스(Data Plane)를 분리하여 운영 안정성과 확장성을 확보한다.

### **1. 통제실 및 승격 파이프라인**
*   **Builder (설계 앱)**: 아키텍트가 UI로 파이프라인을 설계하고 수동 개입(HITL)을 통해 퀄리티를 검증하여 **'Workflow Bundle'**을 생성한다.
*   **Promotion Pipeline**: 검증된 번들을 런타임으로 승격(Deploy)시킨다. 파일 복사/심볼릭 링크 기반의 **제한적 핫스왑[LOCK-3]**을 지원한다.

### **2. Workflow Bundle & Manifest**
*   **구성**: 프롬프트(.md), 정책(.yaml), 평가 기준(.json)이 묶인 배포 단위.
*   **[G] 확장성 포트 (Strategy Injection)**: 번들은 단순 데이터를 넘어 도메인별 최적화된 **'리트리벌 전략'**과 **'검증 로직'**을 런타임에 주입한다. (Core 수정 없이 도메인 확장 가능)

### **3. Runtime Governance (Safety Net)**
*   **[LOCK-4] Core-enforced Fallback**: 판사 AI(Judge Policy)의 판단 실패나 불확실성 발생 시, 시스템은 번들의 정책이 아닌 Runtime Core에 하드코딩된 Fallback 계약을 강제로 따른다.
*   **[LOCK-5] 가디언 루프 (Guardian/Validator Loop)**: 실행 전/후에 Policy Memory를 대조하는 Validator Hook을 실행하여 **ALLOW(통과), WARN(알림), BLOCK(중단)** 신호를 통해 시스템 무결성을 수호한다. Guardian Loop는 구조적/정책적 정합성을 점검하는 수호 레이어이며, 번들 정책이 Runtime Core를 우회하거나 변경하지 못하도록 보장하는 역할을 한다.

---

## **III. Cognitive & Memory Architecture**

단일 AI의 한계를 극복하기 위해 Planner-Worker 구조와 계층적 메모리 모델을 채택한다.

### **1. Planner-Worker & Judge**
*   **디렉터(판사)**: 고성능 AI가 전체 설계도를 검토하고 워커에게 지시한다.
*   **워커(수사관)**: 가성비 AI가 증거(Evidence)를 수집하여 리포트한다.
*   **오토파일럿 [LOCK-2]**: 런타임(Prod)에서는 인간의 검수를 판사 AI가 대체한다.

### **2. 3층 메모리 시스템 (Memory Hierarchy)**
*   **① Policy Memory (Invariant Layer)**: 절대 변해서는 안 되는 불변 규칙(Decision). 번들로 주입된 정책이 강제되는 최상위 계층.
*   **② Structural Memory (Relational Layer)**: 개체 간 위계와 의존성을 파악하는 설계의 지도(Knowledge Graph). "A 수정 시 B의 영향도"를 판단한다.
*   **③ Semantic Memory (Context Recall Layer)**: 유사 맥락 탐색을 위한 과거 대화 및 자산(Evidence/Letta Anchor). Anchor는 여기서 네비게이션 힌트 역할을 한다.

### **3. 데이터 티어링 및 아하 모멘트**
*   **기억의 선명도**: 유료 티어는 벡터 DB(Hot)를 통한 고선명 기억을 제공하고, 무료 티어는 S3 동면(Archive)을 통한 망각 현상을 구현한다.
*   **아하 모멘트 (Recall UX)**: 결제 시 과거의 떡밥(Anchor)을 AI가 먼저 언급하며 세계관을 복구하는 연출을 통해 매몰 비용과 가치를 증명한다.

Memory 계층은 의미를 구조화하기 위한 인지 모델이며, Retrieval 우선순위, strength 로딩 규칙, domain 필터링과 같은 구현 세부는 별도 스펙 문서에서 정의된다. 본 문서는 개념적 구조만을 고정한다.

---

## **IV. Product Surface (UI/UX as Structural Expression)**

UI는 단순 프론트엔드 설계가 아니라, LangGraph의 구조 철학이 사용자에게 드러나는 표면 레이어이다. 따라서 UI 구조는 기능이 아니라 시스템 철학의 표현으로 간주한다. UI는 시스템 구조를 시각적으로 표현하고 사용자의 의도를 구조화하는 창구다.

### **1. 기본 레이아웃 (Tri-State Layout)**
*   **좌측 (The Navigator)**: **[프로젝트 폴더 - 세션]** 계층 구조. 프로젝트의 기억과 정책 범위를 상속받아 세션을 생성한다.
*   **중앙 (Chat & Action)**: 클린한 채팅 타임라인과 로컬 에이전트의 실무 수행 과정을 보여주는 '액션 카드'.
*   **상단/우측 (Status Strip)**: 활성화된 도메인 번들 정보, 모델명, **연료 게이지(기억 선명도)** 상시 노출.

### **2. 설정의 계층화 (Setting Hierarchy)**
*   **퀵 토글 (Quick Toggle)**: 도메인 전환(코딩 ↔ 저술), 모드 전환(Design ↔ Implement) 등 잦은 변경 사항 노출.
*   **딥 세팅 (Deep Settings)**: API 연결, 정책 관리(전문가용), 시스템 텔레메트리 등 심층 설정 은닉.

### **3. 의도 중심 인터페이스**
사용자가 설정을 직접 조작하지 않아도 대화 중 의도를 파악하여 모드를 자동 제안하거나 변경하며, UI는 그 상태를 '연료 게이지'와 '상태 스트립'으로 투명하게 피드백한다.

---

## **V. Expansion & Strategic Roadmap**

전문가 도구에서 시작하여 검증된 노하우를 대중에게 비서 형태로 공급한다.

### **1. 단계별 확장 전략**
*   **Phase 1 (전문가용)**: 코딩(구조 정합성) 및 저술(세계관 정합성) 도메인을 통해 고퀄리티 정책과 의사결정 패턴을 수집하여 번들을 고도화한다.
*   **Phase 2 (대중용)**: 검증된 번들을 이식한 '개인 비서' UI를 제공한다. 대중은 설정 없이 '딸깍'만 하지만, 백엔드의 가디언 루프가 전문가 수준의 품질을 보장한다.

### **2. 글로벌 및 기술 확장**
*   **글로벌 스케일**: 뼈대 코드 수정 없이 번들 교체만으로 국가별 감성과 언어에 맞춘 엔진을 배포한다.
*   **배포 거버넌스**: Stable/Canary 채널 분리 배포 및 A/B 테스트 라우팅을 통해 데이터 기반으로 번들을 승격시킨다.
*   **멀티 테넌트**: B2B 고객사별 프라이빗 번들 격리 운영을 지원한다.

---
*Last Updated: 2026-02-24 (Integrated & Optimized)*
