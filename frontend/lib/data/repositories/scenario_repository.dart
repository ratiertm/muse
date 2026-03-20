import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/scenario.dart';
import '../models/character.dart';

class ScenarioRepository {
  final ApiClient apiClient;

  const ScenarioRepository(this.apiClient);

  Future<List<Scenario>> getScenarios() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.scenarios,
    );

    final data = response.data!;
    final items = (data['items'] as List)
        .map((json) => Scenario.fromJson(json as Map<String, dynamic>))
        .toList();

    return items;
  }

  Future<Scenario> getScenario(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.scenario(id),
    );

    return Scenario.fromJson(response.data!);
  }

  Future<Scenario> createScenario(ScenarioCreate scenario) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.scenarios,
      data: scenario.toJson(),
    );

    return Scenario.fromJson(response.data!);
  }

  Future<Scenario> updateScenario(String id, ScenarioUpdate scenario) async {
    final response = await apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.scenario(id),
      data: scenario.toJson(),
    );

    return Scenario.fromJson(response.data!);
  }

  Future<void> deleteScenario(String id) async {
    await apiClient.delete(ApiEndpoints.scenario(id));
  }

  Future<List<Character>> getScenarioCharacters(String scenarioId) async {
    final response = await apiClient.get<List<dynamic>>(
      ApiEndpoints.scenarioCharacters(scenarioId),
    );

    return response.data!
        .map((json) => Character.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCharacterToScenario(String scenarioId, String characterId) async {
    await apiClient.post(
      ApiEndpoints.scenarioCharacters(scenarioId),
      data: {'character_id': characterId},
    );
  }

  Future<void> removeCharacterFromScenario(
      String scenarioId, String characterId) async {
    await apiClient.delete(
      '${ApiEndpoints.scenarioCharacters(scenarioId)}/$characterId',
    );
  }
}
