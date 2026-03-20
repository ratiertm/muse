# STATE.md — Muse Project Memory

## Current Phase
Phase 4: Flutter 앱 — 기본 UI (NOT STARTED)

## Completed
- [x] Phase 1: 백엔드 코어 (5 plans, 10 tasks)
- [x] Phase 2: God Agent (4 plans, 8 tasks)
  - Scenario API + World State
  - Knowledge Graph + Private State
  - God Agent Core (briefing + update)
  - Chat pipeline integration
- [x] Phase 3: 그룹 채팅 (4 plans, 8 tasks)
  - Group conversation model (is_group, participants table)
  - God Agent turn orchestration (decide_next_speakers)
  - Knowledge isolation in group chat (present_characters only)
  - SSE streaming for multi-character responses

## Key Decisions
- God Agent 아키텍처 채택 (전지적 오케스트레이터)
- GPT-4o-mini (God Agent) + Claude Sonnet (캐릭터) 듀얼 LLM
- Flutter + FastAPI + PostgreSQL
- 오라클 춘천 프리티어 서버
- 애니풍 아바타 (딸 취향: 죠죠, MB: 홈즈/루팡)
- 멀티 프로필 (MB + 딸)
- **그룹챗 별도 엔드포인트** (/api/v1/group-chat)
- **God Agent 동적 턴 결정** (지식 기반 응답자 선택)

## Recent Achievements (Phase 3)
- Group conversation model with participants many-to-many relationship
- God Agent can decide which characters should respond based on knowledge state
- Knowledge isolation: only characters present in the group learn new information
- Secrets/inner_thoughts remain private (not shared in group)
- Multi-character SSE streaming with character_id tracking
- Server tested and verified working

## Next Step
Phase 4: Flutter 앱 기본 UI (프로필 선택, 캐릭터 목록, 채팅 UI)
