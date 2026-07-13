// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'librivox_audiobook.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LibrivoxAudiobook _$LibrivoxAudiobookFromJson(Map<String, dynamic> json) {
  return _LibrivoxAudiobook.fromJson(json);
}

/// @nodoc
mixin _$LibrivoxAudiobook {
  int? get librivoxId => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  int? get totalTimeSecs => throw _privateConstructorUsedError;
  List<LibrivoxSection> get sections => throw _privateConstructorUsedError;

  /// Serializes this LibrivoxAudiobook to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LibrivoxAudiobook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LibrivoxAudiobookCopyWith<LibrivoxAudiobook> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LibrivoxAudiobookCopyWith<$Res> {
  factory $LibrivoxAudiobookCopyWith(
    LibrivoxAudiobook value,
    $Res Function(LibrivoxAudiobook) then,
  ) = _$LibrivoxAudiobookCopyWithImpl<$Res, LibrivoxAudiobook>;
  @useResult
  $Res call({
    int? librivoxId,
    String? title,
    String? author,
    int? totalTimeSecs,
    List<LibrivoxSection> sections,
  });
}

/// @nodoc
class _$LibrivoxAudiobookCopyWithImpl<$Res, $Val extends LibrivoxAudiobook>
    implements $LibrivoxAudiobookCopyWith<$Res> {
  _$LibrivoxAudiobookCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LibrivoxAudiobook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? librivoxId = freezed,
    Object? title = freezed,
    Object? author = freezed,
    Object? totalTimeSecs = freezed,
    Object? sections = null,
  }) {
    return _then(
      _value.copyWith(
            librivoxId: freezed == librivoxId
                ? _value.librivoxId
                : librivoxId // ignore: cast_nullable_to_non_nullable
                      as int?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            author: freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalTimeSecs: freezed == totalTimeSecs
                ? _value.totalTimeSecs
                : totalTimeSecs // ignore: cast_nullable_to_non_nullable
                      as int?,
            sections: null == sections
                ? _value.sections
                : sections // ignore: cast_nullable_to_non_nullable
                      as List<LibrivoxSection>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LibrivoxAudiobookImplCopyWith<$Res>
    implements $LibrivoxAudiobookCopyWith<$Res> {
  factory _$$LibrivoxAudiobookImplCopyWith(
    _$LibrivoxAudiobookImpl value,
    $Res Function(_$LibrivoxAudiobookImpl) then,
  ) = __$$LibrivoxAudiobookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? librivoxId,
    String? title,
    String? author,
    int? totalTimeSecs,
    List<LibrivoxSection> sections,
  });
}

/// @nodoc
class __$$LibrivoxAudiobookImplCopyWithImpl<$Res>
    extends _$LibrivoxAudiobookCopyWithImpl<$Res, _$LibrivoxAudiobookImpl>
    implements _$$LibrivoxAudiobookImplCopyWith<$Res> {
  __$$LibrivoxAudiobookImplCopyWithImpl(
    _$LibrivoxAudiobookImpl _value,
    $Res Function(_$LibrivoxAudiobookImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LibrivoxAudiobook
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? librivoxId = freezed,
    Object? title = freezed,
    Object? author = freezed,
    Object? totalTimeSecs = freezed,
    Object? sections = null,
  }) {
    return _then(
      _$LibrivoxAudiobookImpl(
        librivoxId: freezed == librivoxId
            ? _value.librivoxId
            : librivoxId // ignore: cast_nullable_to_non_nullable
                  as int?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        author: freezed == author
            ? _value.author
            : author // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalTimeSecs: freezed == totalTimeSecs
            ? _value.totalTimeSecs
            : totalTimeSecs // ignore: cast_nullable_to_non_nullable
                  as int?,
        sections: null == sections
            ? _value._sections
            : sections // ignore: cast_nullable_to_non_nullable
                  as List<LibrivoxSection>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LibrivoxAudiobookImpl implements _LibrivoxAudiobook {
  const _$LibrivoxAudiobookImpl({
    this.librivoxId,
    this.title,
    this.author,
    this.totalTimeSecs,
    final List<LibrivoxSection> sections = const <LibrivoxSection>[],
  }) : _sections = sections;

  factory _$LibrivoxAudiobookImpl.fromJson(Map<String, dynamic> json) =>
      _$$LibrivoxAudiobookImplFromJson(json);

  @override
  final int? librivoxId;
  @override
  final String? title;
  @override
  final String? author;
  @override
  final int? totalTimeSecs;
  final List<LibrivoxSection> _sections;
  @override
  @JsonKey()
  List<LibrivoxSection> get sections {
    if (_sections is EqualUnmodifiableListView) return _sections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sections);
  }

  @override
  String toString() {
    return 'LibrivoxAudiobook(librivoxId: $librivoxId, title: $title, author: $author, totalTimeSecs: $totalTimeSecs, sections: $sections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LibrivoxAudiobookImpl &&
            (identical(other.librivoxId, librivoxId) ||
                other.librivoxId == librivoxId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.totalTimeSecs, totalTimeSecs) ||
                other.totalTimeSecs == totalTimeSecs) &&
            const DeepCollectionEquality().equals(other._sections, _sections));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    librivoxId,
    title,
    author,
    totalTimeSecs,
    const DeepCollectionEquality().hash(_sections),
  );

  /// Create a copy of LibrivoxAudiobook
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LibrivoxAudiobookImplCopyWith<_$LibrivoxAudiobookImpl> get copyWith =>
      __$$LibrivoxAudiobookImplCopyWithImpl<_$LibrivoxAudiobookImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LibrivoxAudiobookImplToJson(this);
  }
}

abstract class _LibrivoxAudiobook implements LibrivoxAudiobook {
  const factory _LibrivoxAudiobook({
    final int? librivoxId,
    final String? title,
    final String? author,
    final int? totalTimeSecs,
    final List<LibrivoxSection> sections,
  }) = _$LibrivoxAudiobookImpl;

  factory _LibrivoxAudiobook.fromJson(Map<String, dynamic> json) =
      _$LibrivoxAudiobookImpl.fromJson;

  @override
  int? get librivoxId;
  @override
  String? get title;
  @override
  String? get author;
  @override
  int? get totalTimeSecs;
  @override
  List<LibrivoxSection> get sections;

  /// Create a copy of LibrivoxAudiobook
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LibrivoxAudiobookImplCopyWith<_$LibrivoxAudiobookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LibrivoxSection _$LibrivoxSectionFromJson(Map<String, dynamic> json) {
  return _LibrivoxSection.fromJson(json);
}

/// @nodoc
mixin _$LibrivoxSection {
  String? get title => throw _privateConstructorUsedError;
  String get listenUrl => throw _privateConstructorUsedError;
  int? get playtimeSecs => throw _privateConstructorUsedError;

  /// Serializes this LibrivoxSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LibrivoxSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LibrivoxSectionCopyWith<LibrivoxSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LibrivoxSectionCopyWith<$Res> {
  factory $LibrivoxSectionCopyWith(
    LibrivoxSection value,
    $Res Function(LibrivoxSection) then,
  ) = _$LibrivoxSectionCopyWithImpl<$Res, LibrivoxSection>;
  @useResult
  $Res call({String? title, String listenUrl, int? playtimeSecs});
}

/// @nodoc
class _$LibrivoxSectionCopyWithImpl<$Res, $Val extends LibrivoxSection>
    implements $LibrivoxSectionCopyWith<$Res> {
  _$LibrivoxSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LibrivoxSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? listenUrl = null,
    Object? playtimeSecs = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            listenUrl: null == listenUrl
                ? _value.listenUrl
                : listenUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            playtimeSecs: freezed == playtimeSecs
                ? _value.playtimeSecs
                : playtimeSecs // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LibrivoxSectionImplCopyWith<$Res>
    implements $LibrivoxSectionCopyWith<$Res> {
  factory _$$LibrivoxSectionImplCopyWith(
    _$LibrivoxSectionImpl value,
    $Res Function(_$LibrivoxSectionImpl) then,
  ) = __$$LibrivoxSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? title, String listenUrl, int? playtimeSecs});
}

/// @nodoc
class __$$LibrivoxSectionImplCopyWithImpl<$Res>
    extends _$LibrivoxSectionCopyWithImpl<$Res, _$LibrivoxSectionImpl>
    implements _$$LibrivoxSectionImplCopyWith<$Res> {
  __$$LibrivoxSectionImplCopyWithImpl(
    _$LibrivoxSectionImpl _value,
    $Res Function(_$LibrivoxSectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LibrivoxSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? listenUrl = null,
    Object? playtimeSecs = freezed,
  }) {
    return _then(
      _$LibrivoxSectionImpl(
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        listenUrl: null == listenUrl
            ? _value.listenUrl
            : listenUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        playtimeSecs: freezed == playtimeSecs
            ? _value.playtimeSecs
            : playtimeSecs // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LibrivoxSectionImpl implements _LibrivoxSection {
  const _$LibrivoxSectionImpl({
    this.title,
    required this.listenUrl,
    this.playtimeSecs,
  });

  factory _$LibrivoxSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LibrivoxSectionImplFromJson(json);

  @override
  final String? title;
  @override
  final String listenUrl;
  @override
  final int? playtimeSecs;

  @override
  String toString() {
    return 'LibrivoxSection(title: $title, listenUrl: $listenUrl, playtimeSecs: $playtimeSecs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LibrivoxSectionImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.listenUrl, listenUrl) ||
                other.listenUrl == listenUrl) &&
            (identical(other.playtimeSecs, playtimeSecs) ||
                other.playtimeSecs == playtimeSecs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, listenUrl, playtimeSecs);

  /// Create a copy of LibrivoxSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LibrivoxSectionImplCopyWith<_$LibrivoxSectionImpl> get copyWith =>
      __$$LibrivoxSectionImplCopyWithImpl<_$LibrivoxSectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LibrivoxSectionImplToJson(this);
  }
}

abstract class _LibrivoxSection implements LibrivoxSection {
  const factory _LibrivoxSection({
    final String? title,
    required final String listenUrl,
    final int? playtimeSecs,
  }) = _$LibrivoxSectionImpl;

  factory _LibrivoxSection.fromJson(Map<String, dynamic> json) =
      _$LibrivoxSectionImpl.fromJson;

  @override
  String? get title;
  @override
  String get listenUrl;
  @override
  int? get playtimeSecs;

  /// Create a copy of LibrivoxSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LibrivoxSectionImplCopyWith<_$LibrivoxSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
