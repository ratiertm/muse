import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/character_provider.dart';
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
        title: const Text('캐릭터'),
      ),
      body: charactersAsync.when(
        data: (characters) {
          if (characters.isEmpty) {
            return EmptyState(
              icon: Icons.person_add_outlined,
              title: '캐릭터가 없습니다',
              message: '+ 버튼을 눌러 새로운 캐릭터를 만들어보세요!',
              actionLabel: '캐릭터 만들기',
              onAction: () => context.push('/characters/create'),
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
                  onEdit: character.isMine ? () {
                    context.push('/characters/edit/${character.id}');
                  } : null,
                  onDelete: character.isMine ? () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('캐릭터 삭제'),
                        content: Text('"${character.name}"을(를) 삭제하시겠습니까?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('삭제'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        final apiClient = ref.read(apiClientProvider);
                        await apiClient.delete('/api/v1/characters/${character.id}');
                        ref.invalidate(characterListProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('삭제되었습니다')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('삭제 실패: $e')),
                          );
                        }
                      }
                    }
                  } : null,
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
          context.push('/characters/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
