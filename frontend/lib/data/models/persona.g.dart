// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonaImpl _$$PersonaImplFromJson(Map<String, dynamic> json) =>
    _$PersonaImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      appearance: json['appearance'] as String?,
      personality: json['personality'] as String?,
      description: json['description'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$PersonaImplToJson(_$PersonaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'appearance': instance.appearance,
      'personality': instance.personality,
      'description': instance.description,
      'is_default': instance.isDefault,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

_$PersonaCreateImpl _$$PersonaCreateImplFromJson(Map<String, dynamic> json) =>
    _$PersonaCreateImpl(
      name: json['name'] as String,
      appearance: json['appearance'] as String?,
      personality: json['personality'] as String?,
      description: json['description'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
    );

Map<String, dynamic> _$$PersonaCreateImplToJson(_$PersonaCreateImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'appearance': instance.appearance,
      'personality': instance.personality,
      'description': instance.description,
      'is_default': instance.isDefault,
    };
