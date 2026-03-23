class AppConstants {
  // API Configuration - Environment-based
  static String get baseUrl {
    // Build with: flutter build apk --dart-define=ENV=prod
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    const customUrl = String.fromEnvironment('API_URL', defaultValue: '');
    
    if (customUrl.isNotEmpty) {
      return customUrl;
    }
    
    switch (env) {
      case 'prod':
        // Production server (update with your Oracle Cloud IP or domain)
        return 'http://YOUR_SERVER_IP:8000';
      case 'staging':
        // Staging server
        return 'http://YOUR_STAGING_IP:8000';
      default:
        // Development (Android emulator)
        return 'http://10.0.2.2:8000';
    }
  }
  
  static const int apiTimeoutSeconds = 120;
  
  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keySelectedProfile = 'selected_profile';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';
  
  // Profiles (hardcoded for Phase 4)
  static const profiles = [
    {'name': 'MB', 'avatar': '👨', 'description': '아빠'},
    {'name': '딸', 'avatar': '👧', 'description': '대학생'},
    {'name': 'EM', 'avatar': '👩', 'description': '엄마'},
  ];
  
  /// WHY: MAL CDN URL이 만료되므로 서버 로컬에 저장한 이미지를 절대URL로 변환
  /// SEE: docs/decisions/003-local-avatar-storage.md
  static String? resolveAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return '$baseUrl$url';
  }

  // UI Constants
  static const double cardBorderRadius = 16.0;
  static const double messageBubbleRadius = 12.0;
  static const int maxMessageLength = 2000;
}
