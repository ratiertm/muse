# Phase 2: God Agent — 실행 계획

**Goal:** 전지적 오케스트레이터가 세계 상태를 관리하고 캐릭터에게 브리핑한다  
**Success Criteria:** 같은 시나리오에서 캐릭터 A와 대화한 내용이 캐릭터 B 브리핑에 반영된다

---

## Wave 1: 데이터 모델 & 상태 관리

### Plan 01: Scenario API & World State Schema

#### Task 1.1: Scenario CRUD API 구현
- **type:** auto
- **files:**
  - `backend/app/schemas/scenario.py` — ScenarioCreate, ScenarioUpdate, ScenarioResponse, WorldStateUpdate
    - name, description 필수
    - world_state JSON: `{timeline: str, location: str, current_time: str, active_events: [str], world_facts: [str]}`
  - `backend/app/services/scenario_service.py` — 시나리오 CRUD + world_state 업데이트 로직
  - `backend/app/api/v1/scenarios.py` — 라우터
    - `POST /api/v1/scenarios` — 시나리오 생성
    - `GET /api/v1/scenarios` — 목록 (user_id 필터)
    - `GET /api/v1/scenarios/{id}` — 상세
    - `PUT /api/v1/scenarios/{id}` — 수정
    - `PATCH /api/v1/scenarios/{id}/world-state` — world_state만 부분 업데이트
    - `DELETE /api/v1/scenarios/{id}` — 삭제
  - `backend/app/main.py` (수정) — scenarios 라우터 등록
- **action:** Pydantic 스키마 정의, 시나리오 CRUD 비즈니스 로직, FastAPI 라우터 구현
- **verify:**
  - `POST /api/v1/scenarios` → 201, world_state 기본값 `{}`로 생성
  - `PATCH /scenarios/{id}/world-state` → world_state 부분 업데이트 성공
  - `GET /scenarios` → 유저별 목록 필터링
- **done:** 시나리오 CRUD API가 동작하고 world_state를 관리할 수 있음

#### Task 1.2: ScenarioCharacter 연결 테이블 & API
- **type:** auto
- **files:**
  - `backend/app/models/scenario_character.py` — ScenarioCharacter 모델
    - id (PK)
    - scenario_id (FK to scenarios)
    - character_id (FK to characters)
    - created_at
    - 복합 유니크 제약: (scenario_id, character_id)
  - `backend/app/schemas/scenario.py` (수정) — ScenarioCharacterAdd, CharacterInScenarioResponse
  - `backend/app/services/scenario_service.py` (수정) — 캐릭터 추가/제거 로직
  - `backend/app/api/v1/scenarios.py` (수정) — 엔드포인트 추가
    - `POST /api/v1/scenarios/{id}/characters` — 캐릭터 추가 (character_id)
    - `GET /api/v1/scenarios/{id}/characters` — 시나리오 내 캐릭터 목록
    - `DELETE /api/v1/scenarios/{id}/characters/{character_id}` — 캐릭터 제거
  - `backend/alembic/versions/00X_scenario_characters.py` — 마이그레이션
- **action:** ScenarioCharacter 모델 생성, 마이그레이션, API 구현
- **verify:**
  - `POST /scenarios/{id}/characters` → 캐릭터 추가됨, 중복 방지
  - `GET /scenarios/{id}/characters` → 캐릭터 목록 반환
  - `DELETE /scenarios/{id}/characters/{cid}` → 제거됨
- **done:** 시나리오에 캐릭터를 할당하고 조회할 수 있음

---

### Plan 02: Knowledge Graph & Private State

#### Task 2.1: CharacterKnowledge 모델 & 서비스
- **type:** auto
- **files:**
  - `backend/app/models/character_knowledge.py` — CharacterKnowledge 모델
    - id (PK)
    - character_id (FK to characters)
    - scenario_id (FK to scenarios)
    - known_facts (JSON array) — 캐릭터가 아는 사실들
    - unknown_facts (JSON array) — 캐릭터가 모르는 사실들 (God Agent만 앎)
    - created_at, updated_at
    - 복합 유니크: (character_id, scenario_id)
  - `backend/app/schemas/knowledge.py` — KnowledgeResponse, KnowledgeUpdate
  - `backend/app/services/knowledge_service.py` — CRUD
    - `get_or_create_knowledge(character_id, scenario_id)` → 없으면 빈 배열로 생성
    - `add_known_fact(character_id, scenario_id, fact: str)` → known_facts에 추가
    - `add_unknown_fact(...)` → unknown_facts에 추가
    - `move_to_known(character_id, scenario_id, fact: str)` → unknown → known 이동
  - `backend/alembic/versions/00X_character_knowledge.py` — 마이그레이션
- **action:** CharacterKnowledge 모델 생성, 마이그레이션, 서비스 로직 구현
- **verify:**
  - 단위 테스트 — `get_or_create_knowledge` 중복 생성 방지
  - `add_known_fact` → known_facts 배열에 추가됨
  - `move_to_known` → unknown_facts에서 제거되고 known_facts에 추가됨
