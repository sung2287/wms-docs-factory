# **🚀 PROJECT ROADMAP (04)**

이 문서는 LangGraph 오케스트레이션 런타임의 단계별 로드맵과 PRD 매핑을 관리한다.

---

## **1. Phase 구조 (의미 중심)**

### **Phase 0 – 철학 고정 (Philosophy Foundation)**
*   의미: Runtime 비차단 원칙, Decision Versioned 구조 설계, Memory 3종 고정.
*   상태: ✅ **완료**

### **Phase 1 – Core Runtime Skeleton**
*   의미: 도메인 중립 실행 엔진, 모드 라우터, Ephemeral Session State 구현.
*   상태: ✅ **완료** (PRD-001, 004, 007, 008, 009)

### **Phase 2 – DocBundle-first 문서 주입**
*   의미: mode_docs.yaml 기반 DocBundle Loader, 섹션 슬라이스 주입.
*   상태: ✅ **완료** (PRD-002, 003)

### **Phase 3 – Decision / Evidence Engine**
*   의미: SQLite v1 연동, SAVE_DECISION 즉시 저장, 계층적 Retrieval 구현.
*   상태: ✅ **완료** (PRD-005, 006)

### **Phase 5.5 – Runtime Governance Layer**
*   의미: Workflow Bundle Promotion Unit, 결정론적 해시(LOCK-17), 세션 고정(Pinning).
*   상태: ✅ **완료 (2026-02-23)** (PRD-018)

### **Phase 6 – UI 계층 & UX**
*   의미: 세션 수동 전환, Decision 확인 모달, Session Lifecycle UX.
*   상태: ✅ **완료** (PRD-010, 011, 012)

### **Phase 6A – Chat-First UX Stabilization**
*   의미: React UI 도입, Deterministic Fake Streaming, 세션 매니지먼트 패널, Provider/Model 설정 UI.
*   상태: ✅ **완료 (2026-02-24)** (PRD-013, 014, 015, 016, 017)

### **Phase 7 – Letta Anchor 연동**
*   의미: 앵커 감지 및 상기, 원문 확인 강제 워크플로우.
*   상태: 🔵 **계획**

---

## **2. PRD 상태 매핑 (2026-02-24)**

| PRD | 제목 | 상태 | 해당 Phase |
|:---|:---|:---|:---|
| PRD-001 | Core Runtime Skeleton | COMPLETED | Phase 1 |
| PRD-002 | Policy Injection Layer | COMPLETED | Phase 2 |
| PRD-003 | Repository Context Plugin | COMPLETED | Phase 2 |
| PRD-004 | Session Persistence | COMPLETED | Phase 1 |
| PRD-005 | Decision / Evidence Engine | COMPLETED | Phase 3 |
| PRD-006 | Storage Layer (SQLite v1) | COMPLETED | Phase 3 |
| PRD-007 | Step Contract Lock | COMPLETED | Phase 1 |
| PRD-008 | PolicyInterpreter Contract | COMPLETED | Phase 1 |
| PRD-009 | LLM Provider Routing | COMPLETED | Phase 1 |
| PRD-010 | Session Lifecycle UX | COMPLETED | Phase 6 |
| PRD-011 | Secret Injection UX | COMPLETED | Phase 6 |
| PRD-012A | Deterministic Plan Hash | COMPLETED | Phase 6 |
| PRD-012 | Provider/Model Override UX | COMPLETED | Phase 6 |
| PRD-013 | Minimal Web UI | COMPLETED | Phase 6 |
| PRD-014 | Web UI Framework Introduction | COMPLETED | Phase 6A |
| PRD-015 | Chat Timeline Rendering v2 | COMPLETED | Phase 6A |
| PRD-016 | Session Management Panel | COMPLETED | Phase 6A |
| PRD-017 | Provider/Model/Domain UI Control | COMPLETED | Phase 6A |
| PRD-018 | Bundle Promotion Pipeline | COMPLETED | Phase 5.5 |
| PRD-019 | Dev Mode Overlay | PLANNED | Phase 6A |
| PRD-020 | Extensible Message Schema | PLANNED | Phase 9 |

---

## **3. Next Execution Focus**

*   **Primary Focus**: Phase 6A 안정화 및 버그 픽스, 웹 세션 리스트 계약 동기화.
*   **Secondary**: Phase 7 Letta Anchor 연동 설계 (장기 기억 상기 고도화).

---
*Last Updated: 2026-02-24 (Roadmap Update)*
