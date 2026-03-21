import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/api/sse_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class ChatRepository {
  final ApiClient apiClient;
  final SSEClient sseClient;

  const ChatRepository(this.apiClient, this.sseClient);

  Future<List<Conversation>> getConversations({String? characterId}) async {
    final endpoint = characterId != null
        ? ApiEndpoints.conversationsByCharacter(characterId)
        : ApiEndpoints.conversations;

    final response = await apiClient.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: {'per_page': 100},
    );

    final data = response.data!;
    final items = (data['items'] as List)
        .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
        .toList();

    return items;
  }

  Future<List<Message>> getMessages(String conversationId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.conversationMessages(conversationId),
    );

    final data = response.data!;
    final items = (data['items'] as List)
        .map((json) => Message.fromJson(json as Map<String, dynamic>))
        .toList();

    return items;
  }

  Stream<String> streamChat({
    required String characterId,
    String? conversationId,
    String? scenarioId,
    required String message,
    String? model,
  }) {
    return sseClient.streamChat(
      characterId: characterId,
      conversationId: conversationId,
      scenarioId: scenarioId,
      message: message,
      model: model,
    );
  }
}
