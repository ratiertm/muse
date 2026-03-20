class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  // For real device: use actual server IP
  // static const String baseUrl = 'http://192.168.1.xxx:8000';
  
  static const int apiTimeoutSeconds = 30;
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keySelectedProfile = 'selected_profile';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  
  // Profiles (hardcoded for Phase 4)
  static const profiles = [
    {'name': 'MB', 'avatar': '👨', 'description': '아빠'},
    {'name': '딸', 'avatar': '👧', 'description': '대학생'},
  ];
  
  // UI Constants
  static const double cardBorderRadius = 16.0;
  static const double messageBubbleRadius = 12.0;
  static const int maxMessageLength = 2000;
}
