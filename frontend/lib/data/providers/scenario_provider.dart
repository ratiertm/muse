import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scenario.dart';
import '../repositories/scenario_repository.dart';
import 'auth_provider.dart';

final scenarioRepositoryProvider = Provider<ScenarioRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScenarioRepository(apiClient);
});

final scenarioListProvider = FutureProvider<List<Scenario>>((ref) async {
  final repository = ref.watch(scenarioRepositoryProvider);
  return repository.getScenarios();
});

final scenarioProvider =
    FutureProvider.family<Scenario, String>((ref, scenarioId) async {
  final repository = ref.watch(scenarioRepositoryProvider);
  return repository.getScenario(scenarioId);
});

final scenarioCreateProvider =
    StateNotifierProvider<ScenarioCreateNotifier, AsyncValue<Scenario?>>((ref) {
  final repository = ref.watch(scenarioRepositoryProvider);
  return ScenarioCreateNotifier(repository);
});

class ScenarioCreateNotifier extends StateNotifier<AsyncValue<Scenario?>> {
  final ScenarioRepository _repository;

  ScenarioCreateNotifier(this._repository)
      : super(const AsyncValue.data(null));

  Future<void> createScenario(ScenarioCreate scenario) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.createScenario(scenario);
    });
  }

  Future<void> updateScenario(String id, ScenarioUpdate scenario) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.updateScenario(id, scenario);
    });
  }
}
