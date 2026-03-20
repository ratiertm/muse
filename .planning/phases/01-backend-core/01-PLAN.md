# Phase 1: 백엔드 코어 — 실행 계획

**Goal:** API 서버가 캐릭터 생성하고 채팅 응답을 스트리밍할 수 있다  
**Success Criteria:** curl로 캐릭터 만들고 채팅 응답이 SSE 스트리밍으로 온다

---

## Wave 1: 기반 인프라

### Plan 01: Project Setup & DB Schema

#### Task 1.1: FastAPI 프로젝트 구조 생성
- **type:** auto
- **files:**
  - `backend/pyproject.toml` — Poetry 프로젝트 설정 (FastAPI, uvicorn, sqlalchemy[asyncio], asyncpg, alembic, pydantic-settings, sse-starlette, litellm)
  - `backend/app/__init__.py`
  - `backend/app/main.py` — FastAPI 앱 인스턴스, CORS, 라우터 등록
  - `backend/app/config.py` — pydantic-settings 기반 설정 (DB URL, API 키, 환경변수)
  - `backend/app/dependencies.py` — DB 세션 DI
  - `backend/app/db/database.py` — async SQLAlchemy 엔진, 세션팩토리
  - `backend/docker-compose.yml` — PostgreSQL 16 컨테이너
  - `backend/.env.example` — 환경변수 템플릿
  - `backend/Dockerfile` — Python 3.12 기반
- **action:** Poetry init, FastAPI 앱 스켈레톤, docker-compose로 PostgreSQL 기동
- **verify:** `docker compose up -d && poetry run uvicorn app.main:app --reload` → `GET /health` 200 OK
- **done:** FastAPI 서버가 PostgreSQL에 연결된 상태로 구동됨

#### Task 1.2: SQLAlchemy 모델 & Alembic 마이그레이션
- **type:** auto
- **files:**
  - `backend/app/models/__init__.py`
  - `backend/app/models/user.py` — User (id, name, pin_hash, avatar_url, created_at)
  - `backend/app/models/character.py` — Character (id, user_id FK, name, personality, speech_style, backstory, scenario, first_message, example_dialogue, tags JSON, avatar_url, model_preference, created_at, updated_at)
  - `backend/app/models/conversation.py` — Conversation (id, user_id FK, character_id FK, title, created_at, updated_at)
  - `backend/app/models/message.py` — Message (id, conversation_id FK, role enum[user/assistant/system], content, token_count, created_at)
  - `backend/alembic.ini`
  - `backend/alembic/env.py`
  - `backend/alembic/versions/001_initial.py`
- **action:** SQLAlchemy 모델 정의, Alembic 초기화, 마이그레이션 생성 및 적용
- **verify:** `alembic upgrade head` 성공 → DB에 users, characters, conversations, messages 테이블 존재
- **done:** 모든 테이블이 PostgreSQL에 생성됨

---

## Wave 2: CRUD & LLM (독립적, 병렬 가능)

### Plan 02: Character CRUD API

#### Task 2.1: Pydantic 스키마 & CRUD 엔드포인트
- **type:** auto
- **files:**
  - `backend/app/schemas/__init__.py`
  - `backend/app/schemas/character.py` — CharacterCreate, CharacterUpdate, CharacterResponse (name, personality, speech_style, backstory, scenario, first_message, example_dialogue, tags)
  - `backend/app/api/__init__.py`
  - `backend/app/api/v1/__init__.py`
  - `backend/app/api/v1/characters.py` — POST/GET(list)/GET(detail)/PUT/DELETE /api/v1/characters
  - `backend/app/services/character_service.py` — CRUD 비즈니스 로직
- **action:** Pydantic v2 스키마 정의, 비동기 CRUD 구현, 라우터 등록
- **verify:**
  - `POST /api/v1/characters` → 201 + 캐릭터 생성됨
  - `GET /api/v1/characters` → 목록 반환
  - `GET /api/v1/characters/{id}` → 상세 반환
  - `PUT /api/v1/characters/{id}` → 수정됨
  - `DELETE /api/v1/characters/{id}` → 삭제됨
- **done:** 캐릭터 CRUD가 curl로 동작

#### Task 2.2: 캐릭터 목록 필터링 & 페이지네이션
- **type:** auto
- **files:**
  - `backend/app/schemas/common.py` — PaginationParams, PaginatedResponse
  - `backend/app/api/v1/characters.py` (수정) — query params (tags, search, page, per_page)
- **action:** 태그 필터, 이름 검색, offset 페이지네이션 추가
- **verify:** `GET /api/v1/characters?tags=anime&page=1&per_page=10` → 필터링된 결과
- **done:** 목록 API에 필터/페이지네이션 동작

### Plan 03: LLM Integration

#### Task 3.1: litellm 클라이언트 & 프롬프트 빌더
- **type:** auto
- **files:**
  - `backend/app/core/__init__.py`
  - `backend/app/core/llm_client.py` — litellm 래퍼 (completion, acompletion, stream). 모델: gpt-4o-mini, claude-sonnet-4-20250514
  - `backend/app/core/prompt_builder.py` — 캐릭터 카드 → system prompt 조립 (시스템 지시 + 캐릭터 정보 + 유저 페르소나 + 예시 대화)
