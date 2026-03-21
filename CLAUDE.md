# Muse - AI Character Chat App

## Project Overview
애니메이션/만화/소설 캐릭터와 대화할 수 있는 롤플레이 챗 앱.
가족 단위(부모+딸) 사용을 위한 멀티프로필 지원.

## Tech Stack
- **Frontend**: Flutter (Dart), Riverpod, GoRouter (StatefulShellRoute), freezed
- **Backend**: FastAPI (Python 3.12), SQLAlchemy, PostgreSQL, Claude CLI
- **LLM**: Claude Sonnet (대화), Claude Haiku (자동생성) — `claude -p` CLI OAuth
- **Infra**: Oracle Cloud (x86_64, 512MB RAM + 4GB swap)

## Architecture

### Frontend Navigation
```
BottomNavigationBar (4 tabs):
  Tab 1: /conversations (채팅 - Home)
  Tab 2: /characters (캐릭터)
  Tab 3: /scenarios (스토리)
  Tab 4: /profile (설정)

Full-screen routes (outside shell):
  /chat/:characterId
  /group-chat/:conversationId
  /group/create
  /profile-selection, /pin-auth
```

### Backend API
```
/api/v1/auth/         - PIN 인증, JWT
/api/v1/characters/   - 캐릭터 CRUD + 자동생성
/api/v1/scenarios/    - 시나리오 CRUD + 자동생성 (purpose, character_avatars 포함)
/api/v1/chat/         - 1:1 채팅 (스트리밍)
/api/v1/group-chat/   - 그룹 채팅 (God Agent)
/api/v1/conversations/- 대화 목록
/api/v1/personas/     - 유저 페르소나
/static/avatars/      - 캐릭터 아바타 이미지 (로컬 저장)
```

### LLM Model Mapping (USE_CLAUDE_CLI=True)
| 요청 모델 | CLI 매핑 | 용도 |
|-----------|---------|------|
| claude-sonnet-4 | sonnet | 1:1/그룹 채팅 |
| gpt-4o-mini, haiku | haiku | 캐릭터/시나리오 자동생성 |

## Server (Oracle Cloud)
- **IP**: 158.180.83.142:8000
- **OS**: Oracle Linux 9.7 (x86_64)
- **Service**: systemd `muse.service`
- **DB**: PostgreSQL (muse:muse2026!@localhost:5432/muse)
- **Code**: /home/opc/muse-backend
- **Python**: 3.12 (venv)
- **Claude CLI**: OAuth 인증, `claude -p` 사용
- **SELinux**: Enforcing (venv bin에 `bin_t` context 설정 필요)

### 서버 관리 명령어
```bash
# SSH 접속
ssh -i "oracle ssh keys/ssh-key-2026-02-06_v4.0.key" opc@158.180.83.142

# 서비스 관리
sudo systemctl status muse
sudo systemctl restart muse
sudo journalctl -u muse -f

# 코드 업데이트 (로컬에서)
rsync -avz --exclude='.venv' --exclude='__pycache__' \
  -e 'ssh -i "oracle ssh keys/ssh-key-2026-02-06_v4.0.key"' \
  backend/ opc@158.180.83.142:/home/opc/muse-backend/

# APK 빌드 (Oracle Cloud 서버용)
flutter build apk --release --dart-define=API_URL=http://158.180.83.142:8000
```

## Key Design Decisions

### Public/Private Content
- `is_public` 플래그로 공용/개인 구분
- 공용: 모든 유저 조회 가능, 수정/삭제는 소유자만
- 개인: 소유자만 조회/수정/삭제

### Character Avatars (로컬 저장)
- MAL CDN URL 만료 → Jikan API로 정확한 이미지 다운로드
- `backend/static/avatars/{character_id}.jpg` 에 저장
- FastAPI StaticFiles로 서빙
- 프론트: `AppConstants.resolveAvatarUrl()` 로 상대경로→절대URL 변환

### Scenario Design
- `purpose` 필드: 시나리오의 목적/목표
- `character_avatars`: 시나리오 API 응답에 캐릭터 정보 포함
- 시나리오 탭 → 상세 바텀시트에서 채팅방 이름/페르소나/캐릭터 선택 → 바로 시작
- 대화 목록: 같은 캐릭터 대화는 그룹핑하여 최신 1건만 표시

### Overscroll Effect
- Material 3 스트레치 → GlowingOverscrollIndicator로 교체 (app.dart)

## Development Notes
- Flutter freezed 모델 변경 시: `dart run build_runner build --delete-conflicting-outputs`
- 로컬 Backend: `cd backend && uvicorn app.main:app --reload --port 8000`
- 로컬 DB: PostgreSQL (charbot:charbot@localhost:5432/charbot)
- Android 빌드 시 gradle.properties에 `org.gradle.java.home` 설정 필요
- 앱 캐시 삭제: `adb shell pm clear kr.muse.muse`

## Content
- 유저: 2명 (MB, 딸) — PIN: 1234
- 캐릭터: 60개 (헌터x헌터, 귀멸, 슬램덩크, 드래곤볼, 원피스, 나루토, 죠죠, 은하철도999, 전독시, 프리렌, 프리파라, 아이카츠)
- 시나리오: 13개
- 페르소나: 3개

## PDCA History
- **ui-refactor** (2026-03-21): Drawer→BottomNav 4탭, GoRouter StatefulShellRoute, 시나리오 카드UI+인라인 채팅생성, 대화 그룹핑, 공용/개인 구분, 아바타 로컬 저장, Oracle Cloud 배포
