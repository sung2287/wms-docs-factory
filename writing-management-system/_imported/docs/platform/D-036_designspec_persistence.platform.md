# Platform: DesignSpec Execution Flow

## 1. Persistence Layer Abstraction
- **Persistence Adapter**: 데이터 저장 및 조회는 추상화된 어댑터 계층에서 수행한다.
- **Storage Agnostic**: Core 로직은 특정 저장소 기술(PostgreSQL, NoSQL 등)에 의존하지 않으며, 평면화된 객체 또는 정규화된 바이트 배열로 데이터를 수신한다.
- **Delegation**: 데이터의 물리적 일관성 보장 및 트랜잭션 처리는 어댑터 계층에 위임한다.

## 2. Normalization & Comparison Flow
1. **Ingest**: 새로운 DesignSpec 데이터 수신.
2. **Normalize**: `B-036 1.2` 규칙에 따라 Canonical Form으로 변환.
3. **Fetch Existing**: Persistence Adapter를 통해 기존 정규화된 Spec 로드.
4. **Compare**: 메모리 상에서 Deep Structural Equality 검사.
5. **Propagate**: **Compare가 실패(변경 감지)한 경우에만 `ReviewEngine`을 호출한다.** 변경이 감지되지 않으면 Review 상태는 전이되지 않는다.
6. **Save**: **변경이 감지된 경우에만 Snapshot을 생성하며, 데이터의 실제 변경 없는 Save 호출은 엄격히 금지된다.**

## 3. Accumulate Field Merging
- 병합 시 `UTF-8 codepoint lexicographic order`를 강제 적용하여 직렬화한다.
- 이는 저장소 성능 최적화와 무관하게 비즈니스 로직 레벨에서 고정된다.
