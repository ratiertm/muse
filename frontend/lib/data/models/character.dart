import 'package:freezed_annotation/freezed_annotation.dart';

part 'character.freezed.dart';
part 'character.g.dart';

@freezed
class Character with _$Character {
  const factory Character({
    required String id,
    required String userId,
    required String name,
    required String personality,
    required String speechStyle,
    required String backstory,
    @Default('') String scenario,
    @Default('') String firstMessage,
    @Default('') String exampleDialogue,
    @Default([]) List<String> tags,
    String? avatarUrl,
    String? modelPreference,
    @Default(false) bool isPublic,
    @Default(false) bool isMine,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Character;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);
}

@freezed
class CharacterCreate with _$CharacterCreate {
  const factory CharacterCreate({
    required String name,
    required String personality,
    required String speechStyle,
    required String backstory,
    @Default('') String scenario,
    @Default('') String firstMessage,
    @Default('') String exampleDialogue,
    @Default([]) List<String> tags,
    String? avatarUrl,
    String? modelPreference,
    @Default(false) bool isPublic,
  }) = _CharacterCreate;

  factory CharacterCreate.fromJson(Map<String, dynamic> json) =>
      _$CharacterCreateFromJson(json);
}
