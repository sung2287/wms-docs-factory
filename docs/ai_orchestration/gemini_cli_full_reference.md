# Gemini CLI Full Reference Guide (Verified)

“This document follows the same structural reference model as Codex CLI, with Gemini CLI–specific capabilities mapped into the shared framework.”

- **Canonical Source:** [https://geminicli.com/docs/cli/](https://geminicli.com/docs/cli/)
- **Secondary Sources:** [명령어 레퍼런스](https://geminicli.com/docs/cli/commands/), [도구 상세](https://geminicli.com/docs/tools/), [설정 상세](https://geminicli.com/docs/reference/configuration/)
- **Last verification note:** “Aligned with shared structural reference model. Content preserved from geminicli.com.”

---

## 📑 Canonical Reference Order
1. [What is Gemini CLI (개념/역할)](#1-what-is-gemini-cli-개념역할)
2. [Gemini CLI 개요](#2-gemini-cli-개요)
3. [Installation & Get Started](#3-installation--get-started)
4. [Authentication](#4-authentication)
5. [Interactive Usage](#5-interactive-usage)
6. [Non-interactive / Automation](#6-non-interactive--automation)
7. [Review & Diff / Planning](#7-review--diff--planning)
8. [Safety / Sandbox / Approval](#8-safety--sandbox--approval)
9. [Rules / Policies / Memory](#9-rules--policies--memory)
10. [Integration / Tools / MCP](#10-integration--tools--mcp)
11. [Configuration](#11-configuration)
12. [Appendix (Non-canonical / Observed)](#12-appendix-non-canonical--observed)
13. [Changelog](#13-changelog)

---

## 1. What is Gemini CLI (개념/역할)
Gemini CLI는 소프트웨어 개발을 위한 Gemini AI 모델의 기능을 개발 워크플로우에 직접 통합하는 터미널 기반 인터페이스입니다.

- **역할:** 로컬 파일, 셸 환경 및 프로젝트 컨텍스트를 사용하여 AI와 상호작용할 수 있도록 하여, 생성형 AI와 시스템 도구 간의 다리 역할을 합니다.
- **공식 근거:** [Gemini CLI 개요](https://geminicli.com/docs/cli/)

---

## 2. Gemini CLI 개요
이 문서는 Gemini CLI 공식 문서(`geminicli.com`)의 실제 내용을 바탕으로 작성된 최종 참조 가이드입니다. 검증된 명령어와 설정값만을 포함합니다.

---

## 3. Installation & Get Started
에이전트를 로컬 환경에 설치하고 빠른 실행을 위한 초기 설정을 수행합니다.

### 설치 및 초기화
- **설치:** `npm install -g @google/gemini-cli`
- **초기화:** `/init` 명령어로 현재 프로젝트를 분석하고 `GEMINI.md` 컨텍스트 파일을 자동 생성.

### 빠른 실행 패턴
- `gemini`: 인터랙티브 모드 진입.
- `gemini --prompt-interactive "질문"`: 특정 질문과 함께 인터랙티브 모 시작.
- `gemini --output-format json "질문"`: 결과를 JSON 형식으로 출력 (비대화형).

> **공식 근거:** [CLI Overview](https://geminicli.com/docs/cli/)

---

## 4. Authentication
에이전트 사용을 위한 권한 인증을 수행합니다.

- **인증 방식:** `/auth` 명령어를 통해 대화형으로 설정하거나 `GEMINI_API_KEY` 환경 변수 사용.

---

## 5. Interactive Usage
대화형 인터페이스와 파일 컨텍스트를 활용한 상호작용 방식입니다.

### 앳 명령어 (@ Commands)
- **단일 파일:** `@src/App.tsx 코드를 설명해줘`
- **디렉터리:** `@src/ 디렉토리 내의 전체 구조 요약`
- **다중 파일:** `@file1.ts @file2.ts 두 파일 간의 인터페이스 차이점 분석`

### 채팅 관리 (/chat)
- **`/chat save <tag>`**: 현재 대화 상태를 태그와 함께 저장 (체크포인트).
- **`/chat list`**: 저장된 체크포인트 목록 표시.
- **`/chat resume <tag>`**: 특정 체크포인트에서 대화 재개.
- **`/chat delete <tag>`**: 저장된 체크포인트 삭제.
- **`/chat share [filename]`**: 현재 대화를 Markdown/JSON으로 저장.

---

## 6. Non-interactive / Automation
셸 명령 실행 및 자동화된 정보 수집 방식입니다.

### 느낌표 명령어 (! Commands)
- **명령 실행:** `!ls -la` (시스템 셸 명령 직접 실행 및 결과 표시).
- **셸 모드 토글:** 단독 `!` 입력 시 셸 모드(Shell Mode)로 전환.

### 정보 수집 도구
- **`google_web_search`**: 실시간 정보 검색.
- **`web_fetch`**: 특정 URL의 콘텐츠 가져오기 및 요약.

---

## 7. Review & Diff / Planning
변경 사항 검토 및 작업 계획 관리 기능입니다.

### 계획 모드 (/plan)
- **기능:** 에이전트가 제안한 계획을 검토하는 읽기 전용 모드로 전환.
- **활용:** 대규모 리팩토링 전 작업 단계를 확인하는 데 사용.

### 히스토리 제어
- **`/rewind`**: 대화 및 파일 변경 사항을 뒤로 되돌림 (단축키: `Esc` 두 번).
- **`/restore`**: 도구가 실행되기 직전의 상태로 파일 복구.
- **`/compress`**: 현재까지의 채팅 내역을 요약으로 압축하여 토큰 절약.

---

## 8. Safety / Sandbox / Approval
시스템 보안 및 실행 권한 제어 정책입니다.

### 보안 도구
- **Sandbox:** `sandbox: true` 설정 시 호스트 시스템으로부터 변경 사항 격리.
- **Folder Trust:** `folderTrust.enabled`를 통해 허용된 디렉토리만 접근하도록 제한.
- **YOLO Mode:** `--yolo` 플래그 사용 시 모든 도구 호출을 승인 절차 없이 자동 실행 (주의 필요).

### 정책 관리 (/policies)
- **`/policies list`**: 활성화된 모든 보안 및 동작 정책 나열.

---

## 9. Rules / Policies / Memory
에이전트의 지침 및 장기 기억 관리 기능입니다.

### 계층적 메모리 (/memory)
AI가 지켜야 할 지침과 사실을 관리합니다.
- **`/memory add <text>`**: 중요한 사실을 메모리에 추가.
- **`/memory list`**: 현재 사용 중인 모든 `GEMINI.md` 파일 경로 표시.
- **`/memory refresh`**: 전역/프로젝트/하위 디렉토리의 모든 `GEMINI.md` 다시 로드.
- **`/memory show`**: 현재 로드된 전체 지침 컨텍스트 표시.

---

## 10. Integration / Tools / MCP
외부 프로토콜 연동 및 자동 호출 도구 레퍼런스입니다.

### 파일 시스템 도구 (Model-triggered)
에이전트가 작업을 수행할 때 자동으로 호출하는 도구입니다.
- **`list_directory`**: 파일 및 폴더 목록 나열.
- **`read_file`**: 특정 파일 내용 읽기 (`offset`, `limit` 인수로 부분 읽기 가능).
- **`replace`**: 파일 내 텍스트 정밀 수정 (`old_string`, `new_string` 사용).
- **`glob`**: 패턴 매칭으로 파일 찾기.

### 상호작용 및 MCP
- **`run_shell_command`**: 모델이 셸 명령을 실행하도록 요청할 때 사용.
- **`ask_user`**: 추가 정보가 필요할 때 사용자에게 질문.
- **`/mcp list`**: MCP 서버 및 도구 목록 확인.

### 전체 명령어 레퍼런스 (Full Command List)
| 명령어 | 설명 |
| :--- | :--- |
| `/about` | 버전 정보 표시 |
| `/auth` | 인증 설정 대화 상자 열기 |
| `/bug` | 이슈 제출 가이드 |
| `/clear` | 터미널 화면 지우기 (Ctrl+L) |
| `/copy` | 마지막 응답 클립보드 복사 |
| `/dir add <p>` | 작업 공간에 디렉토리 추가 |
| `/help` | 명령어 및 사용법 표시 (또는 `/?`) |
| `/model` | 모델 선택 대화 상자 |
| `/skills list` | 활성/비활성 스킬 목록 |
| `/stats` | 토큰 사용량 및 세션 통계 |
| `/theme` | 시각적 테마 변경 |
| `/tools desc` | 사용 가능한 도구의 상세 설명 |
| `/vim` | Vim 모드 토글 |

---

## 11. Configuration
에이전트의 동작을 세밀하게 제어하는 환경 변수 및 설정 파일입니다.

### 환경 변수 (Environment Variables)
- `GEMINI_API_KEY`: API 인증 키.
- `GEMINI_MODEL`: 기본 모델 지정 (예: `gemini-1.5-pro`).
- `GEMINI_CLI_HOME`: 설정 및 저장소 루트 경로.
- `DEBUG_MODE`: 상세 디버그 로그 활성화.

### 설정 파일 (settings.json)
위치: `~/.gemini/settings.json` (전역) 또는 `./.gemini/settings.json` (프로젝트별).
- **`sandbox`**: 도구 실행 시 격리 환경 사용 여부 (`boolean` | `string`).
- **`preferredEditor`**: `/editor` 명령 시 사용할 기본 편집기.
- **`vimMode`**: Vim 키 바인딩 활성화.
- **`checkpointing.enabled`**: 자동 체크포인트 생성 여부.

---

## 12. Appendix (Non-canonical / Observed)
공식 문서 외에 관찰된 동작이나 실험적 플래그, 주의사항입니다.

- **토큰 캐싱:** 반복적인 대규모 컨텍스트 사용 시 토큰 캐싱을 통해 비용과 속도를 최적화합니다.
- **모델 라우팅:** 작업의 복잡도에 따라 `flash` 또는 `pro` 모델로 자동 라우팅됩니다.
- **페이저 설정:** `PAGER` 환경 변수를 통해 긴 출력물의 페이저(cat, less 등)를 지정할 수 있습니다.
- **.geminiignore:** AI 전용 차단 목록으로 접근하지 못할 파일 패턴을 정의합니다.

---

## 13. Changelog

### [2024-02-21] (Current Update)
- **Refactoring:** Codex CLI의 13단계 Canonical Reference Order에 맞춰 문서 구조 리팩토링.
- **Mapping:** File Management -> Interactive Usage/Tools, Memory -> Rules/Policies 등으로 매핑.
- **Validation:** 기존 모든 명령어 및 설명 원문 유지 확인.
- **Clean-up:** 404 오류 링크 정리 및 공식 웹 문서 기반 검증 완료.

---
*참조: [Gemini CLI 공식 문서](https://geminicli.com/docs)*


