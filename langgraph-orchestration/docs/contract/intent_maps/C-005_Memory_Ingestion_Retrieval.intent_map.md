# C-005: Memory Ingestion + Retrieval Intent Map

## 1. Problem Recognition (The Why)

- **Long-term Context Loss**: 단일 세션이 길어짐에 따라 초기 대화나 중요 정보가 유실되어 AI의 답변 품질이 저하됨.
- **Information Decay**: 대화가 누적될수록 이전 턴의 정보와 현재 턴의 정보가 섞이거나 잊혀지는 현상을 방지하기 위해 장기 기억(Long-term Memory) 관리가 필수적임.

## 2. Intent Summary (The Core Philosophy)

- **"Memory는 요약(Summary)만 저장한다."**
- **"검색(`RetrieveMemory`)은 Step 기반으로만 실행된다."**
- **Memory는 sessionRef 단위로만 관리되며, 세션 간 메모리 공유는 MVP 범위에 포함되지 않는다.**

## 3. Protection Targets (The What to Protect)

- **Context Continuity**: 대화 턴 전반에 걸친 핵심 문맥의 연속성을 보장함.
- **Policy Consistency**: 생성된 모든 데이터는 특정 정책 버전 하에서 일관성을 유지해야 함.
- **Core Neutrality**: 기억 저장 및 검색을 위해 Core의 구조적 중립성을 훼손하지 않음.

## 4. Risks & Guards (The How to Prevent)

- **Algorithmic Leakage**: 검색 알고리즘이나 요약 알고리즘의 세부 구현이 Core Engine으로 침투하여 핵심 로직을 오염시키는 행위를 '구조적 부패'로 정의하고, 이를 **Step 기반 추상화**로 방지함.
- **Dangerous Silent Fallback**: 검색 실패 시 이를 무시하고 진행하는 것은 '부정확한 답변의 원인'이 되므로, 이를 **Cycle Failure**로 처리하여 데이터 정합성을 보호함.
- **Over-Storage Overextension**: 전체 응답(Full Response)이나 원시 데이터(Raw Content)를 저장하는 행위를 '저장소 낭비 및 관리 복잡성 증가'로 규정하여 **필드 화이트리스트**로 엄격히 제한함.
