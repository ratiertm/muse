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
    required Map<String, dynamic> worldState,
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
    @Default({}) Map<String, dynamic> worldState,
  }) = _ScenarioCreate;

  factory ScenarioCreate.fromJson(Map<String, dynamic> json) =>
      _$ScenarioCreateFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'world_state': worldState,
      };
}

@freezed
class ScenarioUpdate with _$ScenarioUpdate {
  const factory ScenarioUpdate({
    String? name,
    String? description,
    Map<String, dynamic>? worldState,
  }) = _ScenarioUpdate;

  factory ScenarioUpdate.fromJson(Map<String, dynamic> json) =>
      _$ScenarioUpdateFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;
    if (worldState != null) json['world_state'] = worldState;
    return json;
  }
}
