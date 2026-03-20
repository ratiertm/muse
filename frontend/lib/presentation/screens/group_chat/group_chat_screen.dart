import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/character.dart';
import '../../../data/models/message.dart';
import '../../../data/providers/group_chat_provider.dart';
import '../../../data/providers/chat_provider.dart';
import '../../widgets/message_bubble.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const GroupChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<Character> _participants = [];
  List<Message> _messages = [];
  final Map<String, String> _streamingMessages = {}; // character_id -> current message
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadParticipants() async {
    try {
      final repository = ref.read(groupChatRepositoryProvider);
      final participants = await repository.getGroupParticipants(widget.conversationId);

      setState(() {
        _participants = participants;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('참가자 로딩 실패: $e')),
      );
    }
  }

  Future<void> _loadMessages() async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(widget.conversationId);

      setState(() {
        _messages = messages;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 로딩 실패: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isStreaming) {
      return;
    }

    _messageController.clear();

    // Add user message to UI
    final userMessage = Message(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      role: MessageRole.user,
      content: message,
      characterId: null,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isStreaming = true;
      _streamingMessages.clear();
    });

    _scrollToBottom();

    try {
      final repository = ref.read(groupChatRepositoryProvider);
      final stream = repository.sendGroupMessage(
        conversationId: widget.conversationId,
        message: message,
      );

      await for (final event in stream) {
        if (event.isDone) {
          // Stream complete
          setState(() {
            _isStreaming = false;

            // Convert streaming messages to actual messages
            _streamingMessages.forEach((characterId, content) {
              _messages.add(Message(
                id: 'ai-${DateTime.now().millisecondsSinceEpoch}-$characterId',
                conversationId: widget.conversationId,
                role: MessageRole.assistant,
                content: content,
                characterId: characterId,
                createdAt: DateTime.now(),
              ));
            });

            _streamingMessages.clear();
          });

          _scrollToBottom();
        } else if (event.characterId != null) {
          // Update streaming message for this character
          setState(() {
            final current = _streamingMessages[event.characterId] ?? '';
            _streamingMessages[event.characterId!] = current + event.chunk;
          });

          _scrollToBottom();
        }
      }
    } catch (e) {
      setState(() {
        _isStreaming = false;
        _streamingMessages.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 실패: $e')),
      );
    }
  }

  Color _getCharacterColor(String characterId) {
    // Generate consistent color from character ID
    final hash = characterId.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }

  Character? _getCharacter(String? characterId) {
    if (characterId == null) return null;
    return _participants.firstWhere(
      (c) => c.id == characterId,
      orElse: () => Character(
        id: characterId,
        userId: '',
        name: 'Unknown',
        personality: '',
        speechStyle: '',
        backstory: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('그룹 채팅'),
            Text(
              '${_participants.length}명 참가',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          // Participant avatars
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final participant = _participants[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: participant.avatarUrl != null
                        ? NetworkImage(participant.avatarUrl!)
                        : null,
                    child: participant.avatarUrl == null
                        ? Text(participant.name[0])
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + _streamingMessages.length,
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  // Regular message
                  final message = _messages[index];
                  final character = _getCharacter(message.characterId);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: message.role == MessageRole.user
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (character != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: _getCharacterColor(character.id),
                                  backgroundImage: character.avatarUrl != null
                                      ? NetworkImage(character.avatarUrl!)
                                      : null,
                                  child: character.avatarUrl == null
                                      ? Text(
                                          character.name[0],
                                          style: const TextStyle(fontSize: 10),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  character.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getCharacterColor(character.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        MessageBubble(
                          message: message,
                        ),
                      ],
                    ),
                  );
                } else {
                  // Streaming message
                  final streamIndex = index - _messages.length;
                  final characterId = _streamingMessages.keys.elementAt(streamIndex);
                  final content = _streamingMessages[characterId]!;
                  final character = _getCharacter(characterId);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (character != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: _getCharacterColor(character.id),
                                  backgroundImage: character.avatarUrl != null
                                      ? NetworkImage(character.avatarUrl!)
                                      : null,
                                  child: character.avatarUrl == null
                                      ? Text(
                                          character.name[0],
                                          style: const TextStyle(fontSize: 10),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  character.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getCharacterColor(character.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        MessageBubble(
                          message: Message(
                            id: 'streaming-$characterId',
                            conversationId: widget.conversationId,
                            role: MessageRole.assistant,
                            content: content,
                            characterId: characterId,
                            createdAt: DateTime.now(),
                          ),
                          isStreaming: true,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지 입력...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isStreaming,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isStreaming
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isStreaming ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
