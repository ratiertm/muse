import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/persona.dart';
import '../../../data/providers/persona_provider.dart';

class PersonaListScreen extends ConsumerWidget {
  const PersonaListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personasAsync = ref.watch(personaListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 페르소나'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/profile/personas/create');
          ref.invalidate(personaListProvider);
        },
        child: const Icon(Icons.add),
      ),
      body: personasAsync.when(
        data: (personas) {
          if (personas.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildPersonaList(context, ref, personas);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다: $error'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(personaListProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.face_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              '페르소나를 만들어\n시나리오에 참여하세요',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await context.push('/profile/personas/create');
                ref.invalidate(personaListProvider);
              },
              icon: const Icon(Icons.add),
              label: const Text('페르소나 만들기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonaList(BuildContext context, WidgetRef ref, List<Persona> personas) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(personaListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: personas.length,
        itemBuilder: (context, index) {
          final persona = personas[index];
          return _buildPersonaCard(context, ref, persona);
        },
      ),
    );
  }

  Widget _buildPersonaCard(BuildContext context, WidgetRef ref, Persona persona) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await context.push('/profile/personas/edit/${persona.id}');
          ref.invalidate(personaListProvider);
        },
        onLongPress: () => _showDeleteDialog(context, ref, persona),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  persona.name.isNotEmpty ? persona.name[0] : '?',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            persona.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (persona.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '기본',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (persona.personality != null && persona.personality!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        persona.personality!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Persona persona) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('페르소나 삭제'),
        content: Text('"${persona.name}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final repository = ref.read(personaRepositoryProvider);
                await repository.deletePersona(persona.id);
                ref.invalidate(personaListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('페르소나가 삭제되었습니다')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 실패: $e')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
