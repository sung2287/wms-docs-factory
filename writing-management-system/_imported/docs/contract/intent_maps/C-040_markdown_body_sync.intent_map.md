# [C-040] Intent Map: Markdown Body Sync

## 1. Intent Summary
본 문서는 기존 Workspace의 안정적인 구조(Structure)와 설계(Spec)를 보존하면서, 오직 본문(`snippet.body`) 데이터만을 대량으로 안전하게 덮어쓰기(Overwrite)하는 업데이트 도구의 설계 의도를 정의한다. 구조적 변이를 차단하고 본문 데이터의 정합성만을 동기화함으로써, 외부 집필 도구와의 협업 유연성을 확보하는 것을 목적으로 한다.

## 2. Fixed Policies (고정 정책)
- **Single Action Policy**: 본 도구는 오직 `UPDATE_BODY`(전체 본문 교체) 행위만을 수행한다.
- **Structural Immutability**: 노드의 추가(ADD), 삭제(REMOVE), 이동(MOVE), 키 변경(REKEY), 명세 수정(UPDATE_SPEC) 및 부분 머지(Partial Merge)는 일절 허용하지 않는다.
- **Identity Integrity**: 매칭은 오직 `external_key`의 Exact String Match(Case-sensitive, No auto-trim)를 통해서만 수행한다.
- **Change Detection Strategy**: LF 정규화, 행 끝 공백 제거, UTF-8 고정 후 기존 데이터와 바이트 단위로 비교하여 변경이 있을 때만 스냅샷을 1개 생성한다.
- **Fixed Traceability**: 스냅샷 메시지는 `"Markdown Body Sync"`로 고정한다.
- **Review Status Invariance**: 본문 동기화는 디자인 변경이 아니므로 `review_required` 플래그를 절대 변경하지 않는다.

## 3. Forbidden Evolutions (금지된 진화)
- **Paragraph-level Merge**: 본문 내부의 단락 단위 병합이나 지능형 텍스트 결합 시도를 금지한다 (데이터 손상 방지).
- **Silent Spec Updates**: 본문 동기화 도중에 디자인 명세나 메타데이터를 몰래 수정하는 행위를 금지한다.
- **Silent Snapshot Creation**: Generating a snapshot when no canonical body change is detected is strictly forbidden.

## 4. Core & Sandbox Boundary
- **Core**: 본문 정규화 로직(Normalization), 동일성 판정(Equality), 매칭 규칙(Mapping Rules).
- **Adapter**: 마크다운 파일 스캔 및 로드(Markdown Scan/Load).

## 5. Future Expansion (명시적 Defer)
- **Dry-run Report**: 실제 적용 전 어떤 파일이 변경될지 미리 보여주는 영향도 리포트 기능.
- **Conflict UI**: 매칭되지 않는 파일이나 중복 키에 대한 수동 해결 인터페이스는 v2 이후로 연기한다.

## 6. Test Constitution v1.7 준수 의도
테스트 헌법 v1.7에 따라, 본 도구는 변경 사항이 없는 경우 스냅샷이 생성되지 않음을 보장하는 멱등성(Idempotency) 테스트와, 구조 변경 시도 시 예외가 발생하는지를 검증하는 부정 테스트를 반드시 수행해야 한다.
