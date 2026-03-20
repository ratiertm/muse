// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CharacterImpl _$$CharacterImplFromJson(Map<String, dynamic> json) =>
    _$CharacterImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      personality: json['personality'] as String,
      speechStyle: json['speechStyle'] as String,
      backstory: json['backstory'] as String,
      scenario: json['scenario'] as String? ?? '',
      firstMessage: json['firstMessage'] as String? ?? '',
      exampleDialogue: json['exampleDialogue'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      avatarUrl: json['avatarUrl'] as String?,
      modelPreference: json['modelPreference'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CharacterImplToJson(_$CharacterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'personality': instance.personality,
      'speechStyle': instance.speechStyle,
      'backstory': instance.backstory,
      'scenario': instance.scenario,
      'firstMessage': instance.firstMessage,
      'exampleDialogue': instance.exampleDialogue,
      'tags': instance.tags,
      'avatarUrl': instance.avatarUrl,
      'modelPreference': instance.modelPreference,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$CharacterCreateImpl _$$CharacterCreateImplFromJson(
  Map<String, dynamic> json,
) => _$CharacterCreateImpl(
  name: json['name'] as String,
  personality: json['personality'] as String,
  speechStyle: json['speechStyle'] as String,
  backstory: json['backstory'] as String,
  scenario: json['scenario'] as String? ?? '',
  firstMessage: json['firstMessage'] as String? ?? '',
  exampleDialogue: json['exampleDialogue'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  avatarUrl: json['avatarUrl'] as String?,
  modelPreference: json['modelPreference'] as String?,
);

Map<String, dynamic> _$$CharacterCreateImplToJson(
  _$CharacterCreateImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'personality': instance.personality,
  'speechStyle': instance.speechStyle,
  'backstory': instance.backstory,
  'scenario': instance.scenario,
  'firstMessage': instance.firstMessage,
  'exampleDialogue': instance.exampleDialogue,
  'tags': instance.tags,
  'avatarUrl': instance.avatarUrl,
  'modelPreference': instance.modelPreference,
};
