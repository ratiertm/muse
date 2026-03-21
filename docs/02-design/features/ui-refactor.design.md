# UI/UX Refactor Design

## Feature: ui-refactor
## Date: 2026-03-21
## Status: Design

---

## 1. Architecture Design

### 1.1 Navigation Architecture (Before → After)

**Before (Drawer)**:
```
ProfileSelection → PinAuth → CharacterList (Hub)
                                  ├─ Drawer → Personas
                                  ├─ Drawer → Conversations
                                  ├─ Drawer → Scenarios
                                  ├─ Drawer → Group Create
                                  ├─ Drawer → Settings
                                  └─ AppBar → Logout
```

**After (BottomNav)**:
```
ProfileSelection → PinAuth → MainShell (BottomNav)
                                  ├─ Tab 1: Conversations (Home)
                                  │    ├─ /chat/:characterId
                                  │    └─ /group-chat/:conversationId
                                  ├─ Tab 2: Characters
                                  │    ├─ /characters/create
                                  │    └─ /characters/:id/edit
                                  ├─ Tab 3: Scenarios
                                  │    ├─ /scenarios/create
                                  │    └─ /scenarios/:id/edit
                                  └─ Tab 4: Profile (내 정보)
                                       ├─ /profile/personas
                                       └─ /profile/settings
```

### 1.2 GoRouter Structure

```dart
GoRouter(
  initialLocation: '/profile-selection',
  routes: [
    // Auth flow (outside shell)
    GoRoute(path: '/profile-selection', ...),
    GoRoute(path: '/pin-auth', ...),

    // Main app (inside shell)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell),
      branches: [
        // Tab 1: Conversations
        StatefulShellBranch(routes: [
          GoRoute(path: '/conversations', ...),
        ]),
        // Tab 2: Characters
        StatefulShellBranch(routes: [
          GoRoute(path: '/characters', ...),
        ]),
        // Tab 3: Scenarios
        StatefulShellBranch(routes: [
          GoRoute(path: '/scenarios', ...),
        ]),
        // Tab 4: Profile
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', ...),
        ]),
      ],
    ),

    // Full-screen routes (outside shell, with back button)
    GoRoute(path: '/chat/:characterId', ...),
    GoRoute(path: '/group-chat/:conversationId', ...),
    GoRoute(path: '/group/create', ...),
  ],
)
```

### 1.3 MainShell Widget

```dart
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  Widget build(context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        destinations: [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: '대화'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: '캐릭터'),
          NavigationDestination(icon: Icon(Icons.auto_stories_outlined), label: '시나리오'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: '내 정보'),
        ],
        onDestinationSelected: (index) => navigationShell.goBranch(index),
      ),
    );
  }
}
```

### 1.4 ProfileScreen (내 정보 탭)

```
┌─────────────────────────┐
│  프로필 카드              │
│  [아바타] 사용자이름      │
│  ──────────────────────  │
│  📋 내 페르소나     >    │
│  🎨 테마 설정       >    │
│  🔧 서버 설정       >    │
│  ──────────────────────  │
│  🔄 프로필 전환          │
│  🚪 로그아웃             │
│  ──────────────────────  │
│  ℹ️ Muse v1.0            │
└─────────────────────────┘
```

---

## 2. Implementation Order

### Phase 1: P0-1 BottomNav (핵심 구조)
1. `main_shell.dart` 생성
2. `app_router.dart` 전면 재구성 (StatefulShellRoute)
3. `character_list_screen.dart` - Drawer 제거, AppBar 단순화

### Phase 2: P0-2 Back Navigation
4. `group_create_screen.dart` - `go()` → `pushReplacement()`
5. 전체 화면 뒤로가기 검증

### Phase 3: P0-3 로그아웃 동선
6. `profile_screen.dart` 생성 (내 정보 탭)
7. `character_list_screen.dart` - AppBar logout 제거

### Phase 4: P1-4~6 구조 개선
8. `conversation_list_screen.dart` - 홈 탭 강화
9. 그룹채팅 진입점 정리

---

## 3. File Changes Detail

### 신규 파일
| File | Purpose |
|------|---------|
| `presentation/screens/main_shell.dart` | BottomNav 쉘 (4탭) |
| `presentation/screens/profile/profile_screen.dart` | 내 정보 탭 |

### 수정 파일
| File | Changes |
|------|---------|
| `core/router/app_router.dart` | StatefulShellRoute 도입, 전면 재구성 |
| `screens/character_list/character_list_screen.dart` | Drawer 제거, AppBar 단순화 |
| `screens/conversation_list/conversation_list_screen.dart` | 홈 탭 승격, FAB 추가 |
| `screens/group_create/group_create_screen.dart` | `go()` → `pushReplacement()` |
| `screens/scenario_list/scenario_list_screen.dart` | AppBar 정리 |
| `screens/settings/settings_screen.dart` | 설정 항목 축소 (profile에 통합) |

### 삭제 없음
- 기존 화면은 모두 유지, 네비게이션 구조만 변경

---

## 4. Test Checklist

각 Phase 완료 후 화면 캡처로 검증:

### Phase 1 (BottomNav)
- [ ] 4개 탭이 하단에 표시됨
- [ ] 탭 전환 시 화면 정상 변경
- [ ] 탭 간 상태 유지됨

### Phase 2 (Back Navigation)
- [ ] 그룹채팅 생성 후 뒤로가기 정상
- [ ] 채팅 화면에서 뒤로가기 정상
- [ ] 편집 화면에서 뒤로가기 정상

### Phase 3 (로그아웃)
- [ ] 내 정보 탭에서 프로필 카드 표시
- [ ] 로그아웃 버튼 접근 가능
- [ ] 프로필 전환 동작

### Phase 4 (구조 개선)
- [ ] 대화 목록이 첫 번째 탭
- [ ] FAB로 새 대화 시작 가능
- [ ] 전체 앱 동선 자연스러움