- **action:** litellm 비동기 호출 래퍼 구현, 캐릭터 카드 기반 프롬프트 템플릿 작성
- **verify:** 단위 테스트 — 프롬프트 빌더 출력 검증, litellm mock 호출 성공
- **done:** 캐릭터 카드로부터 프롬프트 조립 & LLM 호출 가능

#### Task 3.2: SSE 스트리밍 엔드포인트 (테스트용)
- **type:** auto
- **files:**
  - `backend/app/api/v1/chat.py` — `POST /api/v1/chat/test-stream` (캐릭터 ID + 메시지 → SSE 스트리밍 응답)
- **action:** sse-starlette 기반 EventSourceResponse, litellm 스트리밍 연동
- **verify:** `curl -N -X POST /api/v1/chat/test-stream -d '{"character_id":1,"message":"안녕"}' ` → SSE 이벤트 수신
- **done:** LLM 응답이 SSE로 스트리밍됨

---

## Wave 3: 채팅 & 인증 (Wave 1+2 의존)

### Plan 04: Chat API

#### Task 4.1: 대화 생성 & 메시지 저장
- **type:** auto
- **files:**
  - `backend/app/schemas/chat.py` — ChatRequest, ChatMessageResponse, ConversationResponse
  - `backend/app/services/chat_service.py` — 대화 생성, 메시지 저장, 히스토리 조회
  - `backend/app/api/v1/conversations.py` — GET /api/v1/conversations (목록), GET /api/v1/conversations/{id}/messages (히스토리)
- **action:** Conversation & Message CRUD, 대화 히스토리 페이지네이션
- **verify:**
  - 대화 생성 → messages 테이블에 저장됨
  - `GET /conversations/{id}/messages` → 메시지 목록 반환
- **done:** 대화 기록 저장 & 조회 동작

#### Task 4.2: 채팅 스트리밍 + 컨텍스트 관리
- **type:** auto
- **files:**
  - `backend/app/api/v1/chat.py` (수정) — `POST /api/v1/chat` (conversation_id + message → SSE 스트리밍, 자동 저장)
  - `backend/app/core/context_manager.py` — 슬라이딩 윈도우 (max_tokens 기반, 최근 N개 메시지 선택, 영구 토큰 보존)
- **action:**
  - 유저 메시지 저장 → 컨텍스트 조립 (프롬프트 빌더 + 슬라이딩 윈도우) → LLM 스트리밍 → 어시스턴트 메시지 저장
  - 첫 메시지 시 Conversation 자동 생성 & 캐릭터 first_message 삽입
- **verify:**
  - `POST /api/v1/chat` → SSE 스트리밍 응답 + DB에 양쪽 메시지 저장
  - 30개 이상 메시지 후에도 컨텍스트 윈도우 내에서 정상 동작
- **done:** 1:1 채팅이 스트리밍으로 동작하며 히스토리 관리됨

### Plan 05: Auth & User

#### Task 5.1: 유저 CRUD & PIN 인증
- **type:** auto
- **files:**
  - `backend/app/schemas/user.py` — UserCreate (name, pin), UserResponse, LoginRequest
  - `backend/app/api/v1/users.py` — POST /api/v1/users (생성), POST /api/v1/auth/login (PIN → JWT 토큰)
  - `backend/app/core/auth.py` — PIN 해싱 (bcrypt), JWT 토큰 발급/검증, get_current_user 의존성
- **action:** 유저 생성, PIN 로그인 → JWT 발급, 토큰 기반 인증 미들웨어
- **verify:**
  - `POST /api/v1/users` → 유저 생성
  - `POST /api/v1/auth/login {"name":"딸","pin":"1234"}` → JWT 토큰 반환
  - Authorization 헤더 없이 요청 → 401
- **done:** PIN 로그인 & JWT 인증 동작

#### Task 5.2: 유저별 데이터 격리 적용
- **type:** auto
- **files:**
  - `backend/app/api/v1/characters.py` (수정) — user_id 필터 추가
  - `backend/app/api/v1/conversations.py` (수정) — user_id 필터 추가
  - `backend/app/api/v1/chat.py` (수정) — user_id 검증
  - `backend/app/dependencies.py` (수정) — get_current_user 의존성 주입
- **action:** 모든 API에 현재 유저 기준 필터링 적용. 다른 유저의 캐릭터/대화 접근 차단
- **verify:**
  - 유저 A의 토큰으로 유저 B의 캐릭터 조회 → 빈 목록 또는 403
  - 유저 A의 토큰으로 유저 A의 데이터만 반환됨
- **done:** 유저별 완전한 데이터 격리

---

## 요약

| Wave | Plan | Tasks | 설명 |
|------|------|-------|------|
| **1** | 01: Setup & DB | 1.1, 1.2 | 프로젝트 구조, DB 스키마 |
| **2** | 02: Character CRUD | 2.1, 2.2 | 캐릭터 API (Wave 1 완료 후) |
| **2** | 03: LLM Integration | 3.1, 3.2 | LLM 연동 & 스트리밍 (Wave 1 완료 후, Plan 02와 병렬) |
| **3** | 04: Chat API | 4.1, 4.2 | 채팅 API (Plan 02+03 완료 후) |
| **3** | 05: Auth & User | 5.1, 5.2 | 인증 & 격리 (Plan 02 완료 후) |

**총 Task 수:** 10개 (5 Plans × 2 Tasks)  
**예상 실행:** Wave별 순차, Wave 내 Plan은 병렬 가능
