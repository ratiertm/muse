import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.watch(userRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserRepository _userRepository;

  AuthNotifier(this._userRepository) : super(const AsyncValue.loading()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final token = await _userRepository.getStoredToken();
      if (token != null) {
        final user = await _userRepository.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> login(String name, String pin) async {
    state = const AsyncValue.loading();
    try {
      final tokenResponse = await _userRepository.login(name, pin);
      state = AsyncValue.data(tokenResponse.user);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  Future<void> logout() async {
    await _userRepository.logout();
    state = const AsyncValue.data(null);
  }
}

// Selected Profile Provider (for profile selection screen)
final selectedProfileProvider = StateProvider<String?>((ref) => null);

// Store selected profile
Future<void> storeSelectedProfile(String profileName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(AppConstants.keySelectedProfile, profileName);
}

// Get stored profile
Future<String?> getStoredProfile() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(AppConstants.keySelectedProfile);
}
