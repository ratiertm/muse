import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/character_provider.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../widgets/character_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../widgets/empty_state.dart';

class CharacterListScreen extends ConsumerWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(characterListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 캐릭터'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                context.go('/profile-selection');
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.chat, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Muse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('내 캐릭터'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.movie),
              title: const Text('시나리오'),
              onTap: () {
                Navigator.pop(context);
                context.push('/scenarios');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('그룹 채팅 만들기'),
              onTap: () {
                Navigator.pop(context);
                context.push('/group/create');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
          ],
        ),
      ),
      body: charactersAsync.when(
        data: (characters) {
          if (characters.isEmpty) {
            return EmptyState(
              icon: Icons.person_add_outlined,
              title: '캐릭터가 없습니다',
              message: '+ 버튼을 눌러 새로운 캐릭터를 만들어보세요!',
              actionLabel: '캐릭터 만들기',
              onAction: () => context.push('/character/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(characterListProvider);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return CharacterCard(
                  character: character,
                  onTap: () {
                    context.push('/chat/${character.id}');
                  },
                );
              },
            ),
          );
        },
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 6, // Show 6 shimmer placeholders
          itemBuilder: (context, index) => const CharacterCardShimmer(),
        ),
        error: (error, stack) => EmptyState(
          icon: Icons.error_outline,
          title: '오류가 발생했습니다',
          message: error.toString(),
          actionLabel: '다시 시도',
          onAction: () => ref.invalidate(characterListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/character/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
