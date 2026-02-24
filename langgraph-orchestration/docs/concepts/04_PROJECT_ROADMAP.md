# **🚀 PROJECT ROADMAP (04)**

본 문서는 LangGraph 오케스트레이션 시스템의 **현 위치에서 [01 Master Blueprint](./01_Master_Blueprint.md) 완성 상태까지 가는 경로 지도**이다. 단순한 구현 목록이 아닌, 철학적 청사진을 현실화하기 위한 의미적 진화 단계를 정의한다.

---

## **I. Current Baseline (현 위치)**

시스템의 기초 인프라와 거버넌스가 확립되었으며, 1차 사용자 접점이 안정화된 상태이다.

### **1. 완료된 기반 단계 (Foundation)**
*   **Core Architecture**: 도메인 중립 실행 엔진 및 모드 라우터 완성. (Phase 0~1)
*   **Context Control**: `mode_docs.yaml` 기반 문서 주입 및 SQLite 영구 저장소 연동. (Phase 2~3)
*   **Deterministic Governance**: 번들 무결성 검증 및 세션 고정(Pinning) 엔진 활성화. (Phase 5.5 / PRD-018)
*   **UX Surface**: React UI 도입 및 세션 매니지먼트, 프로바이더 제어 UI 확보. (Phase 6/6A)

### **2. 현재 안정화 수준**
*   CLI와 Web이 동일한 `runRuntimeOnce` 엔트리를 공유하는 **Unified Entry** 체계 확립.
*   번들 해시 불일치 시 즉시 차단하는 **Core-enforced Safety** 작동 중.
*   멀티 프로바이더 채팅 및 스트리밍 렌더링이 가능한 수준의 사용자 경험 제공.

---

## **II. Blueprint Gap Analysis (청사진 대비 부족 요소)**

[01 Master Blueprint](./01_Master_Blueprint.md)에서 정의한 최종 상태와 현재 구현 사이의 주요 간극(Gap)을 정리한다.

*   **Anchor 자동화 (Semantic Memory Automation)**: 현재 Anchor는 수동 트리거 중심이며, 대화 중 자동으로 이정표를 감지하고 상기시키는 Letta 레이어의 통합이 미비함. (01 섹션 III-3 참조)
*   **Agent Separation (조사-구현 분리)**: 아키텍처적으로 분리는 되어 있으나, 런타임에서 "근거 수집 전 구현 금지"와 같은 물리적 역할 강제가 아직 정책적으로만 존재함. (01 섹션 III-1 참조)
*   **Multimodal 확장 (Schema Flexibility)**: 현재 엔진은 텍스트 중심이며, 이미지/오디오 등 다양한 입력과 출력 아티팩트를 처리할 수 있는 추상화 레이어가 필요함.
*   **Domain Pack 확장 (Metafactory Expansion)**: 코딩/저술 외 다양한 도메인 번들을 즉시 교체하여 배포할 수 있는 배포 거버넌스와 도메인 팩 라이브러리 부재.
*   **Platformization (SaaS Scale-up)**: 멀티 테넌트 번들 격리, Stable/Canary 채널 분리 배포, A/B 테스트 라우팅 등 플랫폼 수준의 운영 기능 미완성. (01 섹션 V-2 참조)

---

## **III. Path to Blueprint Completion (확장 단계)**

청사진 완성을 위해 인지 모델을 고도화하고 시스템의 외연을 플랫폼 수준으로 확장한다.

### **1. Phase 7 – 인지 지능 고도화 (Letta Anchor 연동) 🔵 계획**
*   **목표**: 대화 압축 중 Anchor 자동 감지 및 Retrieval 시 원문 확인 강제 워크플로우 구현.
*   **의미**: "기억하는 수석 아키텍트"로서의 인지 뼈대 완성. (상세는 [03 MEMORY MODEL](./03_MEMORY_MODEL.md) 참조)

### **2. Phase 8 – 에이전틱 거버넌스 확립 (Agent Separation) 🔵 계획**
*   **목표**: Research(Gemini)와 Implementation(Codex)의 물리적 역할 분리 및 근거 기반 승인 루프 강제.
*   **의미**: 추측에 의한 구현을 차단하고 설계 정합성을 수호하는 시스템 신뢰도 확보.

### **3. Phase 9 – 멀티모달 및 범용 인터페이스 🔵 계획**
*   **목표**: `InputEvent` 및 `Output Artifact` 추상화, 멀티모달 지원 메시지 스키마 도입.
*   **의미**: 도메인 중립성을 넘어 인터페이스 중립성을 확보하여 범용 오케스트레이터로 진화.

### **4. Horizon – 플랫폼 진화 (Platformization)**
*   **Vision**: 특정 도메인의 전문가 노하우를 '번들'로 데이터화하여 대중에게 공급하는 **메타 팩토리** 완성.
*   **Strategy**: Stable/Canary 분리 배포 및 멀티 테넌트 지원을 통해 SaaS 스케일업 달성.

---

## **Appendix**

### **A. PRD 상태 매핑 (Major Milestones)**
| PRD | 제목 | 상태 | 해당 Phase |
|:---|:---|:---|:---|
| PRD-017 | Provider/Model/Domain UI Control | COMPLETED | Phase 6A |
| PRD-018 | Bundle Promotion Pipeline | COMPLETED | Phase 5.5 |
| PRD-019 | Dev Mode Overlay | PLANNED | Phase 6A |
| PRD-020 | Extensible Message Schema | PLANNED | Phase 9 |

### **B. Definition of Done (DoD)**
모든 단계는 [01 Master Blueprint](./01_Master_Blueprint.md)의 철학을 준수해야 하며, Core 수정 없이 번들/정책 수준에서 확장이 가능해야 함.

---
*Last Updated: 2026-02-24 (Blueprint Path Roadmap)*
