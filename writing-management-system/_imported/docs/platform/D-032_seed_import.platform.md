# Platform: Seed Import Pipeline

## 1. Import Pipeline Flow
1. **Scan Phase**: 지정된 디렉토리의 Excel과 Markdown 파일을 스캔하여 볼륨 인덱스 파싱.
2. **Parse Phase**: Excel 구조 분석 및 `external_key` 생성. Markdown의 `@design_chapter` 추출.
3. **Validate Phase**: 1:1 매핑 확인 및 구조적 정합성 검증.
4. **Transform Phase**: 
   - Node Entities 생성.
   - Snippet Entities 생성 (Leaf는 MD 내용, Non-leaf는 empty).
5. **Persist Phase**: DB에 Workspace, Nodes, Snippets 저장 (트랜잭션).
6. **Finalize Phase**: 첫 번째 Snapshot 생성 및 헤드 설정.

## 2. Archive location
- Seed Import 중 발생하는 불일치 파일은 Archive로 이동하지 않고 에러와 함께 종료한다. (Archive는 Re-import 전용).

## 3. Layering
- **Adapter**: `ExcelToBlueprintParser`, `MarkdownToSnippetParser`.
- **Core**: `WorkspaceFactory`, `HierarchyValidator`.
- **App**: `ImportOrchestrator` (파일 스캔 및 전체 파이프라인 제어).
