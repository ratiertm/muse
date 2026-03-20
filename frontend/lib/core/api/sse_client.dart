import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SSEClient {
  Stream<String> streamChat({
    required String characterId,
    String? conversationId,
    String? scenarioId,
    required String message,
    String? model,
  }) async* {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAccessToken);
    
    if (token == null) {
      throw Exception('No auth token found');
    }
    
    final url = Uri.parse('${AppConstants.baseUrl}/api/v1/chat');
    
    final body = {
      'character_id': characterId,
      if (conversationId != null) 'conversation_id': conversationId,
      if (scenarioId != null) 'scenario_id': scenarioId,
      'message': message,
      if (model != null) 'model': model,
    };
    
    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'text/event-stream'
      ..body = jsonEncode(body);
    
    final response = await request.send();
    
    if (response.statusCode != 200) {
      throw Exception('SSE stream failed: ${response.statusCode}');
    }
    
    // Note: conversation ID is available in response headers if needed
    // final conversationId = response.headers['x-conversation-id'];
    
    await for (var chunk in response.stream.transform(utf8.decoder)) {
      final lines = chunk.split('\n');
      
      for (var line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          
          if (data == '[DONE]') {
            // Stream complete
            return;
          }
          
          yield data;
        }
      }
    }
  }
}
