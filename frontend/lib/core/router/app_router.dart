import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/main_shell.dart';
import '../../presentation/screens/profile_selection/profile_selection_screen.dart';
import '../../presentation/screens/pin_auth/pin_auth_screen.dart';
import '../../presentation/screens/character_list/character_list_screen.dart';
import '../../presentation/screens/character_create/character_create_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/scenario_list/scenario_list_screen.dart';
import '../../presentation/screens/scenario_edit/scenario_edit_screen.dart';
import '../../presentation/screens/group_create/group_create_screen.dart';
import '../../presentation/screens/group_chat/group_chat_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/persona_list/persona_list_screen.dart';
import '../../presentation/screens/persona_edit/persona_edit_screen.dart';
import '../../presentation/screens/conversation_list/conversation_list_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';

// Navigator keys for each tab branch
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _conversationsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'conversations');
final _charactersNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'characters');
final _scenariosNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'scenarios');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/profile-selection',
  routes: [
    // === Auth Flow (outside shell) ===
    GoRoute(
      path: '/profile-selection',
      builder: (context, state) => const ProfileSelectionScreen(),
    ),
    GoRoute(
      path: '/pin-auth',
      builder: (context, state) {
        final profileName = state.extra as String? ?? 'User';
        return PinAuthScreen(profileName: profileName);
      },
    ),

    // === Main App (BottomNav Shell) ===
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Conversations (Home)
        StatefulShellBranch(
          navigatorKey: _conversationsNavigatorKey,
          routes: [
            GoRoute(
              path: '/conversations',
              builder: (context, state) => const ConversationListScreen(),
            ),
          ],
        ),

        // Tab 2: Characters
        StatefulShellBranch(
          navigatorKey: _charactersNavigatorKey,
          routes: [
            GoRoute(
              path: '/characters',
              builder: (context, state) => const CharacterListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const CharacterCreateScreen(),
                ),
                GoRoute(
                  path: 'edit/:characterId',
                  builder: (context, state) {
                    final characterId = state.pathParameters['characterId']!;
                    return CharacterCreateScreen(characterId: characterId);
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 3: Scenarios
        StatefulShellBranch(
          navigatorKey: _scenariosNavigatorKey,
          routes: [
            GoRoute(
              path: '/scenarios',
              builder: (context, state) => const ScenarioListScreen(),
              routes: [
                GoRoute(
                  path: 'create',
                  builder: (context, state) => const ScenarioEditScreen(),
                ),
                GoRoute(
                  path: 'edit/:scenarioId',
                  builder: (context, state) {
                    final scenarioId = state.pathParameters['scenarioId']!;
                    return ScenarioEditScreen(scenarioId: scenarioId);
                  },
                ),
              ],
            ),
          ],
        ),

        // Tab 4: Profile
        StatefulShellBranch(
          navigatorKey: _profileNavigatorKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'personas',
                  builder: (context, state) => const PersonaListScreen(),
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (context, state) => const PersonaEditScreen(),
                    ),
                    GoRoute(
                      path: 'edit/:personaId',
                      builder: (context, state) {
                        final personaId = state.pathParameters['personaId']!;
                        return PersonaEditScreen(personaId: personaId);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // === Full-screen routes (outside shell, with back button) ===
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/chat/:characterId',
      builder: (context, state) {
        final characterId = state.pathParameters['characterId']!;
        final conversationId = state.uri.queryParameters['conversationId'];
        return ChatScreen(
          characterId: characterId,
          conversationId: conversationId,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/group-chat/:conversationId',
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId']!;
        return GroupChatScreen(conversationId: conversationId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/group/create',
      builder: (context, state) => const GroupCreateScreen(),
    ),
  ],
);
