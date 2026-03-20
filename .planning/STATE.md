# STATE.md — Muse Project Memory

## Current Phase
Phase 6: 배포 & 폴리싱 (NOT STARTED)

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
- [x] Phase 5: 고급 기능 (4 plans)
  - Character auto-generation from source work (GPT-4o-mini)
  - Anime avatar generation (DALL-E 3)
  - Group chat UI with multi-character support
  - Scenario management UI (create, edit, add/remove characters)
  - Navigation drawer with scenarios and group chat links

## Key Decisions
- God Agent 아키텍처 채택 (전지적 오케스트레이터)
- GPT-4o-mini (God Agent) + Claude Sonnet (캐릭터) 듀얼 LLM
- Flutter + FastAPI + PostgreSQL
- 오라클 춘천 프리티어 서버
- 애니풍 아바타 (딸 취향: 죠죠, MB: 홈즈/루팡)
- 멀티 프로필 (MB + 딸)
- **그룹챗 별도 엔드포인트** (/api/v1/group-chat)
- **God Agent 동적 턴 결정** (지식 기반 응답자 선택)

## Recent Achievements (Phase 5)
- **Auto-Generation:** "원작에서 가져오기" button on character create screen
  - Dialog: source work + character name input
  - GPT-4o-mini generates personality, speech_style, backstory, scenario, first_message, example_dialogue, tags
  - Pre-fills form for user review/edit
- **Avatar Generation:** "아바타 생성" button (after character save)
  - DALL-E 3 generates anime-style portrait from character traits
  - Updates character.avatar_url
  - Option to regenerate
- **Scenario Management:**
  - Scenario list screen (/scenarios)
  - Scenario create/edit screen (name, description, character add/remove)
  - Character selection for scenarios
- **Group Chat:**
  - Group create screen: select scenario + characters (min 2)
  - Group chat screen: multi-character messages with avatars
  - SSE streaming with character identification per chunk
  - Color-coded character names and avatars
- **Navigation:** Drawer menu with scenarios, group chat, settings
- flutter analyze: 5 info warnings only (deprecations + style)

## Next Step
Phase 6: 배포 & 폴리싱 (오라클 서버, APK 빌드, 실사용 테스트)
