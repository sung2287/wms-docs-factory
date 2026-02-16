# Platform: Writing Packet Extraction Flow

## 1. Retrieval Pipeline
1. **Target Validation**: 요청된 `external_key` 노드의 `is_archived` 상태 확인. `true`일 경우 요청 거부.
2. **Clean Traversal**:
   - 부모 추적 시 `is_archived` 노드를 만날 경우 즉시 중단 및 에러 처리 (고아 노드 방지).
   - 인접 섹션 로드 시 `is_archived == true`인 노드는 결과 집합에서 필터링.
3. **Computation**: 배제된 노드가 없는 청성(Clean) 트리 위상에서 `DesignSpecComposer` 실행.
4. **Packet Serialization**: 사전식 정렬된 JSON 포맷으로 패킷 전송.

## 2. Architectural Constraint
- **Archive Isolation**: Archive 계층은 Core의 비즈니스 로직(집필 지원)에 침투하지 않으며, 데이터 로드 시점에 차단되어야 한다.
