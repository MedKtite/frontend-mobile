// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_create_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NoteCreateRequest _$NoteCreateRequestFromJson(Map<String, dynamic> json) {
  return _NoteCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$NoteCreateRequest {
  String get bookId => throw _privateConstructorUsedError;
  String get bodyMd => throw _privateConstructorUsedError;
  String? get highlightId => throw _privateConstructorUsedError;

  /// Serializes this NoteCreateRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteCreateRequestCopyWith<NoteCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteCreateRequestCopyWith<$Res> {
  factory $NoteCreateRequestCopyWith(
    NoteCreateRequest value,
    $Res Function(NoteCreateRequest) then,
  ) = _$NoteCreateRequestCopyWithImpl<$Res, NoteCreateRequest>;
  @useResult
  $Res call({String bookId, String bodyMd, String? highlightId});
}

/// @nodoc
class _$NoteCreateRequestCopyWithImpl<$Res, $Val extends NoteCreateRequest>
    implements $NoteCreateRequestCopyWith<$Res> {
  _$NoteCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? bodyMd = null,
    Object? highlightId = freezed,
  }) {
    return _then(
      _value.copyWith(
            bookId: null == bookId
                ? _value.bookId
                : bookId // ignore: cast_nullable_to_non_nullable
                      as String,
            bodyMd: null == bodyMd
                ? _value.bodyMd
                : bodyMd // ignore: cast_nullable_to_non_nullable
                      as String,
            highlightId: freezed == highlightId
                ? _value.highlightId
                : highlightId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoteCreateRequestImplCopyWith<$Res>
    implements $NoteCreateRequestCopyWith<$Res> {
  factory _$$NoteCreateRequestImplCopyWith(
    _$NoteCreateRequestImpl value,
    $Res Function(_$NoteCreateRequestImpl) then,
  ) = __$$NoteCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String bookId, String bodyMd, String? highlightId});
}

/// @nodoc
class __$$NoteCreateRequestImplCopyWithImpl<$Res>
    extends _$NoteCreateRequestCopyWithImpl<$Res, _$NoteCreateRequestImpl>
    implements _$$NoteCreateRequestImplCopyWith<$Res> {
  __$$NoteCreateRequestImplCopyWithImpl(
    _$NoteCreateRequestImpl _value,
    $Res Function(_$NoteCreateRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookId = null,
    Object? bodyMd = null,
    Object? highlightId = freezed,
  }) {
    return _then(
      _$NoteCreateRequestImpl(
        bookId: null == bookId
            ? _value.bookId
            : bookId // ignore: cast_nullable_to_non_nullable
                  as String,
        bodyMd: null == bodyMd
            ? _value.bodyMd
            : bodyMd // ignore: cast_nullable_to_non_nullable
                  as String,
        highlightId: freezed == highlightId
            ? _value.highlightId
            : highlightId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoteCreateRequestImpl implements _NoteCreateRequest {
  const _$NoteCreateRequestImpl({
    required this.bookId,
    required this.bodyMd,
    this.highlightId,
  });

  factory _$NoteCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoteCreateRequestImplFromJson(json);

  @override
  final String bookId;
  @override
  final String bodyMd;
  @override
  final String? highlightId;

  @override
  String toString() {
    return 'NoteCreateRequest(bookId: $bookId, bodyMd: $bodyMd, highlightId: $highlightId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteCreateRequestImpl &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.bodyMd, bodyMd) || other.bodyMd == bodyMd) &&
            (identical(other.highlightId, highlightId) ||
                other.highlightId == highlightId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, bookId, bodyMd, highlightId);

  /// Create a copy of NoteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteCreateRequestImplCopyWith<_$NoteCreateRequestImpl> get copyWith =>
      __$$NoteCreateRequestImplCopyWithImpl<_$NoteCreateRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NoteCreateRequestImplToJson(this);
  }
}

abstract class _NoteCreateRequest implements NoteCreateRequest {
  const factory _NoteCreateRequest({
    required final String bookId,
    required final String bodyMd,
    final String? highlightId,
  }) = _$NoteCreateRequestImpl;

  factory _NoteCreateRequest.fromJson(Map<String, dynamic> json) =
      _$NoteCreateRequestImpl.fromJson;

  @override
  String get bookId;
  @override
  String get bodyMd;
  @override
  String? get highlightId;

  /// Create a copy of NoteCreateRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteCreateRequestImplCopyWith<_$NoteCreateRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
