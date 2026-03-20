# STATE.md — Muse Project Memory

## Current Phase
Phase 5: 고급 기능 (NOT STARTED)

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
- [x] Phase 4: Flutter 앱 기본 UI (12 plans)
  - Flutter project setup (Riverpod, dio, go_router, freezed)
  - Material 3 dark/light theme (minimal design)
  - Profile selection + PIN auth (MB / 딸)
  - Character list screen (grid layout with cards)
  - Character creation form (name, personality, speech_style, backstory, tags)
  - Chat screen with SSE streaming (real-time typing effect)
  - Message bubbles with markdown rendering
  - Conversation history support
  - flutter analyze passes with no issues

## Key Decisions
- God Agent 아키텍처 채택 (전지적 오케스트레이터)
- GPT-4o-mini (God Agent) + Claude Sonnet (캐릭터) 듀얼 LLM
- Flutter + FastAPI + PostgreSQL
- 오라클 춘천 프리티어 서버
- 애니풍 아바타 (딸 취향: 죠죠, MB: 홈즈/루팡)
- 멀티 프로필 (MB + 딸)
- **그룹챗 별도 엔드포인트** (/api/v1/group-chat)
- **God Agent 동적 턴 결정** (지식 기반 응답자 선택)

## Recent Achievements (Phase 4)
- Complete Flutter app structure with clean architecture
- Profile selection (hardcoded: MB / 딸) → PIN auth → JWT storage
- Character list with grid layout, pull-to-refresh
- Character creation with form validation (name, personality, speech_style, backstory, tags)
- Chat screen with SSE streaming from backend
- Real-time typing effect with markdown rendering (*italic* = actions, normal = dialogue)
- Message bubbles (user: right, character: left with avatar)
- Theme switching (dark/light) with Material 3
- API client with auto-JWT injection via interceptor
- All screens navigate via go_router
- Code passes `flutter analyze` with zero issues

## Next Step
Phase 5: 고급 기능 (원작 자동 생성, 애니풍 아바타, 그룹챗 UI)
