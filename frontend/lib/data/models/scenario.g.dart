// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScenarioImpl _$$ScenarioImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      worldState: json['worldState'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ScenarioImplToJson(_$ScenarioImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'description': instance.description,
      'worldState': instance.worldState,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$ScenarioCreateImpl _$$ScenarioCreateImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioCreateImpl(
      name: json['name'] as String,
      description: json['description'] as String,
      worldState: json['worldState'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ScenarioCreateImplToJson(
  _$ScenarioCreateImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'worldState': instance.worldState,
};

_$ScenarioUpdateImpl _$$ScenarioUpdateImplFromJson(Map<String, dynamic> json) =>
    _$ScenarioUpdateImpl(
      name: json['name'] as String?,
      description: json['description'] as String?,
      worldState: json['worldState'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$ScenarioUpdateImplToJson(
  _$ScenarioUpdateImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'worldState': instance.worldState,
};
