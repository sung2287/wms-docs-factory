# WMS Docs Factory
Draft(초안) 전용 문서 저장소. 정본(Canonical)은 각 메인 레포로 import+commit된 시점부터 유효합니다.

## Directory Layout (Multi-Project)
Each project must exist in both places with the same folder name:
- Docs factory: `/home/sung2287/projects/wms-docs-factory/<project-name>`
- Main repo: `/home/sung2287/projects/<project-name>`

Docs factory project structure:

```text
<project-name>/
  docs/
    prd/
    contract/specs/
    contract/intent_maps/
    platform/
  _imported/
    docs/
      prd/
      contract/specs/
      contract/intent_maps/
      platform/
```

## Importer (WSL Bash)
Script:
- `bin/import_prd_ui.sh`

What it does:
1. Project 선택 메뉴 표시
2. PRD 후보 선택 메뉴 표시 (`docs/prd/PRD-*.md`만 표시)
3. ABCD 4개 문서를 메인 레포의 `docs/**`로 복사
4. 성공 시 source ABCD를 `_imported/docs/**`로 이동
5. 다음 실행 시 해당 PRD는 후보에서 사라짐

Safety rules:
- Source 4개 중 하나라도 없으면 중단 (missing list 출력)
- Destination 파일이 하나라도 이미 있으면 중단 (overwrite 없음)
- Source move는 copy 성공 후에만 수행

## Run From Windows Explorer (Double-Click)
Windows launcher:
- `launcher/IMPORT_PRD.bat`

### 방법 A: `.bat` 직접 더블클릭
1. Windows Explorer에서 WSL 경로를 엽니다.
   - 예: `\\wsl$\Ubuntu\home\sung2287\projects\wms-docs-factory\launcher`
2. `IMPORT_PRD.bat` 더블클릭
3. 새 콘솔 창에서 project/PRD 메뉴를 선택

### 방법 B: 바탕화면 바로가기 만들기
1. `IMPORT_PRD.bat` 우클릭 -> `바로 가기 만들기`
2. 생성된 바로가기를 바탕화면으로 이동
3. 이후 바로가기 더블클릭으로 실행

## Direct WSL Run
From any directory:

```bash
/home/sung2287/projects/wms-docs-factory/bin/import_prd_ui.sh
```
