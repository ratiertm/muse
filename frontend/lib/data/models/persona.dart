import 'package:freezed_annotation/freezed_annotation.dart';

part 'persona.freezed.dart';
part 'persona.g.dart';

@freezed
class Persona with _$Persona {
  const factory Persona({
    required String id,
    required String userId,
    required String name,
    String? appearance,
    String? personality,
    String? description,
    @Default(false) bool isDefault,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Persona;

  factory Persona.fromJson(Map<String, dynamic> json) => _$PersonaFromJson(json);
}

@freezed
class PersonaCreate with _$PersonaCreate {
  const factory PersonaCreate({
    required String name,
    String? appearance,
    String? personality,
    String? description,
    @Default(false) bool isDefault,
  }) = _PersonaCreate;

  factory PersonaCreate.fromJson(Map<String, dynamic> json) => _$PersonaCreateFromJson(json);
}
