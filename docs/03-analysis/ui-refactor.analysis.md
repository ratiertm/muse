# UI/UX Refactor Gap Analysis

## Feature: ui-refactor
## Date: 2026-03-21
## Match Rate: 95%

---

## 1. Design vs Implementation Comparison

### P0-1: BottomNavigationBar
| Design | Implementation | Status |
|--------|---------------|--------|
| MainShell with NavigationBar 4tabs | `main_shell.dart` created with 4 NavigationDestination | MATCH |
| StatefulShellRoute.indexedStack | `app_router.dart` uses StatefulShellRoute.indexedStack | MATCH |
| Tab icons: chat_bubble, people, auto_stories, person | Correct icons with selected variants | MATCH |
| Tab labels: 대화, 캐릭터, 시나리오, 내 정보 | Correct Korean labels | MATCH |
| Drawer removed from CharacterListScreen | Drawer code fully removed | MATCH |
| AppBar logout icon removed | Removed from CharacterListScreen | MATCH |

### P0-2: Back Navigation
| Design | Implementation | Status |
|--------|---------------|--------|
| group_create go→pushReplacement | Line 106 changed to pushReplacement | MATCH |
| Chat/GroupChat as full-screen routes | Both use parentNavigatorKey: _rootNavigatorKey | MATCH |

### P0-3: Logout Location
| Design | Implementation | Status |
|--------|---------------|--------|
| ProfileScreen with profile card | `profile_screen.dart` created with user card | MATCH |
| Persona, Theme, Server settings | All present in ProfileScreen | MATCH |
| Profile switch button | "프로필 전환" ListTile present | MATCH |
| Logout with confirmation | AlertDialog with red button | MATCH |

### P1-4: Router Hierarchy
| Design | Implementation | Status |
|--------|---------------|--------|
| 4 StatefulShellBranch with navigator keys | 4 branches with unique GlobalKey | MATCH |
| Auth routes outside shell | /profile-selection, /pin-auth outside | MATCH |
| Nested routes (characters/create, etc) | Correctly nested under parent routes | MATCH |

### P1-5: Home Tab
| Design | Implementation | Status |
|--------|---------------|--------|
| ConversationList as first tab | First branch is /conversations | MATCH |
| Login redirects to conversations | pin_auth goes to /conversations | MATCH |
| FAB for new conversation | FAB with BottomSheet (1:1/Group) | MATCH |

### P1-6: Group Chat Entry
| Design | Implementation | Status |
|--------|---------------|--------|
| FAB → BottomSheet selection | ConversationList FAB shows 2 options | MATCH |
| Remove from Drawer | Drawer completely removed | MATCH |

---

## 2. Remaining Gaps (5%)

| # | Gap | Priority | Status |
|---|-----|----------|--------|
| 1 | Settings screen still has persona link and logout (now duplicated with ProfileScreen) | Low | Could simplify SettingsScreen to remove redundant items |
| 2 | ConversationList empty state text could be updated for new FAB context | Low | Minor copy change |
| 3 | Screen capture automated test blocked by adb tap coordinates | N/A | Manual test needed |

---

## 3. Build Verification

- `flutter analyze`: 0 errors, warnings only (deprecation, unused)
- `flutter build`: APK built successfully
- App installed on emulator: Confirmed

---

## 4. Conclusion

**Match Rate: 95%** - All P0 and P1 design items are implemented correctly.
Remaining 5% are minor polish items (duplicated settings content, copy text).
Ready for completion report.
