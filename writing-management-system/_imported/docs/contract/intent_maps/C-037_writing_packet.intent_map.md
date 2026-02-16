# Intent Map: Writing Packet Extraction

## 1. Intent Summary
집필자가(인간 또는 AI) 특정 섹션을 작성하기 위해 필요한 모든 '설계적 맥락'을 정제하여 제공하는 것을 목적으로 한다. 시스템은 집필 도구를 제공하는 것이 아니라, 집필을 위한 '가장 완벽한 정보 꾸러미'를 제공하는 데 집중한다.

## 2. Fixed Policies
- **Read-Only**: Packet 추출은 시스템 상태를 변경하지 않는다.
- **Design-Centric**: 내용(Body)보다 설계(Spec) 정보를 우선적으로 노출한다.
- **No Storage**: 추출된 Packet은 영구 저장하지 않는다.

## 3. Forbidden Evolutions
- Packet 내부에 AI 프롬프트 템플릿을 직접 포함하는 행위 금지 (프롬프트 엔진은 별도 계층).
- Packet 추출 시점에 내용을 자동 생성하는 기능 금지.

## 4. Core & Sandbox Boundary
- **Core**: Composition 엔진, Context 추출 로직.
- **Sandbox**: 특정 LLM에 최적화된 Packet 포맷 변환기.

## 5. Future Expansion
- 실시간 집필 중 디자인 위반 사항을 체크하기 위한 증분 Packet 공급.

## 6. Test Constitution v1.7 Intent Summary
- `context_depth`에 따른 인접 섹션 노출 범위의 정확성 검증.
- `effective_design_spec`이 비즈니스 로직에 정의된 우선순위대로 계산되는지 단위 테스트.
