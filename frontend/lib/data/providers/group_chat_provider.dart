import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/group_chat_repository.dart';
import 'auth_provider.dart';

final groupChatRepositoryProvider = Provider<GroupChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GroupChatRepository(apiClient);
});
