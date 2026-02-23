# **PRD-018: Bundle Promotion Pipeline & Runtime Governance**

## **1\. 문서 목적 (Objective)**

본 문서는 LangGraph 기반의 R\&D 환경(Builder)과 서비스 환경(Runtime)을 물리적으로 분리하고, 코드 수정 없이 파이프라인(프롬프트, 정책, 루브릭)을 배포(Promote)하기 위한 **'메타 팩토리'의 핵심 연결 엔진**을 정의한다.

UI 단의 무한 개선 루프를 차단하고, \*\*"번들 생성 → 매니페스트 검증 → 런타임 교체"\*\*라는 가장 뼈대가 되는 배포 사이클을 최우선으로 물리적 완성하는 것을 목표로 한다.

## **2\. 핵심 원칙 및 제약 사항 (Core Principles & LOCKs)**

* **\[LOCK-1\] 승격 대상의 엄격한 분리 (SSOT Separation):**  
  * Promotion Pipeline을 통해 이동하는 데이터는 오직 \*\*Workflow Bundle(컨텍스트 엔지니어링 스펙)\*\*뿐이다.  
  * 유저의 대화 세션, 원문(Evidence), 기억(Decision), 시스템 로그 등 상태/유저 데이터는 절대 번들에 포함되거나 덮어쓰여지지 않는다.  
* **\[LOCK-4\] Core-enforced Fallback 강제 (가장 중요):**  
  * Prod 모드에서 승인 주체인 판사 AI(Judge Policy)의 구체적인 '판단 기준'은 번들 내에서 자유롭게 수정/배포될 수 있다.  
  * 그러나 해당 Policy가 실패(오류, 불확실성, Timeout 등)했을 때의 \*\*처리 규칙(Fallback: 재시도, 보류, 에스컬레이션, 중단)\*\*은 번들 설정이 아닌 **Runtime Core에 하드코딩된 Contract**를 무조건 따르도록 강제한다. (잘못된 자동화 배포로 인한 시스템 무한 루프 원천 차단)  
  * *주의: 이 강제 규칙은 오해의 소지를 없애기 위해 manifest.json에 변수로 노출하지 않으며 순수 내부 계약으로만 존재한다.*

## **3\. 핵심 구현 범위 (In-Scope)**

본 MVP 단계에서는 화려한 Hot-swap이나 무중단 배포, A/B 테스트는 제외하며, 오직 아래 3가지 엔진 기능만 구현한다.

### **3.1 Manifest Loader (Runtime Core 내부)**

* **기능:** 지정된 디렉토리(예: active\_bundle/)에서 manifest.json을 읽고 검증하는 로더.  
* **검증 로직 (Validation):**  
  * schema\_version이 현재 런타임 파서와 호환되는지 확인.  
  * min\_runtime\_version이 현재 엔진의 버전 이상인지 확인.  
  * 참조된 파일들(prompts/, policies/)이 실제로 폴더 내에 존재하는지(Missing File Check) 무결성 검증.  
  * **무결성 검증 (Hash Check):** bundle\_hash는 manifest.json 자신을 제외한 references 하위의 모든 실제 파일 내용을 기준(알파벳 오름차순 정렬 연결)으로 계산된 해시값과 일치해야 한다. (Builder와 Runtime 간의 해시 계산 불일치 방지)  
* **실패 시:** 로드를 즉시 중단(Abort)하고 이전 정상 번들을 유지하거나 시스템 에러 로그 출력.

### **3.2 Active Bundle Switching (교체 메커니즘)**

* **기능:** 1인 SaaS 운영 환경에 맞춘 가장 단순하고 확실한 물리적 배포/교체 방식.  
* **메커니즘 (Symlink 방식 추천):**  
  1. Builder가 새 번들 폴더를 생성 (/bundles/bundle\_v1.2/)  
  2. Runtime은 항상 고정된 심볼릭 링크(예: /runtime/active\_bundle)만 바라봄.  
  3. Deploy 실행 시, 심볼릭 링크를 새 폴더로 원자적(Atomic)으로 교체.  
* **세션 경계 고정 (Session Boundary Lock):**  
  * 번들 교체는 **새로운 런타임 세션(Session)이 시작될 때**부터 적용된다.  
  * \*\*진행 중인 기존 세션은 시작 시점의 bundle\_version에 완전히 고정(Lock)\*\*된다. 세션 도중 프롬프트나 정책이 변경되는 런타임 지옥을 원천 차단한다.

### **3.3 R\&D vs Prod 프로파일 스위치 (Profile Switch)**

* manifest.json 내의 profiles 설정을 런타임이 해석하여 모드를 결정한다.  
* rd (Research) 모드: require\_human: true 상태를 존중하여 Interrupt 발생.  
* prod (Production) 모드: require\_human을 무시하고, 지정된 auto\_approver (Judge Policy)로 컨텍스트를 넘겨 자동 처리.

## **4\. Manifest JSON 스키마 명세 (Draft)**

{  
  "bundle\_id": "web\_novel\_pipeline",  
  "bundle\_version": "1.2.0",  
  "schema\_version": "v1",  
  "min\_runtime\_version": "0.5.0",  
  "bundle\_hash": "a1b2c3d4e5f6...", 

  "references": {  
    "prompts": \["prompts/system.md", "prompts/character\_extractor.md"\],  
    "policies": \["policies/judge\_criteria.yaml", "policies/routing\_rules.yaml"\],  
    "rubrics": \["rubrics/tone\_evaluator.json"\]  
  },

  "profiles": {  
    "rd": {  
      "allow\_hitl": true,  
      "log\_level": "debug"  
    },  
    "prod": {  
      "allow\_hitl": false,  
      "auto\_approver": "judge\_criteria.yaml"  
      // fallback 처리는 Runtime Core의 강제 계약이므로 manifest에 노출하지 않음.  
    }  
  }  
}

## **5\. 범위 외 (Out-of-Scope / Future)**

* 무중단 Hot-swap (현재는 새 세션 시작 시 새 번들 적용 방식 채택)  
* Canary 배포 / A/B 테스트 라우팅  
* 원격 API를 통한 번들 업로드 (현재는 로컬 파일 시스템 Symlink 교체로 한정)  
* Letta Anchor 연동 및 BM 티어링 (Phase 4로 이관)

## **6\. 완료 기준 (Definition of Done)**

1. Runtime Core가 manifest.json을 읽고 지정된 프롬프트/정책으로 LangGraph 노드를 초기화할 수 있다.  
2. min\_runtime\_version 불일치 또는 bundle\_hash 위변조 발생 시, 로더가 이를 거부(Reject)하고 예외를 발생시킨다.  
3. prod 프로파일로 실행 시, 판사(Judge) 노드에서 의도적으로 에러(Timeout 등)를 냈을 때, Core에 하드코딩된 Fallback(예: "현재 응답 보류" 상태 반환)이 정상 작동한다.