// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CharacterImpl _$$CharacterImplFromJson(Map<String, dynamic> json) =>
    _$CharacterImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      personality: json['personality'] as String,
      speechStyle: json['speech_style'] as String,
      backstory: json['backstory'] as String,
      scenario: json['scenario'] as String? ?? '',
      firstMessage: json['first_message'] as String? ?? '',
      exampleDialogue: json['example_dialogue'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      avatarUrl: json['avatar_url'] as String?,
      modelPreference: json['model_preference'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      isMine: json['is_mine'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CharacterImplToJson(_$CharacterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'personality': instance.personality,
      'speech_style': instance.speechStyle,
      'backstory': instance.backstory,
      'scenario': instance.scenario,
      'first_message': instance.firstMessage,
      'example_dialogue': instance.exampleDialogue,
      'tags': instance.tags,
      'avatar_url': instance.avatarUrl,
      'model_preference': instance.modelPreference,
      'is_public': instance.isPublic,
      'is_mine': instance.isMine,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$CharacterCreateImpl _$$CharacterCreateImplFromJson(
  Map<String, dynamic> json,
) => _$CharacterCreateImpl(
  name: json['name'] as String,
  personality: json['personality'] as String,
  speechStyle: json['speech_style'] as String,
  backstory: json['backstory'] as String,
  scenario: json['scenario'] as String? ?? '',
  firstMessage: json['first_message'] as String? ?? '',
  exampleDialogue: json['example_dialogue'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  avatarUrl: json['avatar_url'] as String?,
  modelPreference: json['model_preference'] as String?,
  isPublic: json['is_public'] as bool? ?? false,
);

Map<String, dynamic> _$$CharacterCreateImplToJson(
  _$CharacterCreateImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'personality': instance.personality,
  'speech_style': instance.speechStyle,
  'backstory': instance.backstory,
  'scenario': instance.scenario,
  'first_message': instance.firstMessage,
  'example_dialogue': instance.exampleDialogue,
  'tags': instance.tags,
  'avatar_url': instance.avatarUrl,
  'model_preference': instance.modelPreference,
  'is_public': instance.isPublic,
};
