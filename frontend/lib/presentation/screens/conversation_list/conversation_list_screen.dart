import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/conversation.dart';
import '../../../data/providers/chat_provider.dart';

final conversationListProvider = FutureProvider.autoDispose<List<Conversation>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getConversations();
});

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('대화'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline),
                    title: const Text('캐릭터와 대화하기'),
                    subtitle: const Text('좋아하는 캐릭터를 골라 대화해요'),
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/characters');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.auto_stories),
                    title: const Text('시나리오 플레이'),
                    subtitle: const Text('여러 캐릭터와 함께 이야기를 만들어요'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/group/create');
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    '아직 대화가 없어요',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '+ 버튼을 눌러 캐릭터와 대화를 시작해보세요!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // WHY: 같은 캐릭터 1:1 대화가 중복 표시되는 문제 → 캐릭터별 최신 1건만 표시
          // SEE: docs/decisions/007-conversation-grouping.md
          final groupChats = conversations.where((c) => c.isGroup).toList();
          final soloChats = conversations.where((c) => !c.isGroup).toList();

          // Group solo chats by character - show only latest per character
          final Map<String, List<Conversation>> soloByChar = {};
          for (final conv in soloChats) {
            final key = conv.characterId ?? conv.id;
            soloByChar.putIfAbsent(key, () => []).add(conv);
          }
          // Sort each group by updatedAt desc (latest first)
          for (final list in soloByChar.values) {
            list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          }
          // Sort character groups by latest conversation
          final sortedSoloKeys = soloByChar.keys.toList()
            ..sort((a, b) => soloByChar[b]!.first.updatedAt
                .compareTo(soloByChar[a]!.first.updatedAt));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(conversationListProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (groupChats.isNotEmpty) ...[
                  _buildSectionHeader(context, '시나리오 캐릭터 대화', Icons.auto_stories),
                  const SizedBox(height: 8),
                  ...groupChats.map((conv) => _buildConversationTile(
                    context,
                    conv,
                    Icons.auto_stories,
                    () => context.push('/group-chat/${conv.id}'),
                  )),
                  const SizedBox(height: 24),
                ],
                if (sortedSoloKeys.isNotEmpty) ...[
                  _buildSectionHeader(context, '이전 캐릭터와 대화', Icons.chat_bubble_outline),
                  const SizedBox(height: 8),
                  ...sortedSoloKeys.map((charId) {
                    final convList = soloByChar[charId]!;
                    final latest = convList.first;
                    final count = convList.length;
                    // Extract character name from title (remove "Chat with " prefix)
                    final charName = latest.title.replaceFirst('Chat with ', '');

                    return _buildSoloConversationTile(
                      context,
                      ref,
                      latest,
                      charName,
                      count,
                      convList,
                    );
                  }),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('오류: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(conversationListProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    Conversation conv,
    IconData icon,
    VoidCallback onTap,
  ) {
    final timeAgo = _formatTimeAgo(conv.updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: conv.isGroup
              ? Colors.deepPurple.shade50
              : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            size: 20,
            color: conv.isGroup
                ? Colors.deepPurple
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          conv.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          timeAgo,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSoloConversationTile(
    BuildContext context,
    WidgetRef ref,
    Conversation latest,
    String charName,
    int count,
    List<Conversation> allConvs,
  ) {
    final timeAgo = _formatTimeAgo(latest.updatedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            charName.isNotEmpty ? charName[0] : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          charName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          count > 1 ? '$timeAgo  ·  대화 ${count}개' : timeAgo,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: () {
          if (count == 1) {
            // 대화가 1개면 바로 진입
            context.push('/chat/${latest.characterId}?conversationId=${latest.id}');
          } else {
            // 여러 개면 목록 보여주기
            showModalBottomSheet(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        '$charName 대화 기록',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...allConvs.map((conv) => ListTile(
                      leading: Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(_formatTimeAgo(conv.updatedAt)),
                      trailing: const Icon(Icons.chevron_right, size: 16),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/chat/${conv.characterId}?conversationId=${conv.id}');
                      },
                    )),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dateTime.month}/${dateTime.day}';
  }
}
