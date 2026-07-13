// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audio_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AudioSession {
  Book get book => throw _privateConstructorUsedError;

  /// Non-null when streaming a LibriVox playlist instead of an uploaded file.
  LibrivoxAudiobook? get librivox => throw _privateConstructorUsedError;

  /// Global start second of each playlist section (empty for single files).
  List<double> get cumStart => throw _privateConstructorUsedError;
  double get totalSecs => throw _privateConstructorUsedError;

  /// Create a copy of AudioSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AudioSessionCopyWith<AudioSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AudioSessionCopyWith<$Res> {
  factory $AudioSessionCopyWith(
    AudioSession value,
    $Res Function(AudioSession) then,
  ) = _$AudioSessionCopyWithImpl<$Res, AudioSession>;
  @useResult
  $Res call({
    Book book,
    LibrivoxAudiobook? librivox,
    List<double> cumStart,
    double totalSecs,
  });

  $BookCopyWith<$Res> get book;
  $LibrivoxAudiobookCopyWith<$Res>? get librivox;
}

/// @nodoc
class _$AudioSessionCopyWithImpl<$Res, $Val extends AudioSession>
    implements $AudioSessionCopyWith<$Res> {
  _$AudioSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AudioSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? book = null,
    Object? librivox = freezed,
    Object? cumStart = null,
    Object? totalSecs = null,
  }) {
    return _then(
      _value.copyWith(
            book: null == book
                ? _value.book
                : book // ignore: cast_nullable_to_non_nullable
                      as Book,
            librivox: freezed == librivox
                ? _value.librivox
                : librivox // ignore: cast_nullable_to_non_nullable
                      as LibrivoxAudiobook?,
            cumStart: null == cumStart
                ? _value.cumStart
                : cumStart // ignore: cast_nullable_to_non_nullable
                      as List<double>,
            totalSecs: null == totalSecs
                ? _value.totalSecs
                : totalSecs // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of AudioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookCopyWith<$Res> get book {
    return $BookCopyWith<$Res>(_value.book, (value) {
      return _then(_value.copyWith(book: value) as $Val);
    });
  }

  /// Create a copy of AudioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LibrivoxAudiobookCopyWith<$Res>? get librivox {
    if (_value.librivox == null) {
      return null;
    }

    return $LibrivoxAudiobookCopyWith<$Res>(_value.librivox!, (value) {
      return _then(_value.copyWith(librivox: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AudioSessionImplCopyWith<$Res>
    implements $AudioSessionCopyWith<$Res> {
  factory _$$AudioSessionImplCopyWith(
    _$AudioSessionImpl value,
    $Res Function(_$AudioSessionImpl) then,
  ) = __$$AudioSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Book book,
    LibrivoxAudiobook? librivox,
    List<double> cumStart,
    double totalSecs,
  });

  @override
  $BookCopyWith<$Res> get book;
  @override
  $LibrivoxAudiobookCopyWith<$Res>? get librivox;
}

/// @nodoc
class __$$AudioSessionImplCopyWithImpl<$Res>
    extends _$AudioSessionCopyWithImpl<$Res, _$AudioSessionImpl>
    implements _$$AudioSessionImplCopyWith<$Res> {
  __$$AudioSessionImplCopyWithImpl(
    _$AudioSessionImpl _value,
    $Res Function(_$AudioSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AudioSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? book = null,
    Object? librivox = freezed,
    Object? cumStart = null,
    Object? totalSecs = null,
  }) {
    return _then(
      _$AudioSessionImpl(
        book: null == book
            ? _value.book
            : book // ignore: cast_nullable_to_non_nullable
                  as Book,
        librivox: freezed == librivox
            ? _value.librivox
            : librivox // ignore: cast_nullable_to_non_nullable
                  as LibrivoxAudiobook?,
        cumStart: null == cumStart
            ? _value._cumStart
            : cumStart // ignore: cast_nullable_to_non_nullable
                  as List<double>,
        totalSecs: null == totalSecs
            ? _value.totalSecs
            : totalSecs // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$AudioSessionImpl implements _AudioSession {
  const _$AudioSessionImpl({
    required this.book,
    this.librivox,
    final List<double> cumStart = const <double>[],
    required this.totalSecs,
  }) : _cumStart = cumStart;

  @override
  final Book book;

  /// Non-null when streaming a LibriVox playlist instead of an uploaded file.
  @override
  final LibrivoxAudiobook? librivox;

  /// Global start second of each playlist section (empty for single files).
  final List<double> _cumStart;

  /// Global start second of each playlist section (empty for single files).
  @override
  @JsonKey()
  List<double> get cumStart {
    if (_cumStart is EqualUnmodifiableListView) return _cumStart;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cumStart);
  }

  @override
  final double totalSecs;

  @override
  String toString() {
    return 'AudioSession(book: $book, librivox: $librivox, cumStart: $cumStart, totalSecs: $totalSecs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioSessionImpl &&
            (identical(other.book, book) || other.book == book) &&
            (identical(other.librivox, librivox) ||
                other.librivox == librivox) &&
            const DeepCollectionEquality().equals(other._cumStart, _cumStart) &&
            (identical(other.totalSecs, totalSecs) ||
                other.totalSecs == totalSecs));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    book,
    librivox,
    const DeepCollectionEquality().hash(_cumStart),
    totalSecs,
  );

  /// Create a copy of AudioSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioSessionImplCopyWith<_$AudioSessionImpl> get copyWith =>
      __$$AudioSessionImplCopyWithImpl<_$AudioSessionImpl>(this, _$identity);
}

abstract class _AudioSession implements AudioSession {
  const factory _AudioSession({
    required final Book book,
    final LibrivoxAudiobook? librivox,
    final List<double> cumStart,
    required final double totalSecs,
  }) = _$AudioSessionImpl;

  @override
  Book get book;

  /// Non-null when streaming a LibriVox playlist instead of an uploaded file.
  @override
  LibrivoxAudiobook? get librivox;

  /// Global start second of each playlist section (empty for single files).
  @override
  List<double> get cumStart;
  @override
  double get totalSecs;

  /// Create a copy of AudioSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioSessionImplCopyWith<_$AudioSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
