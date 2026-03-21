# Muse - AI Character Chat App

## Project Overview
애니메이션/만화/소설 캐릭터와 대화할 수 있는 롤플레이 챗 앱.
가족 단위(부모+딸) 사용을 위한 멀티프로필 지원.

## Tech Stack
- **Frontend**: Flutter (Dart), Riverpod, GoRouter, freezed
- **Backend**: FastAPI (Python), SQLAlchemy, PostgreSQL, LiteLLM
- **LLM**: Claude Sonnet (그룹채팅), GPT-4o-mini (캐릭터 생성)

## Architecture

### Frontend Navigation (2026-03-21 UI Refactor)
```
BottomNavigationBar (4 tabs):
  Tab 1: /conversations (대화 목록 - Home)
  Tab 2: /characters (캐릭터)
  Tab 3: /scenarios (시나리오)
  Tab 4: /profile (내 정보)

Full-screen routes (outside shell):
  /chat/:characterId
  /group-chat/:conversationId
  /group/create
  /profile-selection, /pin-auth
```

### Backend API Structure
```
/api/v1/auth/     - PIN 인증, JWT
/api/v1/characters/ - 캐릭터 CRUD + 자동생성
/api/v1/scenarios/  - 시나리오 CRUD + 자동생성
/api/v1/chat/       - 1:1 채팅 (스트리밍)
/api/v1/group-chat/ - 그룹 채팅 (God Agent)
/api/v1/conversations/ - 대화 목록
/api/v1/personas/   - 유저 페르소나
```

## Key Design Decisions

### Public/Private Content (2026-03-21)
- `is_public` 플래그로 공용/개인 구분
- 공용: 모든 유저 조회 가능, 수정/삭제는 소유자만
- 개인: 소유자만 조회/수정/삭제
- 기존 데이터는 모두 공용으로 마킹

### Scenario-Character Ownership
- 시나리오와 캐릭터는 독립적으로 소유
- `scenario_characters` junction table로 연결
- 시나리오 삭제 시 대화는 보존 (`passive_deletes=True`)

## Development Notes
- Flutter freezed 모델 변경 시: `dart run build_runner build --delete-conflicting-outputs`
- Backend 서버: `cd backend && uvicorn app.main:app --reload --port 8000`
- DB: PostgreSQL (charbot:charbot@localhost:5432/charbot)

## PDCA History
- **ui-refactor** (2026-03-21): Drawer→BottomNav, 뒤로가기 수정, 로그아웃 동선 개선
