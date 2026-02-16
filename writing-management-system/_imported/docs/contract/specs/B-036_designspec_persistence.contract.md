# Contract: DesignSpec Persistent Model & Review Propagation

## 1. Domain Model

### 1.1 DesignSpec (Value Object)
Excel 디자인 블루프린트의 구조를 완전히 수용하는 고정 스키마.
- **constitution**: { rules: string[] }
- **series**: { core_sentence, direction, achievement }
- **volume**: { label, subtitle, role, core_question, achievement, notes: string[] }
- **part**: { title_hint, role, core_insight, next_question, post_summary: string[] }
- **chapter**: { title_hint, one_liner, logic_role, key_claim, reader_state_change, argument_log: string[], next_hooks: string[], post_summary: string[] }
- **section**: { file_key_source, title_hint, purpose, notes: string[] }
- **constraints**: { forbidden: string[], cautions: string[] }
- **style**: { metaphors: string[] }

### 1.2 DesignSpec Canonical Normalization
비교 및 변경 판정 전, DesignSpec은 반드시 다음 규칙에 따라 정규화되어야 한다.
1. **Nullification**: 모든 `undefined` 또는 생략된 필드는 `null`로 통일한다.
2. **Array Preservation**: 빈 배열은 `[]` 상태를 유지한다.
3. **Key Ordering**: 모든 객체의 키는 UTF-8 codepoint 기준 사전식으로 정렬한다.
4. **Field Specific Handling**:
   - **Accumulate 필드**: 모든 문자열 요소를 UTF-8 codepoint 사전식 정렬 후 중복을 제거한다. 병합 결과는 입력 순서와 무관하게 결정론적으로 수렴한다.
   - **Append 필드**: **Root → Leaf 계층 순서**를 엄격히 따른다. 계층 순서는 `external_key`의 depth(루트에서 대상까지 경로 순서)에 의해 결정되며, 동일 depth 내 다중 조상은 존재하지 않음을 전제로 한다. **Accumulate와 달리 Append는 정렬되지 않으며, 계층적 선후 관계가 데이터의 의미를 가진다.**

### 1.3 Node State (Entity)
- **node_id**: UUID (내부 식별자)
- **writing_status**: `empty` | `completed`
- **review_required**: boolean (default: false)
- **design_spec**: DesignSpec (정규화된 상태로 저장)

## 2. State Invariants

1. **Hierarchy Integrity**: 모든 Node는 부모 레벨의 DesignSpec을 상속받을 준비가 되어 있어야 한다.
2. **Immutable Constitution**: `constitution.rules`는 최상위(Series)에서 정의되며 하위에서 재정의할 수 없다.
3. **Review Consistency**: `writing_status == "empty"`인 경우 `review_required`는 반드시 `false`여야 한다.
4. **Effective DesignSpec Non-Persistence**: 계산된 `effective_design_spec`은 절대 저장하지 않으며 요청 시마다 동적으로 계산한다.

## 3. DesignSpec Change Detection
"DesignSpec 필드가 변경될 때"의 정의는 다음과 같이 고정한다:
**"정규화(Canonical Normalization)를 거친 두 DesignSpec 간의 Deep Structural Equality가 성립하지 않을 경우에만 변경으로 간주한다."**

## 4. Review Propagation Rules
DesignSpec 변경 판정(Deep Structural Equality 실패) 발생 시:
- 대상 Node 및 모든 후손(Descendant) Section 탐색.
- `writing_status == "completed"`인 경우: `review_required = true`.
- `writing_status == "empty"`인 경우: 상태 유지.

## 5. Determinism 조건 (Accumulate)
Accumulate 방식의 필드 병합은 다음 절차를 준수하여 결정론을 보장한다:
1. 조상 노드부터 현재 노드까지의 모든 해당 필드 리스트 수집.
2. 모든 문자열 요소를 단일 평면 리스트로 전개.
3. **UTF-8 codepoint lexicographic order**로 정렬.
4. 인접한 중복 요소 제거.

## 6. Snapshot Scope
Snapshot은 다음 정보를 원자적으로 포함해야 한다:
- 정규화된 `design_spec`, `snippet.body`, `writing_status`, `review_required`.
