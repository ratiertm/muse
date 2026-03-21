// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'character.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Character _$CharacterFromJson(Map<String, dynamic> json) {
  return _Character.fromJson(json);
}

/// @nodoc
mixin _$Character {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get personality => throw _privateConstructorUsedError;
  String get speechStyle => throw _privateConstructorUsedError;
  String get backstory => throw _privateConstructorUsedError;
  String get scenario => throw _privateConstructorUsedError;
  String get firstMessage => throw _privateConstructorUsedError;
  String get exampleDialogue => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get modelPreference => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  bool get isMine => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Character to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CharacterCopyWith<Character> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterCopyWith<$Res> {
  factory $CharacterCopyWith(Character value, $Res Function(Character) then) =
      _$CharacterCopyWithImpl<$Res, Character>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String personality,
    String speechStyle,
    String backstory,
    String scenario,
    String firstMessage,
    String exampleDialogue,
    List<String> tags,
    String? avatarUrl,
    String? modelPreference,
    bool isPublic,
    bool isMine,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CharacterCopyWithImpl<$Res, $Val extends Character>
    implements $CharacterCopyWith<$Res> {
  _$CharacterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? personality = null,
    Object? speechStyle = null,
    Object? backstory = null,
    Object? scenario = null,
    Object? firstMessage = null,
    Object? exampleDialogue = null,
    Object? tags = null,
    Object? avatarUrl = freezed,
    Object? modelPreference = freezed,
    Object? isPublic = null,
    Object? isMine = null,
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
            personality: null == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as String,
            speechStyle: null == speechStyle
                ? _value.speechStyle
                : speechStyle // ignore: cast_nullable_to_non_nullable
                      as String,
            backstory: null == backstory
                ? _value.backstory
                : backstory // ignore: cast_nullable_to_non_nullable
                      as String,
            scenario: null == scenario
                ? _value.scenario
                : scenario // ignore: cast_nullable_to_non_nullable
                      as String,
            firstMessage: null == firstMessage
                ? _value.firstMessage
                : firstMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            exampleDialogue: null == exampleDialogue
                ? _value.exampleDialogue
                : exampleDialogue // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            modelPreference: freezed == modelPreference
                ? _value.modelPreference
                : modelPreference // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            isMine: null == isMine
                ? _value.isMine
                : isMine // ignore: cast_nullable_to_non_nullable
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
abstract class _$$CharacterImplCopyWith<$Res>
    implements $CharacterCopyWith<$Res> {
  factory _$$CharacterImplCopyWith(
    _$CharacterImpl value,
    $Res Function(_$CharacterImpl) then,
  ) = __$$CharacterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String personality,
    String speechStyle,
    String backstory,
    String scenario,
    String firstMessage,
    String exampleDialogue,
    List<String> tags,
    String? avatarUrl,
    String? modelPreference,
    bool isPublic,
    bool isMine,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CharacterImplCopyWithImpl<$Res>
    extends _$CharacterCopyWithImpl<$Res, _$CharacterImpl>
    implements _$$CharacterImplCopyWith<$Res> {
  __$$CharacterImplCopyWithImpl(
    _$CharacterImpl _value,
    $Res Function(_$CharacterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? personality = null,
    Object? speechStyle = null,
    Object? backstory = null,
    Object? scenario = null,
    Object? firstMessage = null,
    Object? exampleDialogue = null,
    Object? tags = null,
    Object? avatarUrl = freezed,
    Object? modelPreference = freezed,
    Object? isPublic = null,
    Object? isMine = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CharacterImpl(
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
        personality: null == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as String,
        speechStyle: null == speechStyle
            ? _value.speechStyle
            : speechStyle // ignore: cast_nullable_to_non_nullable
                  as String,
        backstory: null == backstory
            ? _value.backstory
            : backstory // ignore: cast_nullable_to_non_nullable
                  as String,
        scenario: null == scenario
            ? _value.scenario
            : scenario // ignore: cast_nullable_to_non_nullable
                  as String,
        firstMessage: null == firstMessage
            ? _value.firstMessage
            : firstMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        exampleDialogue: null == exampleDialogue
            ? _value.exampleDialogue
            : exampleDialogue // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        modelPreference: freezed == modelPreference
            ? _value.modelPreference
            : modelPreference // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        isMine: null == isMine
            ? _value.isMine
            : isMine // ignore: cast_nullable_to_non_nullable
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
class _$CharacterImpl implements _Character {
  const _$CharacterImpl({
    required this.id,
    required this.userId,
    required this.name,
    required this.personality,
    required this.speechStyle,
    required this.backstory,
    this.scenario = '',
    this.firstMessage = '',
    this.exampleDialogue = '',
    final List<String> tags = const [],
    this.avatarUrl,
    this.modelPreference,
    this.isPublic = false,
    this.isMine = false,
    required this.createdAt,
    required this.updatedAt,
  }) : _tags = tags;

  factory _$CharacterImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String personality;
  @override
  final String speechStyle;
  @override
  final String backstory;
  @override
  @JsonKey()
  final String scenario;
  @override
  @JsonKey()
  final String firstMessage;
  @override
  @JsonKey()
  final String exampleDialogue;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? avatarUrl;
  @override
  final String? modelPreference;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  @JsonKey()
  final bool isMine;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Character(id: $id, userId: $userId, name: $name, personality: $personality, speechStyle: $speechStyle, backstory: $backstory, scenario: $scenario, firstMessage: $firstMessage, exampleDialogue: $exampleDialogue, tags: $tags, avatarUrl: $avatarUrl, modelPreference: $modelPreference, isPublic: $isPublic, isMine: $isMine, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            (identical(other.speechStyle, speechStyle) ||
                other.speechStyle == speechStyle) &&
            (identical(other.backstory, backstory) ||
                other.backstory == backstory) &&
            (identical(other.scenario, scenario) ||
                other.scenario == scenario) &&
            (identical(other.firstMessage, firstMessage) ||
                other.firstMessage == firstMessage) &&
            (identical(other.exampleDialogue, exampleDialogue) ||
                other.exampleDialogue == exampleDialogue) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.modelPreference, modelPreference) ||
                other.modelPreference == modelPreference) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.isMine, isMine) || other.isMine == isMine) &&
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
    personality,
    speechStyle,
    backstory,
    scenario,
    firstMessage,
    exampleDialogue,
    const DeepCollectionEquality().hash(_tags),
    avatarUrl,
    modelPreference,
    isPublic,
    isMine,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterImplCopyWith<_$CharacterImpl> get copyWith =>
      __$$CharacterImplCopyWithImpl<_$CharacterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CharacterImplToJson(this);
  }
}

abstract class _Character implements Character {
  const factory _Character({
    required final String id,
    required final String userId,
    required final String name,
    required final String personality,
    required final String speechStyle,
    required final String backstory,
    final String scenario,
    final String firstMessage,
    final String exampleDialogue,
    final List<String> tags,
    final String? avatarUrl,
    final String? modelPreference,
    final bool isPublic,
    final bool isMine,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CharacterImpl;

  factory _Character.fromJson(Map<String, dynamic> json) =
      _$CharacterImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get personality;
  @override
  String get speechStyle;
  @override
  String get backstory;
  @override
  String get scenario;
  @override
  String get firstMessage;
  @override
  String get exampleDialogue;
  @override
  List<String> get tags;
  @override
  String? get avatarUrl;
  @override
  String? get modelPreference;
  @override
  bool get isPublic;
  @override
  bool get isMine;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Character
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterImplCopyWith<_$CharacterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CharacterCreate _$CharacterCreateFromJson(Map<String, dynamic> json) {
  return _CharacterCreate.fromJson(json);
}

/// @nodoc
mixin _$CharacterCreate {
  String get name => throw _privateConstructorUsedError;
  String get personality => throw _privateConstructorUsedError;
  String get speechStyle => throw _privateConstructorUsedError;
  String get backstory => throw _privateConstructorUsedError;
  String get scenario => throw _privateConstructorUsedError;
  String get firstMessage => throw _privateConstructorUsedError;
  String get exampleDialogue => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get modelPreference => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;

  /// Serializes this CharacterCreate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CharacterCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CharacterCreateCopyWith<CharacterCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterCreateCopyWith<$Res> {
  factory $CharacterCreateCopyWith(
    CharacterCreate value,
    $Res Function(CharacterCreate) then,
  ) = _$CharacterCreateCopyWithImpl<$Res, CharacterCreate>;
  @useResult
  $Res call({
    String name,
    String personality,
    String speechStyle,
    String backstory,
    String scenario,
    String firstMessage,
    String exampleDialogue,
    List<String> tags,
    String? avatarUrl,
    String? modelPreference,
    bool isPublic,
  });
}

/// @nodoc
class _$CharacterCreateCopyWithImpl<$Res, $Val extends CharacterCreate>
    implements $CharacterCreateCopyWith<$Res> {
  _$CharacterCreateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CharacterCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? personality = null,
    Object? speechStyle = null,
    Object? backstory = null,
    Object? scenario = null,
    Object? firstMessage = null,
    Object? exampleDialogue = null,
    Object? tags = null,
    Object? avatarUrl = freezed,
    Object? modelPreference = freezed,
    Object? isPublic = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            personality: null == personality
                ? _value.personality
                : personality // ignore: cast_nullable_to_non_nullable
                      as String,
            speechStyle: null == speechStyle
                ? _value.speechStyle
                : speechStyle // ignore: cast_nullable_to_non_nullable
                      as String,
            backstory: null == backstory
                ? _value.backstory
                : backstory // ignore: cast_nullable_to_non_nullable
                      as String,
            scenario: null == scenario
                ? _value.scenario
                : scenario // ignore: cast_nullable_to_non_nullable
                      as String,
            firstMessage: null == firstMessage
                ? _value.firstMessage
                : firstMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            exampleDialogue: null == exampleDialogue
                ? _value.exampleDialogue
                : exampleDialogue // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            modelPreference: freezed == modelPreference
                ? _value.modelPreference
                : modelPreference // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CharacterCreateImplCopyWith<$Res>
    implements $CharacterCreateCopyWith<$Res> {
  factory _$$CharacterCreateImplCopyWith(
    _$CharacterCreateImpl value,
    $Res Function(_$CharacterCreateImpl) then,
  ) = __$$CharacterCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String personality,
    String speechStyle,
    String backstory,
    String scenario,
    String firstMessage,
    String exampleDialogue,
    List<String> tags,
    String? avatarUrl,
    String? modelPreference,
    bool isPublic,
  });
}

/// @nodoc
class __$$CharacterCreateImplCopyWithImpl<$Res>
    extends _$CharacterCreateCopyWithImpl<$Res, _$CharacterCreateImpl>
    implements _$$CharacterCreateImplCopyWith<$Res> {
  __$$CharacterCreateImplCopyWithImpl(
    _$CharacterCreateImpl _value,
    $Res Function(_$CharacterCreateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CharacterCreate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? personality = null,
    Object? speechStyle = null,
    Object? backstory = null,
    Object? scenario = null,
    Object? firstMessage = null,
    Object? exampleDialogue = null,
    Object? tags = null,
    Object? avatarUrl = freezed,
    Object? modelPreference = freezed,
    Object? isPublic = null,
  }) {
    return _then(
      _$CharacterCreateImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        personality: null == personality
            ? _value.personality
            : personality // ignore: cast_nullable_to_non_nullable
                  as String,
        speechStyle: null == speechStyle
            ? _value.speechStyle
            : speechStyle // ignore: cast_nullable_to_non_nullable
                  as String,
        backstory: null == backstory
            ? _value.backstory
            : backstory // ignore: cast_nullable_to_non_nullable
                  as String,
        scenario: null == scenario
            ? _value.scenario
            : scenario // ignore: cast_nullable_to_non_nullable
                  as String,
        firstMessage: null == firstMessage
            ? _value.firstMessage
            : firstMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        exampleDialogue: null == exampleDialogue
            ? _value.exampleDialogue
            : exampleDialogue // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        modelPreference: freezed == modelPreference
            ? _value.modelPreference
            : modelPreference // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CharacterCreateImpl implements _CharacterCreate {
  const _$CharacterCreateImpl({
    required this.name,
    required this.personality,
    required this.speechStyle,
    required this.backstory,
    this.scenario = '',
    this.firstMessage = '',
    this.exampleDialogue = '',
    final List<String> tags = const [],
    this.avatarUrl,
    this.modelPreference,
    this.isPublic = false,
  }) : _tags = tags;

  factory _$CharacterCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterCreateImplFromJson(json);

  @override
  final String name;
  @override
  final String personality;
  @override
  final String speechStyle;
  @override
  final String backstory;
  @override
  @JsonKey()
  final String scenario;
  @override
  @JsonKey()
  final String firstMessage;
  @override
  @JsonKey()
  final String exampleDialogue;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? avatarUrl;
  @override
  final String? modelPreference;
  @override
  @JsonKey()
  final bool isPublic;

  @override
  String toString() {
    return 'CharacterCreate(name: $name, personality: $personality, speechStyle: $speechStyle, backstory: $backstory, scenario: $scenario, firstMessage: $firstMessage, exampleDialogue: $exampleDialogue, tags: $tags, avatarUrl: $avatarUrl, modelPreference: $modelPreference, isPublic: $isPublic)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterCreateImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.personality, personality) ||
                other.personality == personality) &&
            (identical(other.speechStyle, speechStyle) ||
                other.speechStyle == speechStyle) &&
            (identical(other.backstory, backstory) ||
                other.backstory == backstory) &&
            (identical(other.scenario, scenario) ||
                other.scenario == scenario) &&
            (identical(other.firstMessage, firstMessage) ||
                other.firstMessage == firstMessage) &&
            (identical(other.exampleDialogue, exampleDialogue) ||
                other.exampleDialogue == exampleDialogue) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.modelPreference, modelPreference) ||
                other.modelPreference == modelPreference) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    personality,
    speechStyle,
    backstory,
    scenario,
    firstMessage,
    exampleDialogue,
    const DeepCollectionEquality().hash(_tags),
    avatarUrl,
    modelPreference,
    isPublic,
  );

  /// Create a copy of CharacterCreate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterCreateImplCopyWith<_$CharacterCreateImpl> get copyWith =>
      __$$CharacterCreateImplCopyWithImpl<_$CharacterCreateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CharacterCreateImplToJson(this);
  }
}

abstract class _CharacterCreate implements CharacterCreate {
  const factory _CharacterCreate({
    required final String name,
    required final String personality,
    required final String speechStyle,
    required final String backstory,
    final String scenario,
    final String firstMessage,
    final String exampleDialogue,
    final List<String> tags,
    final String? avatarUrl,
    final String? modelPreference,
    final bool isPublic,
  }) = _$CharacterCreateImpl;

  factory _CharacterCreate.fromJson(Map<String, dynamic> json) =
      _$CharacterCreateImpl.fromJson;

  @override
  String get name;
  @override
  String get personality;
  @override
  String get speechStyle;
  @override
  String get backstory;
  @override
  String get scenario;
  @override
  String get firstMessage;
  @override
  String get exampleDialogue;
  @override
  List<String> get tags;
  @override
  String? get avatarUrl;
  @override
  String? get modelPreference;
  @override
  bool get isPublic;

  /// Create a copy of CharacterCreate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterCreateImplCopyWith<_$CharacterCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
