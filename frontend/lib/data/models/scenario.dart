import 'package:freezed_annotation/freezed_annotation.dart';

part 'scenario.freezed.dart';
part 'scenario.g.dart';

@freezed
class Scenario with _$Scenario {
  const factory Scenario({
    required String id,
    required String userId,
    required String name,
    required String description,
    @Default('') String purpose,
    required Map<String, dynamic> worldState,
    @Default(false) bool isPublic,
    @Default(false) bool isMine,
    @Default([]) List<Map<String, dynamic>> characterAvatars,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Scenario;

  factory Scenario.fromJson(Map<String, dynamic> json) =>
      _$ScenarioFromJson(json);
}

@freezed
class ScenarioCreate with _$ScenarioCreate {
  const factory ScenarioCreate({
    required String name,
    required String description,
    @Default('') String purpose,
    @Default({}) Map<String, dynamic> worldState,
    @Default(false) bool isPublic,
  }) = _ScenarioCreate;

  factory ScenarioCreate.fromJson(Map<String, dynamic> json) =>
      _$ScenarioCreateFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'purpose': purpose,
        'world_state': worldState,
        'is_public': isPublic,
      };
}

@freezed
class ScenarioUpdate with _$ScenarioUpdate {
  const factory ScenarioUpdate({
    String? name,
    String? description,
    String? purpose,
    Map<String, dynamic>? worldState,
    bool? isPublic,
  }) = _ScenarioUpdate;

  factory ScenarioUpdate.fromJson(Map<String, dynamic> json) =>
      _$ScenarioUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (purpose != null) json['purpose'] = purpose;
    if (worldState != null) json['world_state'] = worldState;
    if (isPublic != null) json['is_public'] = isPublic;
    return json;
  }
}
