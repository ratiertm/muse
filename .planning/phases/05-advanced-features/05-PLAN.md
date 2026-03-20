# Phase 5: 고급 기능 — Detailed Plan

**Goal:** 원작 자동 생성, 아바타, 그룹챗 UI 완성
**Success Metric:** "죠죠 디오" 입력하면 캐릭터가 자동 생성되고 애니 아바타도 나온다

---

## Plan 01: 원작 기반 캐릭터 자동 생성

### Backend Tasks

**Task 01.1: Auto-generation prompt & service**
- File: `backend/app/core/auto_generator.py`
- Class: `CharacterAutoGenerator`
- Method: `generate_from_source(source_work: str, character_name: str) -> CharacterCreate`
- Uses GPT-4o-mini to generate:
  - personality (3-5 sentences)
  - speech_style (2-3 sentences)
  - backstory (1 paragraph)
  - scenario (default scenario context)
  - first_message (in-character greeting)
  - example_dialogue (3-5 exchanges)
  - tags (auto-extracted from source work)
- Prompt template:
  ```
  You are a character expert. Generate a detailed character card for:
  Source Work: {source_work}
  Character Name: {character_name}
  
  Return JSON with: personality, speech_style, backstory, scenario, first_message, example_dialogue, tags
  Be faithful to the original character. Use Korean for all text.
  ```

**Task 01.2: Auto-generate endpoint**
- File: `backend/app/api/v1/characters.py`
- Endpoint: `POST /api/v1/characters/auto-generate`
- Request: `{"source_work": str, "character_name": str}`
- Response: `CharacterCreate` (pre-filled, ready for user to edit/save)
- Does NOT save to DB — just returns the generated data

**Task 01.3: New schema**
- File: `backend/app/schemas/character.py`
- Add: `CharacterAutoGenerateRequest(source_work, character_name)`

### Frontend Tasks

**Task 01.4: Auto-generate button on character create screen**
- File: `frontend/lib/presentation/screens/character_create/character_create_screen.dart`
- Add "원작에서 가져오기" button above form
- Opens dialog with 2 text fields: 작품명, 캐릭터명
- On submit → API call → fill form fields
- User can still edit before saving

**Task 01.5: API client method**
- File: `frontend/lib/data/repositories/character_repository.dart`
- Method: `autoGenerateCharacter(sourceWork, characterName) → CharacterCreate`

---

## Plan 02: 애니풍 캐릭터 아바타 AI 생성

### Backend Tasks

**Task 02.1: Avatar generator service**
- File: `backend/app/core/avatar_generator.py`
- Class: `AvatarGenerator`
- Method: `generate_avatar(character: Character) -> str` (returns image URL)
- Uses OpenAI DALL-E 3:
  - Prompt: "Anime-style portrait of {name}. {personality summary}. High quality, detailed, colorful, 1024x1024."
  - Returns image URL from OpenAI response
  - For now: store OpenAI-hosted URL directly (later: download + upload to storage)

**Task 02.2: Avatar endpoint**
- File: `backend/app/api/v1/characters.py`
- Endpoint: `POST /api/v1/characters/{character_id}/generate-avatar`
- Response: `{"avatar_url": str}`
- Updates character.avatar_url in DB
- Returns new avatar URL

### Frontend Tasks

**Task 02.3: Avatar generation button**
- File: `frontend/lib/presentation/screens/character_create/character_create_screen.dart`
- Add "아바타 생성" button next to avatar preview
- Shows loading spinner while generating
- Updates avatar preview on success
- Toast on error

**Task 02.4: API client method**
- File: `frontend/lib/data/repositories/character_repository.dart`
- Method: `generateAvatar(characterId) → String` (returns avatar URL)

**Task 02.5: Avatar regeneration**
- Same button works on edit mode
- Can regenerate if user doesn't like first result

---

## Plan 03: 그룹 채팅 UI

### Frontend Tasks

**Task 03.1: Group chat creation screen**
- File: `frontend/lib/presentation/screens/group_create/group_create_screen.dart`
- Route: `/group/create`
- Form:
  - Title (text field)
  - Scenario selector (dropdown or list)
  - Character multi-select (checkboxes, min 2)
  - "채팅 시작" button → creates group via API → navigates to group chat screen

