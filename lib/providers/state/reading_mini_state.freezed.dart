// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_mini_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ReadingMiniSession {
  Book get book => throw _privateConstructorUsedError;
  double get pct => throw _privateConstructorUsedError; // 0–100
  String get label => throw _privateConstructorUsedError;

  /// Create a copy of ReadingMiniSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReadingMiniSessionCopyWith<ReadingMiniSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReadingMiniSessionCopyWith<$Res> {
  factory $ReadingMiniSessionCopyWith(
    ReadingMiniSession value,
    $Res Function(ReadingMiniSession) then,
  ) = _$ReadingMiniSessionCopyWithImpl<$Res, ReadingMiniSession>;
  @useResult
  $Res call({Book book, double pct, String label});

  $BookCopyWith<$Res> get book;
}

/// @nodoc
class _$ReadingMiniSessionCopyWithImpl<$Res, $Val extends ReadingMiniSession>
    implements $ReadingMiniSessionCopyWith<$Res> {
  _$ReadingMiniSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReadingMiniSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? book = null, Object? pct = null, Object? label = null}) {
    return _then(
      _value.copyWith(
            book: null == book
                ? _value.book
                : book // ignore: cast_nullable_to_non_nullable
                      as Book,
            pct: null == pct
                ? _value.pct
                : pct // ignore: cast_nullable_to_non_nullable
                      as double,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of ReadingMiniSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BookCopyWith<$Res> get book {
    return $BookCopyWith<$Res>(_value.book, (value) {
      return _then(_value.copyWith(book: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReadingMiniSessionImplCopyWith<$Res>
    implements $ReadingMiniSessionCopyWith<$Res> {
  factory _$$ReadingMiniSessionImplCopyWith(
    _$ReadingMiniSessionImpl value,
    $Res Function(_$ReadingMiniSessionImpl) then,
  ) = __$$ReadingMiniSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Book book, double pct, String label});

  @override
  $BookCopyWith<$Res> get book;
}

/// @nodoc
class __$$ReadingMiniSessionImplCopyWithImpl<$Res>
    extends _$ReadingMiniSessionCopyWithImpl<$Res, _$ReadingMiniSessionImpl>
    implements _$$ReadingMiniSessionImplCopyWith<$Res> {
  __$$ReadingMiniSessionImplCopyWithImpl(
    _$ReadingMiniSessionImpl _value,
    $Res Function(_$ReadingMiniSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReadingMiniSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? book = null, Object? pct = null, Object? label = null}) {
    return _then(
      _$ReadingMiniSessionImpl(
        book: null == book
            ? _value.book
            : book // ignore: cast_nullable_to_non_nullable
                  as Book,
        pct: null == pct
            ? _value.pct
            : pct // ignore: cast_nullable_to_non_nullable
                  as double,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ReadingMiniSessionImpl implements _ReadingMiniSession {
  const _$ReadingMiniSessionImpl({
    required this.book,
    required this.pct,
    required this.label,
  });

  @override
  final Book book;
  @override
  final double pct;
  // 0–100
  @override
  final String label;

  @override
  String toString() {
    return 'ReadingMiniSession(book: $book, pct: $pct, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingMiniSessionImpl &&
            (identical(other.book, book) || other.book == book) &&
            (identical(other.pct, pct) || other.pct == pct) &&
            (identical(other.label, label) || other.label == label));
  }

  @override
  int get hashCode => Object.hash(runtimeType, book, pct, label);

  /// Create a copy of ReadingMiniSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingMiniSessionImplCopyWith<_$ReadingMiniSessionImpl> get copyWith =>
      __$$ReadingMiniSessionImplCopyWithImpl<_$ReadingMiniSessionImpl>(
        this,
        _$identity,
      );
}

abstract class _ReadingMiniSession implements ReadingMiniSession {
  const factory _ReadingMiniSession({
    required final Book book,
    required final double pct,
    required final String label,
  }) = _$ReadingMiniSessionImpl;

  @override
  Book get book;
  @override
  double get pct; // 0–100
  @override
  String get label;

  /// Create a copy of ReadingMiniSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadingMiniSessionImplCopyWith<_$ReadingMiniSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
