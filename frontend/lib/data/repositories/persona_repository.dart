import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/persona.dart';

class PersonaRepository {
  final ApiClient apiClient;
  const PersonaRepository(this.apiClient);

  Future<List<Persona>> getPersonas() async {
    final response = await apiClient.get<List<dynamic>>(ApiEndpoints.personas);
    return response.data!.map((json) => Persona.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Persona> createPersona(PersonaCreate data) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.personas,
      data: data.toJson(),
    );
    return Persona.fromJson(response.data!);
  }

  Future<Persona> updatePersona(String id, Map<String, dynamic> data) async {
    final response = await apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.persona(id),
      data: data,
    );
    return Persona.fromJson(response.data!);
  }

  Future<void> deletePersona(String id) async {
    await apiClient.delete(ApiEndpoints.persona(id));
  }
}
