import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String conversationId,
    String? characterId,
    required MessageRole role,
    required String content,
    int? tokenCount,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}
