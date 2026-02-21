# PRD-005: Decision / Evidence Engine (Phase 3)

## Objective
단순 대화 요약을 폐기하고, 프로젝트의 핵심 결정(Decision)과 근거(Evidence)를 체계적으로 저장, 관리, 검색하여 세션 간 설계 일관성을 유지한다.

## Background
- 단순 요약(Summary)은 정보 왜곡 및 핵심 결정 근거 유실의 원인이 됨.
- "왜 그렇게 하기로 했는가"에 대한 근거(Evidence)와 "앞으로 지켜야 할 규칙"인 결정(Decision)을 분리 관리함.

## Scope
- **Decision 관리**: 결정 사항의 즉시 저장, 버전 관리(Versioned), 강도(Strength) 및 범위(Scope) 적용.
- **Evidence 관리**: 결정의 배경이 되는 대화 원문 또는 스냅샷 저장.
- **Anchor 연동**: 특정 맥락에서 과거 결정/근거를 떠올리게 하는 네비게이션 힌트 제공.
- **Retrieval 시스템**: 강도와 범위에 따른 계층적 검색 및 주입.

## Non-Goals
- 매 턴 대화 요약(Summary) 저장.
- 키워드 기반 장기 기억 시스템.
- 세션 단위의 데이터 격리 (Global Scope 도입).
- 기존 데이터 덮어쓰기(Overwrite) 방식의 수정.

### Naming Convention Rule (LOCK)

- 문서 레벨 필드는 camelCase (`rootId`, `previousVersionId`, `isActive`)를 사용한다.
- DB 스키마 레벨은 snake_case (`root_id`, `previous_version_id`, `is_active`)를 사용한다.
- 두 표현은 동일 의미이며, 구현 시 매핑 레이어에서 변환한다.

## Data Structures (LOCK)

### 1. Decision (결정)
- `id`: UUID v4 (각 버전의 고유 ID)
- `rootId`: 최초 생성된 Decision의 ID (체인 식별자)
- `version`: 수정 시 증가하는 정수 (최초 버전 1)
- `previousVersionId`: 직전 버전을 가리키는 ID
- `text`: 결정된 규칙의 한 줄 요약
- `strength`: `axis` | `lock` | `normal`
- `scope`: `global` | `runtime` | `wms` | `coding` | `ui` 등
- `isActive`: 현재 활성 여부 (boolean)
- `createdAt`: 생성 시점 (timestamp)

### Decision Versioning Model (LOCK)
- 하나의 논리적 Decision 체인은 동일한 `rootId`를 공유한다.
- `(rootId, version)` 조합은 유일해야 한다.
- 수정 시 기존 `isActive=true` 레코드를 `false`로 전환하고, 동일 `rootId`와 `version + 1`로 신규 레코드를 생성한다.

### rootId Rules (LOCK)
- 최초 생성 시 `rootId`는 해당 레코드의 `id`와 동일해야 한다. (`rootId = id`)
- 수정(버전 생성) 시 `rootId`는 절대 변경하지 않는다.
- `rootId`는 사용자/외부 입력으로 받지 않으며, 시스템이 생성 규칙에 따라 설정한다.
- `previousVersionId`는 동일 `rootId` 체인 내부의 직전 버전만 가리킬 수 있다.

### Anchor Version Policy (LOCK)

- Anchor는 특정 Decision "버전"을 가리킨다.
- Decision의 신규 버전이 생성되어도 기존 Anchor는 자동 갱신되지 않는다.
- Anchor는 역사적 맥락을 보존하기 위한 포인터이며, 항상 생성 당시의 version을 유지한다.

### 2. Evidence (근거)
- `id`: UUID v4
- `content`: 대화 원문 또는 스냅샷 데이터
- `decisionRef`: 관련 Decision ID (**NOT NULL**)
- `timestamp`: 생성 시점

### Evidence Rule
- Evidence는 반드시 하나의 Decision에 귀속된다.
- 독립적인 Evidence 저장은 허용하지 않으며, Decision 없는 Evidence는 저장 단계에서 거부한다.

### 3. Anchor (앵커)
- `id`: UUID v4
- `hint`: 상기를 위한 짧은 텍스트
- `targetRef`: 가리키는 Evidence 또는 Decision ID
- `type`: `evidence_link` | `decision_link`

## Execution Rules
- **즉시 저장 (Immediate Persist)**: `SAVE_DECISION` 확정 즉시 DB에 저장되며, 세션 종료를 기다리지 않고 다음 턴부터 Retrieval 대상이 된다.
- **Retrieval 우선순위**: 
    1. `global` + `axis` (최우선)
    2. `current_domain` + `axis`
    3. `current_domain` + `lock`
    4. `current_domain` + `normal`

### Retrieval Strategy Clarification (LOCK)

- Retrieval은 단일 ORDER BY 기반 정렬 방식이 아니라, **계층적 로딩(Hierarchical Loading) 후 병합 방식**을 원칙으로 한다.
- 계층 간 우선순위는 명시된 4단계를 절대 변경할 수 없다.

- **Anchor 작동 원칙**: Anchor는 실행 규칙이 아니며, Retrieval 시 사용자에게 상기시키고 원문 확인을 유도하는 역할만 수행한다.

## Failure Handling
### Failure Semantics Clarification (LOCK)
- **Write 오류 / DB 무결성 오류 / SQL 실행 오류**: 즉시 **Fail-Fast** 한다.
- **Retrieval 결과가 비어 있는 경우**: 정상 처리로 간주한다.
- **Retrieval 알고리즘 내부 예외 발생 시**: 즉시 **Fail-Fast** 한다.

## Conclusion
Decision / Evidence 데이터가 의미 SSOT를 구성하며, PRD-005는 그 저장 및 검색 엔진을 정의한다.
