import 'package:go_router/go_router.dart';
import '../../presentation/screens/profile_selection/profile_selection_screen.dart';
import '../../presentation/screens/pin_auth/pin_auth_screen.dart';
import '../../presentation/screens/character_list/character_list_screen.dart';
import '../../presentation/screens/character_create/character_create_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/scenario_list/scenario_list_screen.dart';
import '../../presentation/screens/scenario_edit/scenario_edit_screen.dart';
import '../../presentation/screens/group_create/group_create_screen.dart';
import '../../presentation/screens/group_chat/group_chat_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/profile-selection',
  routes: [
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
    GoRoute(
      path: '/characters',
      builder: (context, state) => const CharacterListScreen(),
    ),
    GoRoute(
      path: '/character/create',
      builder: (context, state) => const CharacterCreateScreen(),
    ),
    GoRoute(
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
      path: '/scenarios',
      builder: (context, state) => const ScenarioListScreen(),
    ),
    GoRoute(
      path: '/scenario/create',
      builder: (context, state) => const ScenarioEditScreen(),
    ),
    GoRoute(
      path: '/scenario/edit/:scenarioId',
      builder: (context, state) {
        final scenarioId = state.pathParameters['scenarioId']!;
        return ScenarioEditScreen(scenarioId: scenarioId);
      },
    ),
    GoRoute(
      path: '/group/create',
      builder: (context, state) => const GroupCreateScreen(),
    ),
    GoRoute(
      path: '/group-chat/:conversationId',
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId']!;
        return GroupChatScreen(conversationId: conversationId);
      },
    ),
  ],
);
