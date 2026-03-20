// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scenario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Scenario _$ScenarioFromJson(Map<String, dynamic> json) {
  return _Scenario.fromJson(json);
}

/// @nodoc
mixin _$Scenario {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic> get worldState => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Scenario to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Scenario
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScenarioCopyWith<Scenario> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScenarioCopyWith<$Res> {
  factory $ScenarioCopyWith(Scenario value, $Res Function(Scenario) then) =
      _$ScenarioCopyWithImpl<$Res, Scenario>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String description,
    Map<String, dynamic> worldState,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$ScenarioCopyWithImpl<$Res, $Val extends Scenario>
    implements $ScenarioCopyWith<$Res> {
  _$ScenarioCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Scenario
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = null,
    Object? worldState = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            worldState: null == worldState
                ? _value.worldState
                : worldState // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScenarioImplCopyWith<$Res>
    implements $ScenarioCopyWith<$Res> {
  factory _$$ScenarioImplCopyWith(
    _$ScenarioImpl value,
    $Res Function(_$ScenarioImpl) then,
  ) = __$$ScenarioImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String description,
    Map<String, dynamic> worldState,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$ScenarioImplCopyWithImpl<$Res>
    extends _$ScenarioCopyWithImpl<$Res, _$ScenarioImpl>
    implements _$$ScenarioImplCopyWith<$Res> {
  __$$ScenarioImplCopyWithImpl(
    _$ScenarioImpl _value,
    $Res Function(_$ScenarioImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Scenario
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = null,
    Object? worldState = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$ScenarioImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        worldState: null == worldState
            ? _value._worldState
            : worldState // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScenarioImpl implements _Scenario {
  const _$ScenarioImpl({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required final Map<String, dynamic> worldState,
    required this.createdAt,
    required this.updatedAt,
  }) : _worldState = worldState;

  factory _$ScenarioImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScenarioImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String description;
  final Map<String, dynamic> _worldState;
  @override
  Map<String, dynamic> get worldState {
    if (_worldState is EqualUnmodifiableMapView) return _worldState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_worldState);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Scenario(id: $id, userId: $userId, name: $name, description: $description, worldState: $worldState, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScenarioImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._worldState,
              _worldState,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    name,
    description,
    const DeepCollectionEquality().hash(_worldState),
    createdAt,
    updatedAt,
  );

  /// Create a copy of Scenario
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScenarioImplCopyWith<_$ScenarioImpl> get copyWith =>
      __$$ScenarioImplCopyWithImpl<_$ScenarioImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScenarioImplToJson(this);
  }
}

abstract class _Scenario implements Scenario {
  const factory _Scenario({
    required final String id,
    required final String userId,
    required final String name,
    required final String description,
    required final Map<String, dynamic> worldState,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$ScenarioImpl;

  factory _Scenario.fromJson(Map<String, dynamic> json) =
      _$ScenarioImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get description;
  @override
  Map<String, dynamic> get worldState;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Scenario
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScenarioImplCopyWith<_$ScenarioImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScenarioCreate _$ScenarioCreateFromJson(Map<String, dynamic> json) {
  return _ScenarioCreate.fromJson(json);
}

/// @nodoc
mixin _$ScenarioCreate {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  Map<String, dynamic> get worldState => throw _privateConstructorUsedError;

  /// Serializes this ScenarioCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScenarioCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScenarioCreateCopyWith<ScenarioCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScenarioCreateCopyWith<$Res> {
  factory $ScenarioCreateCopyWith(
    ScenarioCreate value,
    $Res Function(ScenarioCreate) then,
  ) = _$ScenarioCreateCopyWithImpl<$Res, ScenarioCreate>;
  @useResult
  $Res call({String name, String description, Map<String, dynamic> worldState});
}

/// @nodoc
class _$ScenarioCreateCopyWithImpl<$Res, $Val extends ScenarioCreate>
    implements $ScenarioCreateCopyWith<$Res> {
  _$ScenarioCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScenarioCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? worldState = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            worldState: null == worldState
                ? _value.worldState
                : worldState // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScenarioCreateImplCopyWith<$Res>
    implements $ScenarioCreateCopyWith<$Res> {
  factory _$$ScenarioCreateImplCopyWith(
    _$ScenarioCreateImpl value,
    $Res Function(_$ScenarioCreateImpl) then,
  ) = __$$ScenarioCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String description, Map<String, dynamic> worldState});
}

/// @nodoc
class __$$ScenarioCreateImplCopyWithImpl<$Res>
    extends _$ScenarioCreateCopyWithImpl<$Res, _$ScenarioCreateImpl>
    implements _$$ScenarioCreateImplCopyWith<$Res> {
  __$$ScenarioCreateImplCopyWithImpl(
    _$ScenarioCreateImpl _value,
    $Res Function(_$ScenarioCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScenarioCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? worldState = null,
  }) {
    return _then(
      _$ScenarioCreateImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        worldState: null == worldState
            ? _value._worldState
            : worldState // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScenarioCreateImpl implements _ScenarioCreate {
  const _$ScenarioCreateImpl({
    required this.name,
    required this.description,
    final Map<String, dynamic> worldState = const {},
  }) : _worldState = worldState;

  factory _$ScenarioCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScenarioCreateImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  final Map<String, dynamic> _worldState;
  @override
  @JsonKey()
  Map<String, dynamic> get worldState {
    if (_worldState is EqualUnmodifiableMapView) return _worldState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_worldState);
  }

  @override
  String toString() {
    return 'ScenarioCreate(name: $name, description: $description, worldState: $worldState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScenarioCreateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._worldState,
              _worldState,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    const DeepCollectionEquality().hash(_worldState),
  );

  /// Create a copy of ScenarioCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScenarioCreateImplCopyWith<_$ScenarioCreateImpl> get copyWith =>
      __$$ScenarioCreateImplCopyWithImpl<_$ScenarioCreateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScenarioCreateImplToJson(this);
  }
}

abstract class _ScenarioCreate implements ScenarioCreate {
  const factory _ScenarioCreate({
    required final String name,
    required final String description,
    final Map<String, dynamic> worldState,
  }) = _$ScenarioCreateImpl;

  factory _ScenarioCreate.fromJson(Map<String, dynamic> json) =
      _$ScenarioCreateImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  Map<String, dynamic> get worldState;

  /// Create a copy of ScenarioCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScenarioCreateImplCopyWith<_$ScenarioCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScenarioUpdate _$ScenarioUpdateFromJson(Map<String, dynamic> json) {
  return _ScenarioUpdate.fromJson(json);
}

/// @nodoc
mixin _$ScenarioUpdate {
  String? get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  Map<String, dynamic>? get worldState => throw _privateConstructorUsedError;

  /// Serializes this ScenarioUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScenarioUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScenarioUpdateCopyWith<ScenarioUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScenarioUpdateCopyWith<$Res> {
  factory $ScenarioUpdateCopyWith(
    ScenarioUpdate value,
    $Res Function(ScenarioUpdate) then,
  ) = _$ScenarioUpdateCopyWithImpl<$Res, ScenarioUpdate>;
  @useResult
  $Res call({
    String? name,
    String? description,
    Map<String, dynamic>? worldState,
  });
}

/// @nodoc
class _$ScenarioUpdateCopyWithImpl<$Res, $Val extends ScenarioUpdate>
    implements $ScenarioUpdateCopyWith<$Res> {
  _$ScenarioUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScenarioUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? worldState = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            worldState: freezed == worldState
                ? _value.worldState
                : worldState // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScenarioUpdateImplCopyWith<$Res>
    implements $ScenarioUpdateCopyWith<$Res> {
  factory _$$ScenarioUpdateImplCopyWith(
    _$ScenarioUpdateImpl value,
    $Res Function(_$ScenarioUpdateImpl) then,
  ) = __$$ScenarioUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? name,
    String? description,
    Map<String, dynamic>? worldState,
  });
}

/// @nodoc
class __$$ScenarioUpdateImplCopyWithImpl<$Res>
    extends _$ScenarioUpdateCopyWithImpl<$Res, _$ScenarioUpdateImpl>
    implements _$$ScenarioUpdateImplCopyWith<$Res> {
  __$$ScenarioUpdateImplCopyWithImpl(
    _$ScenarioUpdateImpl _value,
    $Res Function(_$ScenarioUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScenarioUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? description = freezed,
    Object? worldState = freezed,
  }) {
    return _then(
      _$ScenarioUpdateImpl(
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        worldState: freezed == worldState
            ? _value._worldState
            : worldState // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScenarioUpdateImpl implements _ScenarioUpdate {
  const _$ScenarioUpdateImpl({
    this.name,
    this.description,
    final Map<String, dynamic>? worldState,
  }) : _worldState = worldState;

  factory _$ScenarioUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScenarioUpdateImplFromJson(json);

  @override
  final String? name;
  @override
  final String? description;
  final Map<String, dynamic>? _worldState;
  @override
  Map<String, dynamic>? get worldState {
    final value = _worldState;
    if (value == null) return null;
    if (_worldState is EqualUnmodifiableMapView) return _worldState;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'ScenarioUpdate(name: $name, description: $description, worldState: $worldState)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScenarioUpdateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._worldState,
              _worldState,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    description,
    const DeepCollectionEquality().hash(_worldState),
  );

  /// Create a copy of ScenarioUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScenarioUpdateImplCopyWith<_$ScenarioUpdateImpl> get copyWith =>
      __$$ScenarioUpdateImplCopyWithImpl<_$ScenarioUpdateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScenarioUpdateImplToJson(this);
  }
}

abstract class _ScenarioUpdate implements ScenarioUpdate {
  const factory _ScenarioUpdate({
    final String? name,
    final String? description,
    final Map<String, dynamic>? worldState,
  }) = _$ScenarioUpdateImpl;

  factory _ScenarioUpdate.fromJson(Map<String, dynamic> json) =
      _$ScenarioUpdateImpl.fromJson;

  @override
  String? get name;
  @override
  String? get description;
  @override
  Map<String, dynamic>? get worldState;

  /// Create a copy of ScenarioUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScenarioUpdateImplCopyWith<_$ScenarioUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
