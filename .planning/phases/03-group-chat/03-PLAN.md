# Phase 3: 그룹 채팅 — 실행 계획

**Goal:** 여러 캐릭터가 동시에 대화하며 각자 다른 지식 상태를 유지한다  
**Success Criteria:** 3명 캐릭터 그룹챗에서 비밀을 아는 캐릭터만 반응한다

---

## Wave 1: Group Chat Data Model

### Plan 01: Group Conversation Model Extension

#### Task 1.1: Extend Conversation & Message Models for Group Chat
- **type:** auto
- **files:**
  - `backend/app/models/conversation.py` (수정) — `is_group` flag 추가
  - `backend/app/models/message.py` (수정) — `character_id` 추가 (누가 말했는지)
  - `backend/app/models/group_conversation_participant.py` (신규) — Many-to-many 관계 테이블
    - id (PK)
    - conversation_id (FK to conversations)
    - character_id (FK to characters)
    - turn_order (Integer) — 발언 순서 (NULL 허용, God Agent가 동적 결정 가능)
    - created_at
    - 복합 유니크: (conversation_id, character_id)
  - `backend/alembic/versions/00X_group_chat_models.py` — 마이그레이션
- **action:**
  - Conversation 모델에 `is_group: bool = False` 컬럼 추가
  - Message 모델에 `character_id: UUID | None` 추가 (null = 유저 메시지)
  - GroupConversationParticipant 모델 생성
  - Alembic 마이그레이션 작성 및 실행
- **verify:**
  - `poetry run alembic upgrade head` 성공
  - DB에 is_group, character_id 컬럼 추가 확인
  - group_conversation_participants 테이블 생성 확인
- **done:** 그룹 채팅을 위한 데이터 모델 준비 완료

#### Task 1.2: Group Chat Schemas
- **type:** auto
- **files:**
  - `backend/app/schemas/chat.py` (수정) — 그룹챗 스키마 추가
    - `GroupChatCreateRequest` — scenario_id, character_ids[], title
    - `GroupChatMessageRequest` — conversation_id, message
    - `GroupChatMessageResponse` — character_id, character_name, content
    - `GroupChatStreamEvent` — character_id, chunk, is_done
- **action:**
  - Pydantic 스키마 정의
  - character_id를 응답에 포함하여 클라이언트가 누가 말했는지 알 수 있게 함
- **verify:**
  - 스키마 import 에러 없음
  - FastAPI docs에서 스키마 확인 가능
- **done:** 그룹챗 API 스키마 준비 완료

---

## Wave 2: Group Chat Orchestration & Knowledge Isolation

### Plan 02: God Agent Group Chat Turn Orchestration

#### Task 2.1: God Agent 그룹챗 턴 결정 로직
- **type:** auto
- **files:**
  - `backend/app/core/god_prompts.py` (수정) — 그룹챗 프롬프트 추가
    - `GROUP_TURN_DECISION_PROMPT` — 어떤 캐릭터가 다음에 응답할지 결정
      - 입력: 참여 캐릭터 목록, world_state, 최근 대화, user_message
      - 출력: JSON `{"responding_characters": [character_id, ...], "reasoning": "..."}`
      - 1명 이상 응답 가능 (동시 발언 or 순차 발언)
  - `backend/app/core/god_agent.py` (수정) — 그룹챗 메서드 추가
    - `async decide_next_speakers(db, scenario, participants, user_message, conversation_history) -> list[UUID]`
      - God Agent가 누가 응답할지 결정
      - 캐릭터 지식 상태 고려 (비밀 아는 사람만 반응)
      - 반환: 응답할 character_id 리스트
- **action:**
  - 그룹챗 턴 결정 프롬프트 작성
  - God Agent에 decide_next_speakers 구현
  - JSON 파싱 및 에러 핸들링
- **verify:**
  - 단위 테스트 — 3명 캐릭터, 비밀 언급 시 아는 캐릭터만 선택
  - 로그로 reasoning 확인
- **done:** God Agent가 그룹챗에서 턴 순서를 동적으로 결정

#### Task 2.2: God Agent 그룹챗 지식 전파 (Knowledge Isolation)
- **type:** auto
- **files:**
  - `backend/app/core/god_agent.py` (수정) — `observe_and_update_group` 메서드 추가
    - 입력: scenario, speaker_character, assistant_response, present_characters[]
    - 동작:
      1. 대화에서 새 정보 추출 (기존 observe_and_update와 유사)
      2. **차이점:** 정보를 들은 캐릭터 = present_characters (그룹에 참여한 사람들)
      3. present_characters 전원의 known_facts에 추가
      4. 그룹에 없는 캐릭터는 업데이트 안 함 (지식 격리)
      5. speaker의 inner_thoughts는 **다른 캐릭터가 알 수 없음** (private)
