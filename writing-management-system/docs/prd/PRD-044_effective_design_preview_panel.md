# [PRD-043] Effective Design Preview Panel

## 1. Objective
PRD-036에 정의된 계층적 DesignSpec 상속 규칙에 따라 계산된 `effective_design_spec`을 집필자에게 실시간으로 시각화하여 제공한다.

## 2. In Scope
- Effective Design Spec의 동적 계산 및 표시
- 계층별(Series~Section) 디자인 사양 뷰
- 제약 사항(Constraints)의 강조 노출

## 3. Out of Scope
- UI를 통한 DesignSpec 직접 수정 (PRD-039 Re-import 영역)
- 계산된 스펙의 영구 저장

## 4. 표시 사양 및 규칙

### 4.1 패널 구성
- **Location**: 편집기 우측 또는 하단의 별도 패널.
- **Calculation**: 사용자가 노드를 선택하거나 편집할 때마다 PRD-037 로직에 의거하여 **항상 동적으로 계산**한다. 절대 DB에 저장된 값을 참조하지 않는다.

### 4.2 계층별 표시 내용
- **Static Levels**: Series, Volume, Part, Chapter의 사양을 접기/펴기(Collapse/Expand) 형태로 제공.
- **Target Level**: 현재 집필 중인 Section의 전용 사양을 최상단에 배치.

### 4.3 필드 타입별 표시 방식
1. **Override 필드**: 최종 계산에 채택된 값만 표시하되, 출처 레벨(예: "From Chapter")을 병기한다.
2. **Accumulate/Append 필드**: PRD-036의 결합 규칙(정렬/중복제거 등)이 완료된 최종 리스트를 표시한다.

## 5. Review Required 연동
`review_required == true`인 경우, 디자인 프레뷰 패널 상단에 "디자인 변경됨: 본문 검토 필요" 경고 문구를 상시 노출하여 집필자가 변경된 설계를 즉시 인지하도록 강제한다.
