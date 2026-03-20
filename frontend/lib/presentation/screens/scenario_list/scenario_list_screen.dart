import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/providers/scenario_provider.dart';

class ScenarioListScreen extends ConsumerWidget {
  const ScenarioListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scenariosAsync = ref.watch(scenarioListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('시나리오'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scenario/create'),
        child: const Icon(Icons.add),
      ),
      body: scenariosAsync.when(
        data: (scenarios) {
          if (scenarios.isEmpty) {
            return const Center(
              child: Text('시나리오가 없습니다\n+ 버튼으로 생성하세요'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(scenarioListProvider);
            },
            child: ListView.builder(
              itemCount: scenarios.length,
              itemBuilder: (context, index) {
                final scenario = scenarios[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(
                      scenario.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      scenario.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.push('/scenario/edit/${scenario.id}'),
                    ),
                    onTap: () => context.push('/scenario/edit/${scenario.id}'),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류: $error'),
        ),
      ),
    );
  }
}