**Task 03.2: Group chat screen**
- File: `frontend/lib/presentation/screens/group_chat/group_chat_screen.dart`
- Route: `/group-chat/:conversationId`
- UI:
  - AppBar: group title + participant avatars (horizontal scroll)
  - Message list:
    - Each message shows character avatar + name
    - Different colors per character (hash character ID for color)
  - Input field at bottom
  - Send → SSE stream with multiple character responses
  - Each character response appends separately

**Task 03.3: Group chat repository**
- File: `frontend/lib/data/repositories/group_chat_repository.dart`
- Methods:
  - `createGroupChat(scenarioId, characterIds, title) → Conversation`
  - `sendGroupMessage(conversationId, message) → Stream<GroupChatEvent>`
  - `getGroupParticipants(conversationId) → List<Character>`

**Task 03.4: SSE handling for group chat**
- Parse SSE events: `{character_id, character_name, chunk, is_done}`
- Accumulate chunks per character_id
- Display each character's message as it arrives

**Task 03.5: Update router**
- File: `frontend/lib/core/router/app_router.dart`
- Add routes:
  - `/group/create`
  - `/group-chat/:conversationId`

---

## Plan 04: 시나리오 관리 UI

### Frontend Tasks

**Task 04.1: Scenario list screen**
- File: `frontend/lib/presentation/screens/scenario_list/scenario_list_screen.dart`
- Route: `/scenarios`
- Shows all user scenarios (grid or list)
- Each card: name, description, character count, "편집" button
- "+" FAB → create new scenario

**Task 04.2: Scenario create/edit screen**
- File: `frontend/lib/presentation/screens/scenario_edit/scenario_edit_screen.dart`
- Route: `/scenario/create` or `/scenario/edit/:scenarioId`
- Form:
  - Name, description
  - Character multi-select (add/remove)
  - World state display (read-only JSON or pretty-printed)
- Save button → POST/PUT scenario

**Task 04.3: Scenario repository**
- File: `frontend/lib/data/repositories/scenario_repository.dart`
- Methods:
  - `getScenarios() → List<Scenario>`
  - `getScenario(id) → Scenario`
  - `createScenario(ScenarioCreate) → Scenario`
  - `updateScenario(id, ScenarioUpdate) → Scenario`
  - `deleteScenario(id)`
  - `getScenarioCharacters(id) → List<Character>`
  - `addCharacterToScenario(scenarioId, characterId)`
  - `removeCharacterFromScenario(scenarioId, characterId)`

**Task 04.4: User persona settings screen**
- File: `frontend/lib/presentation/screens/settings/persona_settings_screen.dart`
- Route: `/settings/persona`
- Form:
  - User name (default: "User")
  - User description (optional, for roleplay context)
- Save to local storage (shared_preferences)
- Used in chat prompts (pass to backend)

**Task 04.5: Scenario models**
- File: `frontend/lib/data/models/scenario.dart`
- Freezed model matching backend schema:
  - id, userId, name, description, worldState (JSON), createdAt, updatedAt

**Task 04.6: Update navigation**
- Add "시나리오" tab or menu item from character list screen
- Add "설정" menu item → persona settings

---

## Implementation Order

1. **Plan 01 (Auto-generate)** — Backend → Frontend
2. **Plan 02 (Avatar)** — Backend → Frontend
3. **Plan 04 (Scenarios)** — Frontend only (backend already exists)
4. **Plan 03 (Group chat)** — Frontend only (backend already exists)

---

## Success Criteria

- [ ] User enters "죠죠의 기묘한 모험" + "디오" → character auto-fills
- [ ] Click "아바타 생성" → anime avatar appears
- [ ] Create scenario with 3 characters → group chat works
- [ ] Scenario UI shows world state
- [ ] User persona settings saved
- [ ] `flutter analyze` passes
- [ ] All features work end-to-end

---

## Testing Checklist

- [ ] Auto-generate: "죠죠의 기묘한 모험" → "디오"
- [ ] Auto-generate: "셜록 홈즈" → "셜록 홈즈"
- [ ] Avatar generation for new character
- [ ] Avatar regeneration for existing character
- [ ] Create scenario → add characters → start group chat
- [ ] Group chat: user message → multiple character responses
- [ ] Scenario list → edit → add/remove characters
- [ ] User persona: change name → appears in chat prompts
