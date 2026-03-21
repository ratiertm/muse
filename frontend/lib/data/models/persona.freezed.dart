// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'persona.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Persona _$PersonaFromJson(Map<String, dynamic> json) {
  return _Persona.fromJson(json);
}

/// @nodoc
mixin _$Persona {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get appearance => throw _privateConstructorUsedError;
  String? get personality => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Persona to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Persona
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonaCopyWith<Persona> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonaCopyWith<$Res> {
  factory $PersonaCopyWith(Persona value, $Res Function(Persona) then) =
      _$PersonaCopyWithImpl<$Res, Persona>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String? appearance,
    String? personality,
    String? description,
    bool isDefault,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$PersonaCopyWithImpl<$Res, $Val extends Persona>
    implements $PersonaCopyWith<$Res> {
  _$PersonaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Persona
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? appearance = freezed,
    Object? personality = freezed,
    Object? description = freezed,
    Object? isDefault = null,
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
            appearance: freezed == appearance
                ? _value.appearance
                : appearance // ignore: cast_nullable_to_non_nullable
                      as String?,
            personality: freezed == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$PersonaImplCopyWith<$Res> implements $PersonaCopyWith<$Res> {
  factory _$$PersonaImplCopyWith(
    _$PersonaImpl value,
    $Res Function(_$PersonaImpl) then,
  ) = __$$PersonaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String? appearance,
    String? personality,
    String? description,
    bool isDefault,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$PersonaImplCopyWithImpl<$Res>
    extends _$PersonaCopyWithImpl<$Res, _$PersonaImpl>
    implements _$$PersonaImplCopyWith<$Res> {
  __$$PersonaImplCopyWithImpl(
    _$PersonaImpl _value,
    $Res Function(_$PersonaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Persona
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? appearance = freezed,
    Object? personality = freezed,
    Object? description = freezed,
    Object? isDefault = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$PersonaImpl(
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
        appearance: freezed == appearance
            ? _value.appearance
            : appearance // ignore: cast_nullable_to_non_nullable
                  as String?,
        personality: freezed == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$PersonaImpl implements _Persona {
  const _$PersonaImpl({
    required this.id,
    required this.userId,
    required this.name,
    this.appearance,
    this.personality,
    this.description,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$PersonaImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonaImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String? appearance;
  @override
  final String? personality;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Persona(id: $id, userId: $userId, name: $name, appearance: $appearance, personality: $personality, description: $description, isDefault: $isDefault, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.appearance, appearance) ||
                other.appearance == appearance) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
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
    appearance,
    personality,
    description,
    isDefault,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Persona
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonaImplCopyWith<_$PersonaImpl> get copyWith =>
      __$$PersonaImplCopyWithImpl<_$PersonaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonaImplToJson(this);
  }
}

abstract class _Persona implements Persona {
  const factory _Persona({
    required final String id,
    required final String userId,
    required final String name,
    final String? appearance,
    final String? personality,
    final String? description,
    final bool isDefault,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$PersonaImpl;

  factory _Persona.fromJson(Map<String, dynamic> json) = _$PersonaImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String? get appearance;
  @override
  String? get personality;
  @override
  String? get description;
  @override
  bool get isDefault;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Persona
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonaImplCopyWith<_$PersonaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PersonaCreate _$PersonaCreateFromJson(Map<String, dynamic> json) {
  return _PersonaCreate.fromJson(json);
}

/// @nodoc
mixin _$PersonaCreate {
  String get name => throw _privateConstructorUsedError;
  String? get appearance => throw _privateConstructorUsedError;
  String? get personality => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this PersonaCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PersonaCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PersonaCreateCopyWith<PersonaCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonaCreateCopyWith<$Res> {
  factory $PersonaCreateCopyWith(
    PersonaCreate value,
    $Res Function(PersonaCreate) then,
  ) = _$PersonaCreateCopyWithImpl<$Res, PersonaCreate>;
  @useResult
  $Res call({
    String name,
    String? appearance,
    String? personality,
    String? description,
    bool isDefault,
  });
}

/// @nodoc
class _$PersonaCreateCopyWithImpl<$Res, $Val extends PersonaCreate>
    implements $PersonaCreateCopyWith<$Res> {
  _$PersonaCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PersonaCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? appearance = freezed,
    Object? personality = freezed,
    Object? description = freezed,
    Object? isDefault = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            appearance: freezed == appearance
                ? _value.appearance
                : appearance // ignore: cast_nullable_to_non_nullable
                      as String?,
            personality: freezed == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PersonaCreateImplCopyWith<$Res>
    implements $PersonaCreateCopyWith<$Res> {
  factory _$$PersonaCreateImplCopyWith(
    _$PersonaCreateImpl value,
    $Res Function(_$PersonaCreateImpl) then,
  ) = __$$PersonaCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String? appearance,
    String? personality,
    String? description,
    bool isDefault,
  });
}

/// @nodoc
class __$$PersonaCreateImplCopyWithImpl<$Res>
    extends _$PersonaCreateCopyWithImpl<$Res, _$PersonaCreateImpl>
    implements _$$PersonaCreateImplCopyWith<$Res> {
  __$$PersonaCreateImplCopyWithImpl(
    _$PersonaCreateImpl _value,
    $Res Function(_$PersonaCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PersonaCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? appearance = freezed,
    Object? personality = freezed,
    Object? description = freezed,
    Object? isDefault = null,
  }) {
    return _then(
      _$PersonaCreateImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        appearance: freezed == appearance
            ? _value.appearance
            : appearance // ignore: cast_nullable_to_non_nullable
                  as String?,
        personality: freezed == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonaCreateImpl implements _PersonaCreate {
  const _$PersonaCreateImpl({
    required this.name,
    this.appearance,
    this.personality,
    this.description,
    this.isDefault = false,
  });

  factory _$PersonaCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonaCreateImplFromJson(json);

  @override
  final String name;
  @override
  final String? appearance;
  @override
  final String? personality;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isDefault;

  @override
  String toString() {
    return 'PersonaCreate(name: $name, appearance: $appearance, personality: $personality, description: $description, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonaCreateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.appearance, appearance) ||
                other.appearance == appearance) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    appearance,
    personality,
    description,
    isDefault,
  );

  /// Create a copy of PersonaCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonaCreateImplCopyWith<_$PersonaCreateImpl> get copyWith =>
      __$$PersonaCreateImplCopyWithImpl<_$PersonaCreateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonaCreateImplToJson(this);
  }
}

abstract class _PersonaCreate implements PersonaCreate {
  const factory _PersonaCreate({
    required final String name,
    final String? appearance,
    final String? personality,
    final String? description,
    final bool isDefault,
  }) = _$PersonaCreateImpl;

  factory _PersonaCreate.fromJson(Map<String, dynamic> json) =
      _$PersonaCreateImpl.fromJson;

  @override
  String get name;
  @override
  String? get appearance;
  @override
  String? get personality;
  @override
  String? get description;
  @override
  bool get isDefault;

  /// Create a copy of PersonaCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PersonaCreateImplCopyWith<_$PersonaCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
