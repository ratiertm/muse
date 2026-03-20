import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/conversation.dart';
import '../models/character.dart';

class GroupChatEvent {
  final String? characterId;
  final String? characterName;
  final String chunk;
  final bool isDone;

  GroupChatEvent({
    this.characterId,
    this.characterName,
    required this.chunk,
    required this.isDone,
  });

  factory GroupChatEvent.fromJson(Map<String, dynamic> json) {
    return GroupChatEvent(
      characterId: json['character_id'] as String?,
      characterName: json['character_name'] as String?,
      chunk: json['chunk'] as String? ?? '',
      isDone: json['is_done'] as bool? ?? false,
    );
  }
}

class GroupChatRepository {
  final ApiClient apiClient;

  const GroupChatRepository(this.apiClient);

  Future<Conversation> createGroupChat({
    required String scenarioId,
    required List<String> characterIds,
    required String title,
  }) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.groupChat,
      data: {
        'scenario_id': scenarioId,
        'character_ids': characterIds,
        'title': title,
      },
    );

    return Conversation.fromJson(response.data!);
  }

  Future<List<Character>> getGroupParticipants(String conversationId) async {
    final response = await apiClient.get<List<dynamic>>(
      '${ApiEndpoints.groupChat}/$conversationId/participants',
    );

    return response.data!
        .map((json) => Character.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Stream<GroupChatEvent> sendGroupMessage({
    required String conversationId,
    required String message,
  }) async* {
    final url = '${apiClient.baseUrl}${ApiEndpoints.groupChat}/$conversationId/message';
    final token = await apiClient.token;

    final request = await apiClient.dio.post<ResponseBody>(
      url,
      data: {'message': message},
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'text/event-stream',
        },
        responseType: ResponseType.stream,
      ),
    );

    final stream = request.data!.stream;

    await for (final chunk in stream) {
      final lines = utf8.decode(chunk).split('\n');

      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          try {
            final json = jsonDecode(jsonStr) as Map<String, dynamic>;
            yield GroupChatEvent.fromJson(json);
          } catch (e) {
            // Skip invalid JSON
          }
        }
      }
    }
  }
}
