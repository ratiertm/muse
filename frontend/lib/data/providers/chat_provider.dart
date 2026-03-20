import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/sse_client.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';
import 'auth_provider.dart';

// Chat Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(apiClientProvider),
    SSEClient(),
  );
});

// Conversations List Provider
final conversationsProvider = FutureProvider.family<List<Conversation>, String?>((ref, characterId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getConversations(characterId: characterId);
});

// Messages Provider
final messagesProvider = FutureProvider.family<List<Message>, String>((ref, conversationId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return await repository.getMessages(conversationId);
});

// Chat Controller (for managing chat state and streaming)
final chatControllerProvider = StateNotifierProvider.family<ChatController, ChatState, String>(
  (ref, characterId) {
    return ChatController(
      characterId: characterId,
      repository: ref.watch(chatRepositoryProvider),
    );
  },
);

class ChatState {
  final List<Message> messages;
  final String? conversationId;
  final String? streamingMessage;
  final bool isLoading;
  final String? error;

  ChatState({
    this.messages = const [],
    this.conversationId,
    this.streamingMessage,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    String? conversationId,
    String? streamingMessage,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
      streamingMessage: streamingMessage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final String characterId;
  final ChatRepository repository;

  ChatController({
    required this.characterId,
    required this.repository,
  }) : super(ChatState());

  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(isLoading: true, conversationId: conversationId);
    try {
      final messages = await repository.getMessages(conversationId);
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    final userMessage = Message(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: state.conversationId ?? '',
      role: MessageRole.user,
      content: text,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      String assistantMessage = '';

      // Stream the response
      final stream = repository.streamChat(
        characterId: characterId,
        conversationId: state.conversationId,
        message: text,
      );

      await for (final chunk in stream) {
        assistantMessage += chunk;
        state = state.copyWith(streamingMessage: assistantMessage);
      }

      // Add complete assistant message
      final completeMessage = Message(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        conversationId: state.conversationId ?? '',
        role: MessageRole.assistant,
        content: assistantMessage,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, completeMessage],
        streamingMessage: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        streamingMessage: null,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