- **action:**
  - observe_and_update_group 구현
  - 그룹 참여자 전원에게 지식 전파
  - inner_thoughts는 speaker만 업데이트
- **verify:**
  - 단위 테스트 — A, B, C 그룹챗에서 A 발언 → B, C도 known_facts 업데이트
  - D (그룹 밖)는 업데이트 안됨 확인
  - inner_thoughts는 A만 업데이트 확인
- **done:** 그룹챗에서 지식이 참여자에게만 전파됨 (Phase 3 핵심!)

---

## Wave 3: Group Chat API & Streaming

### Plan 03: Group Chat Endpoints

#### Task 3.1: Group Conversation CRUD
- **type:** auto
- **files:**
  - `backend/app/services/chat_service.py` (수정) — 그룹챗 서비스 추가
    - `async create_group_conversation(db, user_id, scenario_id, character_ids, title) -> Conversation`
      - is_group=True로 생성
      - GroupConversationParticipant 레코드 생성 (각 캐릭터)
    - `async get_group_participants(db, conversation_id) -> list[Character]`
      - 그룹 참여 캐릭터 목록 조회
  - `backend/app/api/v1/group_chat.py` (신규) — 그룹챗 라우터
    - `POST /api/v1/group-chat` — 그룹 대화 생성
      - 요청: GroupChatCreateRequest (scenario_id, character_ids[], title)
      - 응답: ConversationResponse
    - `GET /api/v1/group-chat/{conversation_id}/participants` — 참여자 목록
  - `backend/app/main.py` (수정) — group_chat 라우터 등록
- **action:**
  - 그룹 대화 생성 로직 구현
  - 라우터 추가 및 등록
- **verify:**
  - `POST /api/v1/group-chat` → 201, 그룹 대화 생성
  - `GET /participants` → 캐릭터 목록 반환
- **done:** 그룹 대화 생성 및 조회 가능

#### Task 3.2: Group Chat Streaming Endpoint
- **type:** auto
- **files:**
  - `backend/app/api/v1/group_chat.py` (수정) — 그룹챗 스트리밍 엔드포인트
    - `POST /api/v1/group-chat/{conversation_id}/message` — 유저 메시지 전송
      - 요청: GroupChatMessageRequest (message)
      - 응답: SSE 스트림
        - 각 캐릭터 응답을 순차적으로 스트리밍
        - 이벤트 포맷: `data: {"character_id": "...", "character_name": "...", "chunk": "...", "is_done": false}\n\n`
        - 모든 캐릭터 응답 완료 후: `data: {"is_done": true}\n\n`
  - `backend/app/services/chat_service.py` (수정) — 그룹챗 스트리밍 로직
    - `async stream_group_chat(db, conversation_id, user_message, user_id) -> AsyncGenerator`
      - God Agent decide_next_speakers 호출
      - 각 선택된 캐릭터에 대해:
        1. God Agent brief_character (with knowledge filtering)
        2. Character Agent 응답 생성 (streaming)
        3. 응답 저장 (character_id 포함)
        4. God Agent observe_and_update_group (백그라운드)
      - 각 캐릭터 응답을 SSE로 스트리밍
- **action:**
  - 그룹챗 스트리밍 파이프라인 구현
  - God Agent 턴 결정 + 브리핑 + 업데이트 통합
  - SSE 이벤트 포맷 구현 (character_id 포함)
- **verify:**
  - curl로 그룹챗 메시지 전송
  - SSE 스트림에서 각 캐릭터 응답 확인
  - character_id로 누가 말했는지 구분 가능
- **done:** 그룹챗 스트리밍 API 완성

---

## Wave 4: Integration & Testing

### Plan 04: End-to-End Testing & Verification

#### Task 4.1: Phase 3 Success Criteria Test
- **type:** manual
- **test scenario:**
  1. 시나리오 생성 ("비밀 테스트")
  2. 캐릭터 3명 생성 (Alice, Bob, Charlie)
  3. Alice와 Bob을 시나리오에 추가
  4. Alice와 1:1 대화: "Bob, 내일 놀라운 일이 일어날 거야. 이건 비밀이야." (비밀 공유)
  5. God Agent가 Alice의 지식에 "내일 놀라운 일" 추가 확인
  6. 그룹 대화 생성: Alice, Bob, Charlie
  7. 유저: "내일 무슨 일이 있을까?"
  8. 예상 결과:
     - God Agent가 Alice, Bob만 응답하도록 선택 (Charlie는 비밀 모름)
     - Alice, Bob이 비밀에 대해 반응
     - Charlie는 응답 안 함 or "모르겠어요"
