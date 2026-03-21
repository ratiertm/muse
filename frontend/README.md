# Muse Frontend

AI 캐릭터 롤플레이 챗 앱의 Flutter 프론트엔드.

## Navigation Structure (v2 - BottomNav)

```
BottomNavigationBar (4 tabs)
├── 대화 (/conversations) - 홈
├── 캐릭터 (/characters)
├── 시나리오 (/scenarios)
└── 내 정보 (/profile)
    ├── 페르소나 관리
    ├── 테마/서버 설정
    └── 로그아웃/프로필 전환
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/core/router/app_router.dart` | GoRouter (StatefulShellRoute) |
| `lib/presentation/screens/main_shell.dart` | BottomNav Shell |
| `lib/presentation/screens/profile/profile_screen.dart` | 내 정보 탭 |
| `lib/data/models/*.dart` | freezed 데이터 모델 |
| `lib/data/providers/*.dart` | Riverpod providers |

## Build

```bash
# 개발 실행
flutter run -d emulator-5554

# freezed 코드 생성
dart run build_runner build --delete-conflicting-outputs

# APK 빌드
flutter build apk --release
```

## Changelog

### 2026-03-21: UI/UX Refactor
- Drawer 네비게이션 → BottomNavigationBar (4탭)
- GoRouter StatefulShellRoute 도입
- 대화 목록을 홈 탭으로 승격
- 내 정보 탭에 프로필/로그아웃/설정 통합
- Back Navigation 수정 (go → push/pushReplacement)
- 그룹채팅 진입점: 대화 탭 FAB → 1:1/그룹 선택
