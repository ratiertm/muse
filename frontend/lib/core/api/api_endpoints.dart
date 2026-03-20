class ApiEndpoints {
  static const String users = '/api/v1/users';
  static const String login = '/api/v1/auth/login';
  static const String me = '/api/v1/auth/me';
  static const String characters = '/api/v1/characters';
  static const String chat = '/api/v1/chat';
  static const String conversations = '/api/v1/conversations';
  static const String groupChat = '/api/v1/group-chat';
  
  static String character(String id) => '$characters/$id';
  static String conversation(String id) => '$conversations/$id';
  static String conversationMessages(String id) => '$conversations/$id/messages';
  static String conversationsByCharacter(String characterId) => 
      '$conversations?character_id=$characterId';
}