- **verify:**
  - God Agent가 지식 상태 기반으로 턴 결정
  - 비밀 아는 캐릭터만 응답 생성
  - Charlie는 비밀 언급 안 함
- **done:** Phase 3 성공 기준 달성!

#### Task 4.2: Server Health Check & Commit
- **type:** auto
- **action:**
  - Alembic 마이그레이션 실행
  - 서버 시작 테스트
  - Health check 확인
  - Git commit
- **verify:**
  - `poetry run alembic upgrade head` 성공
  - `uvicorn app.main:app` 실행 성공
  - `/health` 엔드포인트 200 OK
- **done:** Phase 3 구현 완료, 커밋 준비

---

## 요약

| Wave | Plan | Tasks | 설명 | 의존성 |
|------|------|-------|------|--------|
| **1** | 01: Group Chat Data Model | 1.1, 1.2 | 그룹 대화 모델 & 스키마 | Phase 2 완료 |
| **2** | 02: Turn Orchestration & Knowledge Isolation | 2.1, 2.2 | God Agent 턴 결정 & 지식 격리 | Wave 1 완료 |
| **3** | 03: Group Chat API | 3.1, 3.2 | 그룹챗 엔드포인트 & 스트리밍 | Wave 2 완료 |
| **4** | 04: Testing & Verification | 4.1, 4.2 | E2E 테스트 & 커밋 | Wave 3 완료 |

**총 Task 수:** 8개 (4 Plans × 2 Tasks)  
**예상 실행:** Wave별 순차 실행

---

## Architecture Flow (Phase 3 완료 후)

```
유저 메시지 수신 (그룹챗)
    │
    ▼
God Agent: decide_next_speakers()
    │ (누가 응답할지 결정 — 지식 기반)
    ▼
for each responding_character:
    │
    ▼
  God Agent: brief_character()
    │ (지식 필터링 브리핑)
    ▼
  Character Agent (Claude Sonnet) 응답 생성
    │
    ▼
  SSE 스트리밍 (character_id 포함)
    │
    ▼
  메시지 저장 (character_id 포함)
    │
    ▼
  God Agent: observe_and_update_group() [백그라운드]
    │ (그룹 참여자 전원에게 지식 전파)
    ▼
next character
    │
    ▼
모든 캐릭터 응답 완료
    │
    ▼
SSE 종료 (is_done: true)
```

---

## Key Features (Phase 3)

1. **턴 기반 오케스트레이션** — God Agent가 맥락 기반으로 누가 말할지 결정
2. **지식 격리** — 그룹에 참여한 캐릭터만 정보를 공유
3. **다중 캐릭터 스트리밍** — SSE로 각 캐릭터 응답을 순차 전송
4. **Character-aware messaging** — 메시지에 character_id 포함으로 UI에서 구분 가능

---

## Differences from 1:1 Chat

| Feature | 1:1 Chat | Group Chat |
|---------|----------|------------|
| **Conversation Model** | is_group=False | is_group=True + participants |
| **Message Model** | character_id=NULL (암묵적) | character_id 명시 |
| **Turn Decision** | 단일 캐릭터 (고정) | God Agent가 동적 결정 |
| **Briefing** | 1번 (단일 캐릭터) | N번 (각 응답 캐릭터) |
| **Knowledge Update** | 1명 업데이트 | 그룹 전원 업데이트 |
| **SSE Format** | 단순 텍스트 청크 | JSON (character_id 포함) |

---

## Migration Strategy

기존 1:1 채팅은 그대로 유지 (is_group=False). 그룹챗은 별도 엔드포인트 (`/api/v1/group-chat`)로 분리하여 기존 기능과 충돌 방지.

---

## LLM Cost Optimization

- God Agent (턴 결정): GPT-4o-mini (저렴, 빠름)
- God Agent (브리핑): GPT-4o-mini
- Character Agents: Claude Sonnet (고품질)
- 그룹챗에서 N명 캐릭터 응답 시 비용 = God Agent (턴 결정 1회) + God Agent (브리핑 N회) + Claude (응답 N회)
- 최적화: 동시 응답 캐릭터 수 제한 (기본 1-2명, 최대 3명)
