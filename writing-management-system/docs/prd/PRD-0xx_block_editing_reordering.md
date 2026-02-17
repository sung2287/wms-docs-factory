# [PRD-0xx] Block Editing & Reordering

## 1. Objective
단일 문자열로 저장되는 `snippet.body` 내부를 논리적 블록 단위로 구분하여 편집 생산성을 높이고, 블록 간 순서 변경을 용이하게 한다.

## 2. In Scope
- 주요 블록 타입 지원 (Paragraph, Heading, Quote, List)
- 블록 단위 Reorder (Up/Down), 삭제, 타입 전환 기능
- UI 계층의 블록 모델과 저장 계층의 String 모델 간 직렬화

## 3. Out of Scope
- 노드(Section) 간의 블록 이동 (Section 내부로 한정)
- 이미지, 표 등 복합 미디어 블록
- 블록별 개별 스냅샷 관리 (노드 단위 유지)

## 4. 블록 편집 사양

### 4.1 지원 블록 타입
- **Paragraph**: 일반 텍스트 블록.
- **Heading**: `#` 기반의 제목 블록.
- **Quote**: `>` 기반의 인용구 블록.
- **List**: `-` 또는 `1.` 기반의 리스트 블록.

### 4.2 블록 조작 UX
- 각 블록 옆에 핸들러를 배치하여 드래그 앤 드롭 또는 버튼 클릭으로 위/아래 순서 변경.
- 블록 삭제 시 즉시 UI에서 제거하되, `Save` 전까지는 스냅샷에 반영되지 않음.

## 5. 직렬화(Serialization) 원칙
1. **Source of Truth**: 저장소에는 항상 `snippet.body`라는 단일 String 필드로 저장된다.
2. **UI Mapping**: 편집기 로드 시 마크다운 파서를 통해 블록 배열로 분해하고, 저장 시에는 순서대로 결합하여 마크다운 문자열로 변환한다.
3. **Determinism**: 동일한 블록 배열은 항상 동일한 마크다운 문자열로 직렬화되어야 한다.
