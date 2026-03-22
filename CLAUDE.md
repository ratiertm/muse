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

## Architecture Decision Records
의사결정 맥락은 `docs/decisions/`에 기록. 새 세션에서 "왜 이렇게 했는지" 파악 시 참조.
- ADR-001: Drawer → BottomNav 4탭 전환
- ADR-002: Claude CLI OAuth 사용 (API 키 대신)
- ADR-003: 로컬 아바타 저장 (CDN 대신)
- ADR-004: God Agent 그룹 채팅 패턴
- ADR-005: Oracle Cloud 1GB 배포 전략
- ADR-006: 시나리오 바텀시트 인라인 채팅 생성
- ADR-007: 대화 목록 캐릭터별 그룹핑
- ADR-008: 캐릭터 말투 충실도 (speech_style + example_dialogue)

## Retrospectives
Phase 완료 시 반드시 `docs/retrospectives/`에 회고 기록. 템플릿: `docs/templates/RETROSPECTIVE.md`
- **ui-refactor** (2026-03-22): [회고](docs/retrospectives/ui-refactor-2026-03-22.md)
  - 핵심 교훈: 이미지 검색은 영문 필수, release APK는 실네트워크 테스트, Material 3 기본값 확인

## Development Lifecycle Rules
아래 규칙은 GSD/PDCA/ADR/회고 스킬 간 연동을 보장한다. 재작업을 줄이기 위한 체크포인트.

### Phase 완료 시 (필수)
1. `/gsd:verify-work` → 구현 검증
2. `/gsd-retrospective` → 회고 작성 (배운 것 + 실수 + 교훈)
3. ADR 누락 체크 → 회고에서 발견된 미기록 결정은 `/adr`로 생성
4. CLAUDE.md 업데이트 → ADR 목록, 회고 링크, PDCA History 추가

### 결정 시점 (자동)
- "A 대신 B로 하자" 같은 트레이드오프 → `/adr` 자동 트리거
- ADR 생성 → 코드에 WHY+SEE 주석 자동 삽입

### Phase 시작 전 (필수)
- 이전 Phase 회고의 "Lessons for Next Phase" 확인
- 관련 ADR 읽기 → 같은 실수 반복 방지

### PDCA 연동
- Plan → GSD plan-phase와 동기화
- Do → GSD execute-phase
- Check → `/gsd:verify-work` + `/pdca analyze`
- Act → gap 있으면 수정, 완료면 → 회고 + ADR 체크

## PDCA History
- **ui-refactor** (2026-03-21~22): Drawer→BottomNav 4탭, GoRouter StatefulShellRoute, 시나리오 카드UI+인라인 채팅생성, 대화 그룹핑, 공용/개인 구분, 아바타 로컬 저장, Oracle Cloud 배포
