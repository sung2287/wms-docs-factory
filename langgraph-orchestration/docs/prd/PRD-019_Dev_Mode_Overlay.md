# PRD-019: Dev Mode Overlay (Observability & Local Control)

## 1. Objective
개발자가 터미널 환경 변수 설정이나 서버 재시작 없이 웹 UI 상상에서 **Secrets(API Keys) 관리, 실행 텔레메트리 모니터링, 상태 정합성 검토**를 실시간으로 수행할 수 있는 오버레이 인터페이스를 제공한다. 본 기능은 오직 **Dev/RD 모드**에서만 활성화되며, 운영(Prod) 환경의 무결성에는 어떤 영향도 미치지 않아야 한다.

---

## 2. Scope & Priorities

### P0) Secret Handling (Local-only & In-memory)
- **UI Input**: 마스킹 처리된 입력 필드 제공. 현재 활성화된 Provider/Model에 따라 동적 필드 노출.
- **In-memory Use**: 시크릿은 서버의 **영속성 레이어(PRD-004)에 절대 저장될 수 없다.**
- **Isolation**: 런타임 메모리 내 일시적 주입은 허용되나(LLM 호출용), 로그, 세션 파일, BundlePin, Delta, Evidence 등 **어떠한 물리적 저장 경로에도 기록될 수 없다.**
- **Storage**: OS Keychain 또는 로컬 암호화 파일에만 잔류한다.

### P0) Live Telemetry Panel (Isolated Snapshot)
- **Snapshot Mandate**: 텔레메트리 데이터는 반드시 **Deep-Copy된 Snapshot 객체만 전송**한다.
- **Execution Flow**: 현재 실행 Step, Phase, Mode, Plan Hash, Bundle Pin 정보 실시간 표시.
- **Governance Status**: `validators[]` / `postValidators[]` 실행 결과(ALLOW/WARN/BLOCK) 및 `InterventionRequired` 사유 노출.

### P1) Dev Override & Reproducibility Isolation
- **Isolation LOCK**: Dev Override 활성화 시 Bundle Promote, Pin 생성/갱신, 운영 상태 전이(`cycle`/`close`) 기능을 물리적으로 차단한다.
- **Watermark**: Dev Override 상태 세션은 **"NON-REPRODUCIBLE (DEV MODE)"** 워터마크를 강제 표시한다.

---

## 3. Non-Goals
- **Prod Persistence**: 운영 세션 영속성(PRD-004)에 시크릿을 저장하는 행위.
- **Core Semantic Modification**: 오버레이가 실행 엔진의 핵심 로직(Hash 계산 등)을 변경하는 행위.

---

## 4. Acceptance Criteria
- **E2E DX**: 터미널 조작 없이 웹 UI만으로 API Key를 설정하고 첫 채팅을 시작할 수 있음.
- **Real-time Visibility**: Validator Hook 결과와 Plan Hash 변동을 100ms 이내에 오버레이에서 확인할 수 있음.
- **Safety**: Dev 오버레이가 비활성화된 경우, 운영 환경의 성능이나 동작에 영향이 없음.

---

## 5. Risk Assessment
- **Medium**: 로컬 시크릿 저장소의 보안 구현 및 운영 환경과의 물리적 격리(LOCK) 구현이 핵심 리스크임.

---

## Implementation Order Checklist

### Stage 1: Infrastructure & Isolation (P0)
- [ ] Deep-copy 기반 `TelemetryEmitter` 구축.
- [ ] **Reproducibility Isolation LOCK** (Promote/Pin 차단 가드) 구현.
- [ ] `LocalSecretStore` (영속성 레이어 차단형) 구현.

### Stage 2: P0 Feature Delivery
- [ ] "NON-REPRODUCIBLE" 워터마크 및 UI 레이아웃.
- [ ] Secret Input UI (Masked, Local-only).
- [ ] 실시간 Snapshot 스트리밍 연동.

### Stage 3: Observability Hardening (P1)
- [ ] Retrieval Metrics (Layer별 카운트) 데이터 수집 및 시각화.
- [ ] Plan Hash Watcher 및 Diff View 구현.
- [ ] Memory "Fuel Gauge" 차트 추가.
