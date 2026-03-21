// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      characterId: json['character_id'] as String?,
      scenarioId: json['scenario_id'] as String?,
      personaId: json['persona_id'] as String?,
      isGroup: json['is_group'] as bool? ?? false,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'character_id': instance.characterId,
      'scenario_id': instance.scenarioId,
      'persona_id': instance.personaId,
      'is_group': instance.isGroup,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
