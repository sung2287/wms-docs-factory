# Codex CLI Full Reference Guide (Verified)

- **Canonical Source:** [https://developers.openai.com/codex](https://developers.openai.com/codex)
- **Secondary Sources:** Help Center (help.openai.com), GitHub README (openai/codex)
- **Last verification note:** “Community/Observed features separated. Aligned with developers.openai.com structure.”

---

## 📑 Canonical Reference Order
1. [What is Codex (개념/역할)](#1-what-is-codex-개념역할)
2. [Codex CLI 개요](#2-codex-cli-개요)
3. [Installation & Get Started](#3-installation--get-started)
4. [Authentication](#4-authentication)
5. [Interactive Usage (TUI)](#5-interactive-usage-tui)
6. [Non-interactive / Automation](#6-non-interactive--automation)
7. [Review & Diff Workflow](#7-review--diff-workflow)
8. [Safety, Sandbox, Approval](#8-safety-sandbox-approval)
9. [Rules / AGENTS.md](#9-rules--agentsmd)
10. [MCP / Agents / Integration](#10-mcp--agents--integration)
11. [Configuration](#11-configuration)
12. [Appendix: Community / Observed (Non-canonical)](#12-appendix-community--observed-non-canonical)

---

## 1. What is Codex (개념/역할)
Codex는 소프트웨어 개발을 위한 OpenAI의 코딩 에이전트(Coding Agent)입니다.

- **역할:** 의도를 코드로 변환하고, 낯선 코드베이스를 이해하며, 버그를 진단하고 반복적인 개발 작업을 자동화합니다.
- **주요 기능:** 코드 작성, 코드 이해/설명, 코드 리뷰, 디버깅, 작업 자동화.
- **공식 근거:** [What is Codex](https://developers.openai.com/codex)

---

## 2. Codex CLI 개요
터미널 환경에서 직접 Codex 에이전트와 상호작용하기 위한 인터페이스입니다.

- **역할:** 로컬 파일 시스템에 직접 접근하여 코드 조작, 셸 명령 실행, 버전 제어 연동 작업을 수행합니다.
- **공식 근거:** [Using Codex -> CLI](https://developers.openai.com/codex)

---

## 3. Installation & Get Started
에이전트를 로컬 환경에 설치하고 실행 환경을 준비합니다.

- **설치 방식:** npm을 통한 전역 설치 또는 플랫폼별 바이너리 설치를 지원합니다.
- **관련 명령:** 
  ```bash
  npm install -g @openai/codex
  ```
- **공식 근거:** [GitHub README (Secondary)](https://github.com/openai/codex)

---

## 4. Authentication
에이전트 사용을 위해 ChatGPT 계정 또는 API 키를 통해 인증을 수행합니다.

- **인증 방식:** 대화형 로그인(`--login`) 또는 환경 변수를 통한 API 키 인증을 지원합니다.
- **관련 명령:** 
  ```bash
  codex --login
  ```
- **공식 근거:** [Help Center (Secondary)](https://help.openai.com/en/articles/11381614-codex-cli-and-sign-in-with-chatgpt)

---

## 5. Interactive Usage (TUI)
대화형 인터페이스를 통해 자연어로 에이전트에게 지시를 내립니다.

- **사용 시점:** 코드의 의미를 묻거나, 특정 파일의 리팩토링을 실시간으로 가이드할 때 사용합니다.
- **실행 패턴:**
  ```bash
  codex "이 프로젝트의 주요 구조를 설명해줘"
  ```
- **공식 근거:** [Using Codex -> CLI -> Overview](https://developers.openai.com/codex)

---

## 6. Non-interactive / Automation
반복적인 워크플로우를 스크립팅하거나 CI/CD 파이프라인에 통합합니다.

- **사용 시점:** 테스트 자동화, 마이그레이션, 문서 업데이트 등 반복 작업 수행 시.
- **관련 명령/패턴:**
  - `codex exec`: 워크플로우 자동화 실행.
  - `codex --quiet`: 대화형 UI 없이 결과만 출력.
- **공식 근거:** [Using Codex -> Automation](https://developers.openai.com/codex)

---

## 7. Review & Diff Workflow
에이전트가 제안한 변경 사항을 적용하기 전 검토합니다.

- **역할:** 파일 변경 전 Unified Diff를 통해 수정 내용을 확인하고 승인 여부를 결정합니다.
- **공식 근거:** [Using Codex -> App -> Review](https://developers.openai.com/codex)

---

## 8. Safety, Sandbox, Approval
에이전트의 실행 권한을 제어하고 시스템을 보호합니다.

- **승인 모드 (Approval Mode):**
  - **Suggest:** 모든 변경 및 셸 명령에 승인 필요 (기본값).
  - **Auto Edit:** 파일 수정은 자동, 셸 명령은 승인 필요.
  - **Full Auto:** 모든 작업을 승인 없이 수행 (YOLO 모드).
- **보안 장치:** 모든 작업은 로컬 샌드박스 내에서 먼저 시뮬레이션됩니다.
- **공식 근거:** [Administration -> Authentication & Security](https://developers.openai.com/codex), [GitHub README](https://github.com/openai/codex)

---

## 9. Rules / AGENTS.md
에이전트의 동작을 규정하는 규칙과 컨텍스트를 제공합니다.

- **역할:** 프로젝트 루트의 `AGENTS.md` 또는 `codex.md` 파일을 통해 에이전트가 지켜야 할 스타일 가이드나 프로젝트 제약 사항을 정의합니다.
- **공식 근거:** [Using Codex -> Rules](https://developers.openai.com/codex)

---

## 10. MCP / Agents / Integration
Model Context Protocol(MCP) 및 외부 도구와의 연동을 관리합니다.

- **역할:** 외부 데이터 소스나 특수 기능을 갖춘 MCP 서버를 연결하여 에이전트의 능력을 확장합니다.
- **관련 명령:** `/mcp list`, `/mcp refresh`
- **공식 근거:** [Using Codex -> Tools -> MCP Server](https://developers.openai.com/codex)

---

## 11. Configuration
에이전트의 전역 및 프로젝트별 설정을 관리합니다.

- **설정 파일:** `~/.codex/config.yaml`
- **주요 옵션:** 기본 모델(`model`), 에러 처리 모드(`fullAutoErrorMode`) 등.
- **공식 근거:** [GitHub README (Secondary)](https://github.com/openai/codex)

---

## 12. Appendix: Community / Observed (Non-canonical)
공식 문서에 명시되지 않았으나 실제 실행 또는 커뮤니티에서 확인된 동작입니다.

- **`/undo` / `/rewind` (Observed):** 마지막 대화나 파일 변경을 취소하는 명령. 공식 문서에는 `restore` 기능으로 설명됨.
- **`-q` / `--quiet` (Community):** 비대화형 모드 플래그. 공식 문서에는 `Non-interactive mode`로 개념적 설명.
- **`-m` / `--model` (Community):** 모델 수동 지정 플래그. 공식 설정 파일 설명을 통한 유추.

---

## 📑 Changelog (This Revision)
- **Structure Reset:** `developers.openai.com/codex` 흐름에 맞춰 전체 섹션 재배치.
- **Source Isolation:** 각 섹션 하단에 정전적 근거(Canonical)와 보조 근거(Secondary) 명시.
- **Appendix Isolation:** 공식 문서에 명시되지 않은 `-q`, `-m`, `/undo` 등을 부록으로 격리.
- **Terminology Alignment:** 'What is Codex'의 공식 정의(Coding Agent)를 반영하여 용어 정정.

---
*참조: [OpenAI Codex 공식 개발자 문서](https://developers.openai.com/codex)*

