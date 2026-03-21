# Muse Frontend

AI 캐릭터 롤플레이 챗 앱의 Flutter 프론트엔드.

## Navigation (BottomNav 4탭)

```
BottomNavigationBar
├── 채팅 (/conversations) — 홈, 대화 기록
├── 캐릭터 (/characters) — 캐릭터 목록
├── 스토리 (/scenarios) — 시나리오 목록, 인라인 채팅 생성
└── 설정 (/profile) — 페르소나, 테마, 로그아웃
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/core/router/app_router.dart` | GoRouter (StatefulShellRoute) |
| `lib/presentation/screens/main_shell.dart` | BottomNav Shell |
| `lib/presentation/screens/profile/profile_screen.dart` | 설정 탭 (페르소나 인라인) |
| `lib/presentation/screens/scenario_list/scenario_list_screen.dart` | 스토리 카드 + 채팅 생성 바텀시트 |
| `lib/presentation/screens/conversation_list/conversation_list_screen.dart` | 채팅 목록 (캐릭터별 그룹핑) |
| `lib/core/constants/app_constants.dart` | API URL, resolveAvatarUrl() |
| `lib/data/models/*.dart` | freezed 데이터 모델 |
| `lib/data/providers/*.dart` | Riverpod providers |

## Build

```bash
# 개발 실행 (에뮬레이터)
flutter run -d emulator-5554

# Oracle Cloud 서버용 APK
flutter build apk --release --dart-define=API_URL=http://158.180.83.142:8000

# 로컬 서버용 APK (에뮬레이터)
flutter build apk --release

# freezed 코드 생성
dart run build_runner build --delete-conflicting-outputs
```

## App Info
- **Package**: kr.muse.muse
- **Icon**: 보라 그라데이션 + 채팅 버블 + M
- **캐시 삭제**: `adb shell pm clear kr.muse.muse`

## Changelog

### 2026-03-21: UI/UX Refactor + Oracle Cloud 배포
- Drawer → BottomNavigationBar 4탭 (채팅/캐릭터/스토리/설정)
- GoRouter StatefulShellRoute 도입
- 대화 목록을 홈 탭으로 승격, 캐릭터별 그룹핑
- 시나리오: 카드 UI + 상세 바텀시트에서 인라인 채팅 생성
- 설정 탭에 페르소나 인라인 관리 통합
- 공용/개인 컨텐츠 구분 (is_public, is_mine)
- 캐릭터 아바타 로컬 서버 저장 (60개)
- Material 3 스트레치 → Glow 오버스크롤
- Back Navigation 수정 (go → push)
- 새 앱 아이콘 (보라+채팅버블+M)
- FAB 워딩: "캐릭터와 대화하기" / "시나리오 플레이"
- 대화 섹션: "시나리오 캐릭터 대화" / "이전 캐릭터와 대화"
- 버그 수정: 시나리오 에러, 입력창 확장, 아바타 "AI" 표시
- Oracle Cloud 배포 (158.180.83.142:8000)
- 신규 컨텐츠: 프리파라, 프리렌(힘멜/하이터/아이젠/자인), 아이카츠 원작명
