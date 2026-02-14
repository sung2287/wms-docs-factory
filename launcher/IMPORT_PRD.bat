@echo off
setlocal

set "WSL_SCRIPT=/home/sung2287/projects/wms-docs-factory/bin/import_prd_ui.sh"

echo [WMS Docs Factory] Starting PRD importer in WSL...
echo.
wsl.exe -e bash -lc "'%WSL_SCRIPT%'"
set "EXIT_CODE=%ERRORLEVEL%"
echo.
if not "%EXIT_CODE%"=="0" (
  echo Importer finished with error code %EXIT_CODE%.
) else (
  echo Importer finished successfully.
)
echo.
pause
exit /b %EXIT_CODE%
