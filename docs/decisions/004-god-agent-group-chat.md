# ADR-004: 그룹 채팅 God Agent 패턴

- **Status**: Accepted
- **Date**: 2026-03-20
- **Context**: 그룹 채팅에서 여러 캐릭터가 응답할 때, 누가 언제 말할지 결정하는 오케스트레이터가 필요.
- **Decision**: God Agent 패턴 — Haiku가 먼저 "누가 응답해야 하는가"를 판단 → 해당 캐릭터들이 Sonnet으로 순차 응답
- **Alternatives considered**:
  - 모든 캐릭터가 항상 응답 → 대화가 느리고 부자연스러움
  - 랜덤 선택 → 맥락 무시
  - 단일 LLM 호출로 모든 캐릭터 응답 생성 → 개성 표현 약함
- **Consequences**:
  - 자연스러운 그룹 대화 (관련 캐릭터만 응답)
  - LLM 호출이 N+1회 (판단 1회 + 응답 N회)로 비용 증가
  - Haiku 판단이 가끔 부정확 (엉뚱한 캐릭터 선택)
