import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';

class UserRepository {
  final ApiClient apiClient;

  const UserRepository(this.apiClient);

  Future<TokenResponse> login(String name, String pin) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.login,
      data: {
        'name': name,
        'pin': pin,
      },
    );

    final tokenResponse = TokenResponse.fromJson(response.data!);

    // Store token and user info
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAccessToken, tokenResponse.accessToken);
    await prefs.setString(AppConstants.keyUserId, tokenResponse.user.id);
    await prefs.setString(AppConstants.keyUserName, tokenResponse.user.name);

    return tokenResponse;
  }

  Future<User> getCurrentUser() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.me,
    );

    return User.fromJson(response.data!);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAccessToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keySelectedProfile);
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAccessToken);
  }
}