- **done:** 캐릭터별 지식 그래프 저장 및 관리 가능

#### Task 2.2: CharacterPrivateState 모델 & 서비스
- **type:** auto
- **files:**
  - `backend/app/models/character_private_state.py` — CharacterPrivateState 모델
    - id (PK)
    - character_id (FK)
    - scenario_id (FK)
    - inner_thoughts (Text) — 캐릭터 속마음/현재 생각
    - feelings_toward (JSON) — `{character_name: sentiment, ...}` 감정 맵
    - secrets (JSON array) — 캐릭터만 아는 비밀들
    - created_at, updated_at
    - 복합 유니크: (character_id, scenario_id)
  - `backend/app/schemas/private_state.py` — PrivateStateResponse, PrivateStateUpdate
  - `backend/app/services/private_state_service.py` — CRUD
    - `get_or_create_state(character_id, scenario_id)`
    - `update_inner_thoughts(character_id, scenario_id, thoughts: str)`
    - `update_feeling(character_id, scenario_id, target: str, sentiment: str)`
    - `add_secret(character_id, scenario_id, secret: str)`
  - `backend/alembic/versions/00X_character_private_state.py` — 마이그레이션
- **action:** CharacterPrivateState 모델 생성, 마이그레이션, 서비스 구현
- **verify:**
  - 단위 테스트 — `update_inner_thoughts` 덮어쓰기 확인
  - `update_feeling` → feelings_toward 업데이트
  - `add_secret` → secrets 배열에 추가
- **done:** 캐릭터별 감정/비밀 상태 저장 및 업데이트 가능

---

## Wave 2: God Agent 핵심 로직

### Plan 03: God Agent Core — Briefing & Update

#### Task 3.1: God Agent 브리핑 생성
- **type:** auto
- **files:**
  - `backend/app/core/god_agent.py` — GodAgent 클래스
    - `__init__(llm_client, model="gpt-4o-mini")` — God Agent는 GPT-4o-mini 사용
    - `async brief_character(character, scenario, user_message, conversation_history=None) -> str` — 브리핑 생성
  - `backend/app/core/god_prompts.py` — God Agent 전용 프롬프트 템플릿
    - `BRIEFING_SYSTEM_PROMPT` — God Agent의 역할 정의 (전지적 시점 오케스트레이터)
    - `BRIEFING_TEMPLATE` — 브리핑 생성 프롬프트
      - 입력: world_state, character_knowledge, character_private_state, user_message, recent_history
      - 출력: 캐릭터에게 전달할 컨텍스트 브리핑 (무엇을 알고, 모르는지, 현재 감정 상태, 세계 상태)
- **action:**
  - God Agent 클래스 구현
  - 브리핑 프롬프트 작성 (캐릭터에게 "무엇을 알고 모르는지" 명시)
  - world_state, knowledge, private_state를 조합하여 브리핑 생성
- **verify:**
  - 단위 테스트 — mock 데이터로 브리핑 생성 확인
  - 브리핑에 known_facts 포함, unknown_facts 제외 확인
  - 브리핑에 inner_thoughts, feelings_toward 반영 확인
- **done:** God Agent가 캐릭터별 맞춤 브리핑 생성 가능

#### Task 3.2: God Agent 상태 업데이트 (이벤트 추출 & 지식 전파)
- **type:** auto
- **files:**
  - `backend/app/core/god_agent.py` (수정) — `async observe_and_update(...)` 메서드 추가
    - 입력: character, scenario, user_message, assistant_response
    - 동작:
      1. LLM으로 대화에서 새 이벤트 추출 (프롬프트: "이 대화에서 세계 상태에 추가할 사건이 있는가?")
      2. 추출된 이벤트를 world_state.active_events에 추가
      3. 캐릭터 지식 업데이트 (알게 된 새 사실을 known_facts에 추가)
      4. 감정 변화가 있다면 private_state 업데이트
  - `backend/app/core/god_prompts.py` (수정) — `UPDATE_SYSTEM_PROMPT`, `EVENT_EXTRACTION_TEMPLATE`
    - 입력: user_message, assistant_response, current_world_state
    - 출력: JSON `{new_events: [str], new_known_facts: [str], emotion_changes: {target: sentiment}}`
- **action:**
  - observe_and_update 구현 (이벤트 추출 → DB 업데이트)
  - JSON 응답 파싱 및 world_state, knowledge, private_state 업데이트
  - 에러 핸들링 (LLM 응답 파싱 실패 시 로깅, 무시)
- **verify:**
  - 단위 테스트 — "A가 B에게 비밀을 말했다" → new_events 추출 확인
  - 이벤트가 world_state에 추가됨
  - known_facts 업데이트됨
- **done:** God Agent가 대화 후 세계 상태를 자동 업데이트할 수 있음

---

## Wave 3: 채팅 파이프라인 통합

