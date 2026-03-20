import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/character.dart';

class CharacterRepository {
  final ApiClient apiClient;

  const CharacterRepository(this.apiClient);

  Future<List<Character>> getCharacters({
    List<String>? tags,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (tags != null && tags.isNotEmpty) {
      queryParams['tags'] = tags;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.characters,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final data = response.data!;
    final items = (data['items'] as List)
        .map((json) => Character.fromJson(json as Map<String, dynamic>))
        .toList();

    return items;
  }

  Future<Character> getCharacter(String id) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.character(id),
    );

    return Character.fromJson(response.data!);
  }

  Future<Character> createCharacter(CharacterCreate character) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.characters,
      data: character.toJson(),
    );

    return Character.fromJson(response.data!);
  }

  Future<void> deleteCharacter(String id) async {
    await apiClient.delete(ApiEndpoints.character(id));
  }
}
