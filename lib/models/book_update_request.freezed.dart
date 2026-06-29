// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book_update_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookUpdateRequest _$BookUpdateRequestFromJson(Map<String, dynamic> json) {
  return _BookUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$BookUpdateRequest {
  String? get status =>
      throw _privateConstructorUsedError; // reading | listening | finished | archived
  double? get progressPct => throw _privateConstructorUsedError;
  String? get cursor => throw _privateConstructorUsedError;

  /// Serializes this BookUpdateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookUpdateRequestCopyWith<BookUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookUpdateRequestCopyWith<$Res> {
  factory $BookUpdateRequestCopyWith(
    BookUpdateRequest value,
    $Res Function(BookUpdateRequest) then,
  ) = _$BookUpdateRequestCopyWithImpl<$Res, BookUpdateRequest>;
  @useResult
  $Res call({String? status, double? progressPct, String? cursor});
}

/// @nodoc
class _$BookUpdateRequestCopyWithImpl<$Res, $Val extends BookUpdateRequest>
    implements $BookUpdateRequestCopyWith<$Res> {
  _$BookUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? progressPct = freezed,
    Object? cursor = freezed,
  }) {
    return _then(
      _value.copyWith(
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            progressPct: freezed == progressPct
                ? _value.progressPct
                : progressPct // ignore: cast_nullable_to_non_nullable
                      as double?,
            cursor: freezed == cursor
                ? _value.cursor
                : cursor // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookUpdateRequestImplCopyWith<$Res>
    implements $BookUpdateRequestCopyWith<$Res> {
  factory _$$BookUpdateRequestImplCopyWith(
    _$BookUpdateRequestImpl value,
    $Res Function(_$BookUpdateRequestImpl) then,
  ) = __$$BookUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? status, double? progressPct, String? cursor});
}

/// @nodoc
class __$$BookUpdateRequestImplCopyWithImpl<$Res>
    extends _$BookUpdateRequestCopyWithImpl<$Res, _$BookUpdateRequestImpl>
    implements _$$BookUpdateRequestImplCopyWith<$Res> {
  __$$BookUpdateRequestImplCopyWithImpl(
    _$BookUpdateRequestImpl _value,
    $Res Function(_$BookUpdateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = freezed,
    Object? progressPct = freezed,
    Object? cursor = freezed,
  }) {
    return _then(
      _$BookUpdateRequestImpl(
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        progressPct: freezed == progressPct
            ? _value.progressPct
            : progressPct // ignore: cast_nullable_to_non_nullable
                  as double?,
        cursor: freezed == cursor
            ? _value.cursor
            : cursor // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookUpdateRequestImpl implements _BookUpdateRequest {
  const _$BookUpdateRequestImpl({this.status, this.progressPct, this.cursor});

  factory _$BookUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookUpdateRequestImplFromJson(json);

  @override
  final String? status;
  // reading | listening | finished | archived
  @override
  final double? progressPct;
  @override
  final String? cursor;

  @override
  String toString() {
    return 'BookUpdateRequest(status: $status, progressPct: $progressPct, cursor: $cursor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookUpdateRequestImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progressPct, progressPct) ||
                other.progressPct == progressPct) &&
            (identical(other.cursor, cursor) || other.cursor == cursor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, progressPct, cursor);

  /// Create a copy of BookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookUpdateRequestImplCopyWith<_$BookUpdateRequestImpl> get copyWith =>
      __$$BookUpdateRequestImplCopyWithImpl<_$BookUpdateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BookUpdateRequestImplToJson(this);
  }
}

abstract class _BookUpdateRequest implements BookUpdateRequest {
  const factory _BookUpdateRequest({
    final String? status,
    final double? progressPct,
    final String? cursor,
  }) = _$BookUpdateRequestImpl;

  factory _BookUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$BookUpdateRequestImpl.fromJson;

  @override
  String? get status; // reading | listening | finished | archived
  @override
  double? get progressPct;
  @override
  String? get cursor;

  /// Create a copy of BookUpdateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookUpdateRequestImplCopyWith<_$BookUpdateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
