# PRD-024: Workspace 저장 모델 정교화 (Save Model Refinement)

---

## 1. 목적 (Why)

PRD-021까지의 구현으로 Tree + Snippet 편집 및 통합 화면은 완성되었다.

이제 시스템은 명확한 저장 철학을 고정해야 한다.

본 PRD는 다음 질문에 대한 최종 답을 정의한다:

> Workspace는 언제, 무엇을, 어떤 방식으로 저장되는가?

---

## 2. 저장 철학 (LOCKED)

### 모델: C (Memory-first + Explicit Save)

- 사용자의 모든 편집은 즉시 메모리 상태에 반영된다.
- 서버 영속화는 명시적 Save 버튼 클릭 시에만 수행된다.
- 자동 저장은 도입하지 않는다.
- rev는 서버에서만 증가하며 클라이언트는 이를 신뢰한다.

이 모델은 사용자의 "확정 시점"을 명확히 하며, 상태 동기화 복잡도를 최소화한다.

---

## 3. 저장 단위 (LOCKED)

### Full Snapshot Replace

- 저장은 항상 WorkspaceSnapshot 전체를 교체한다.
- 부분 패치(patch) 저장은 도입하지 않는다.
- PUT /api/workspaces/default는 전체 스냅샷 교체를 유지한다.

이 정책은 단순성과 안정성을 우선한다.

### 성능 고려사항 (Non-blocking Note)

- Snapshot 크기가 비대해질 경우 네트워크 오버헤드가 발생할 수 있다.
- 현재 스니펫 중심 구조에서는 관리 가능한 수준으로 판단한다.
- 대용량 최적화는 향후 PRD-025 이후 단계에서 검토한다.

---

## 4. 상태 모델 정의

WorkspaceStore 상태는 다음을 포함한다:

```
{
  snapshot: WorkspaceSnapshot,
  selectedNodeId: string | null,
  isDirty: boolean,
  isSaving: boolean
}
```

---

## 5. Dirty 정책 (LOCKED)

### Dirty는 행동 기반(action-based)으로 추적한다.

isDirty = true 조건:

- Tree 구조 변경
- Snippet 생성/삭제
- Snippet rawText 수정
- linkedSnippetId 변경

isDirty = false 조건:

- Save 성공 직후
- 최초 로드 직후

### 상태 전이 명세

- Load → isDirty = false
- Edit/Structure Change → isDirty = true
- Save Success → isDirty = false

### Unload 정책

```
if (isDirty === true)
  → 브라우저 beforeunload 경고 표시
```

예외 규칙은 두지 않는다.

---

## 6. Save 버튼 동작 (LOCKED)

Save 버튼 클릭 시:

1. isSaving = true
2. UI 편집 입력 read-only / disabled 처리 (저장 중 잠금)
3. 현재 snapshot 전체를 PUT
4. 성공 시:
   - rev 정확히 +1 증가
   - updatedAt 갱신
   - isDirty = false
   - isSaving = false
5. 실패 시:
   - isSaving = false
   - isDirty 유지
   - 사용자에게 오류 표시

저장 중에는 추가 편집을 허용하지 않는다.

---

## 7. Rev 정책 (LOCKED)

- rev는 서버에서만 증가한다.
- 메모리 상태 변경은 rev를 증가시키지 않는다.
- Save 성공 시에만 정확히 +1 증가해야 한다.
- 서버에서 반환된 rev 값은 클라이언트 상태에 즉시 반영되어야 한다.

---

## 8. UX 규칙

- isDirty = true → TopBar에 "Unsaved changes" 표시
- isDirty = false → Save 버튼 비활성화
- isSaving = true → 저장 중 표시 + 편집 비활성화

---

## 9. 테스트 전략 (Implementation Guide)

다음 시나리오는 자동화 테스트에 포함되어야 한다:

1. Dirty Trigger Test
   - 트리 순서 변경 시 isDirty가 true로 변경되는지 검증

2. Save Integrity Test
   - 저장 API 호출 중 추가 편집 시도가 차단되는지 검증

3. Revision Consistency Test
   - 저장 성공 후 서버에서 반환된 rev 값이 클라이언트 상태에 정확히 반영되는지 검증

---

## 10. 제외 범위

- Snapshot 전략 세부 구조 (PRD-025)
- Backup / Restore (PRD-026)
- Schema Version / Migration (PRD-027)
- 다중 사용자 충돌 해결

---

## 11. 수용 기준 (Acceptance Criteria)

1. 편집 시 isDirty가 정확히 true로 변경된다.
2. Save 성공 시 isDirty가 false로 변경된다.
3. isDirty === true 상태에서 페이지를 닫으려 하면 경고가 표시된다.
4. Save 중에는 입력이 차단된다.
5. rev는 Save 성공 시에만 증가한다.
6. 서버에서 반환된 rev가 클라이언트 상태에 정확히 반영된다.
7. 기존 테스트는 깨지지 않는다.

---

## One-line Summary

Workspace는 메모리 우선 방식으로 동작하며, 전체 스냅샷 교체 기반의 명시적 Save 모델과 행동 기반 Dirty 추적을 채택한다.