### Plan 04: Integration into Chat Pipeline

#### Task 4.1: 시나리오 기반 채팅 플로우 수정
- **type:** auto
- **files:**
  - `backend/app/services/chat_service.py` (수정) — 시나리오 인식 추가
    - `async stream_chat(conversation_id, user_message, user_id)` 수정
      - conversation에서 scenario_id 조회
      - scenario_id가 있으면 God Agent 플로우 사용
      - 없으면 기존 플로우 (Phase 1) 그대로
  - `backend/app/core/prompt_builder.py` (수정) — `build_system_prompt_with_briefing(character, briefing)` 추가
    - 기존 시스템 프롬프트 + God Agent 브리핑 조합
- **action:**
  - chat_service에 scenario_id 체크 로직 추가
  - 시나리오 활성화 시 God Agent 호출 플로우 구현:
    1. God Agent 브리핑 생성
    2. 브리핑을 시스템 프롬프트에 추가
    3. Character Agent(Claude Sonnet) 응답 생성
    4. God Agent observe_and_update 호출 (백그라운드)
- **verify:**
  - scenario_id 없는 대화 → 기존 플로우 동작 (Phase 1)
  - scenario_id 있는 대화 → God Agent 브리핑 적용 확인 (로그로 확인)
- **done:** 시나리오 유무에 따라 다른 플로우 동작

#### Task 4.2: 시나리오 인식 채팅 엔드포인트 & 지식 반영 검증
- **type:** auto
- **files:**
  - `backend/app/api/v1/chat.py` (수정) — `POST /api/v1/chat` 스키마 수정
    - 요청 body에 `scenario_id` optional 파라미터 추가
    - scenario_id가 있으면 conversation 생성/조회 시 scenario_id 연결
  - `backend/app/schemas/chat.py` (수정) — ChatRequest에 scenario_id 추가
- **action:**
  - chat 엔드포인트에 scenario_id 파라미터 처리
  - conversation 생성 시 scenario_id 저장
  - God Agent 업데이트를 백그라운드 태스크로 실행 (asyncio.create_task)
- **verify:**
  - **Success Test Case:**
    1. 시나리오 생성 (시나리오 A)
    2. 캐릭터 A, B를 시나리오 A에 추가
    3. 캐릭터 A와 대화: "내일 파티가 있어"
    4. God Agent가 "내일 파티" 이벤트를 world_state에 추가
    5. 캐릭터 B와 대화 시작 → 브리핑에 "시나리오의 최근 이벤트: 내일 파티" 포함 확인
    6. 캐릭터 B가 파티 관련 응답 생성 확인
  - 캐릭터 A와의 대화 내용이 캐릭터 B의 브리핑에 반영됨
- **done:** 같은 시나리오에서 캐릭터 간 지식 공유 동작 (Phase 2 성공 기준 달성!)

---

## 요약

| Wave | Plan | Tasks | 설명 | 의존성 |
|------|------|-------|------|--------|
| **1** | 01: Scenario & World State | 1.1, 1.2 | 시나리오 API, world_state 관리 | Phase 1 완료 |
| **1** | 02: Knowledge & Private State | 2.1, 2.2 | 지식 그래프, 감정/비밀 상태 | Phase 1 완료 (Plan 01과 병렬) |
| **2** | 03: God Agent Core | 3.1, 3.2 | 브리핑 생성, 상태 업데이트 | Wave 1 완료 |
| **3** | 04: Chat Integration | 4.1, 4.2 | 채팅 파이프라인 통합 | Wave 2 완료 |

**총 Task 수:** 8개 (4 Plans × 2 Tasks)  
**예상 실행:** Wave별 순차, Wave 1 내부는 병렬 가능

---

## Architecture Flow (Phase 2 완료 후)

```
유저 메시지 수신
    │
    ▼
scenario_id 체크 ──No──> 기존 플로우 (Phase 1)
    │ Yes
    ▼
God Agent: brief_character()
    │ (world_state + knowledge + private_state)
    ▼
브리핑 조립 (시스템 프롬프트 + 브리핑)
    │
    ▼
Character Agent (Claude Sonnet) 응답 생성
    │
    ▼
클라이언트에 SSE 스트리밍
    │
    ▼
God Agent: observe_and_update() [백그라운드]
    │ (이벤트 추출, 상태 업데이트)
    ▼
완료
```

---

## LLM 사용 분리

| 역할 | 모델 | 용도 | 비용 |
|-----|------|------|------|
| **God Agent** | GPT-4o-mini | 브리핑 생성, 이벤트 추출, 상태 업데이트 | 저렴, 빠름 |
| **Character Agent** | Claude Sonnet 4 | 캐릭터 응답 생성 | 고품질 |

**이유:** God Agent는 구조화된 출력 (JSON, 브리핑)을 생성하고 빠르게 동작해야 하므로 GPT-4o-mini 사용. 캐릭터 응답은 창의성과 롤플레이 품질이 중요하므로 Claude Sonnet 사용.
