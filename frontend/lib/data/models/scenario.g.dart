// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScenarioImpl _$$ScenarioImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      purpose: json['purpose'] as String? ?? '',
      worldState: json['world_state'] as Map<String, dynamic>,
      isPublic: json['is_public'] as bool? ?? false,
      isMine: json['is_mine'] as bool? ?? false,
      characterAvatars:
          (json['character_avatars'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ScenarioImplToJson(_$ScenarioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'purpose': instance.purpose,
      'world_state': instance.worldState,
      'is_public': instance.isPublic,
      'is_mine': instance.isMine,
      'character_avatars': instance.characterAvatars,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$ScenarioCreateImpl _$$ScenarioCreateImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioCreateImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      purpose: json['purpose'] as String? ?? '',
      worldState: json['world_state'] as Map<String, dynamic>? ?? const {},
      isPublic: json['is_public'] as bool? ?? false,
    );

Map<String, dynamic> _$$ScenarioCreateImplToJson(
  _$ScenarioCreateImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'purpose': instance.purpose,
  'world_state': instance.worldState,
  'is_public': instance.isPublic,
};

_$ScenarioUpdateImpl _$$ScenarioUpdateImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioUpdateImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      purpose: json['purpose'] as String?,
      worldState: json['world_state'] as Map<String, dynamic>?,
      isPublic: json['is_public'] as bool?,
    );

Map<String, dynamic> _$$ScenarioUpdateImplToJson(
  _$ScenarioUpdateImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'purpose': instance.purpose,
  'world_state': instance.worldState,
  'is_public': instance.isPublic,
};
