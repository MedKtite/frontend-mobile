// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presign_upload_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PresignUploadRequest _$PresignUploadRequestFromJson(Map<String, dynamic> json) {
  return _PresignUploadRequest.fromJson(json);
}

/// @nodoc
mixin _$PresignUploadRequest {
  String get format => throw _privateConstructorUsedError;
  String get contentType => throw _privateConstructorUsedError;
  int get contentLength => throw _privateConstructorUsedError;

  /// Serializes this PresignUploadRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresignUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresignUploadRequestCopyWith<PresignUploadRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresignUploadRequestCopyWith<$Res> {
  factory $PresignUploadRequestCopyWith(
    PresignUploadRequest value,
    $Res Function(PresignUploadRequest) then,
  ) = _$PresignUploadRequestCopyWithImpl<$Res, PresignUploadRequest>;
  @useResult
  $Res call({String format, String contentType, int contentLength});
}

/// @nodoc
class _$PresignUploadRequestCopyWithImpl<
  $Res,
  $Val extends PresignUploadRequest
>
    implements $PresignUploadRequestCopyWith<$Res> {
  _$PresignUploadRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresignUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? contentType = null,
    Object? contentLength = null,
  }) {
    return _then(
      _value.copyWith(
            format: null == format
                ? _value.format
                : format // ignore: cast_nullable_to_non_nullable
                      as String,
            contentType: null == contentType
                ? _value.contentType
                : contentType // ignore: cast_nullable_to_non_nullable
                      as String,
            contentLength: null == contentLength
                ? _value.contentLength
                : contentLength // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PresignUploadRequestImplCopyWith<$Res>
    implements $PresignUploadRequestCopyWith<$Res> {
  factory _$$PresignUploadRequestImplCopyWith(
    _$PresignUploadRequestImpl value,
    $Res Function(_$PresignUploadRequestImpl) then,
  ) = __$$PresignUploadRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String format, String contentType, int contentLength});
}

/// @nodoc
class __$$PresignUploadRequestImplCopyWithImpl<$Res>
    extends _$PresignUploadRequestCopyWithImpl<$Res, _$PresignUploadRequestImpl>
    implements _$$PresignUploadRequestImplCopyWith<$Res> {
  __$$PresignUploadRequestImplCopyWithImpl(
    _$PresignUploadRequestImpl _value,
    $Res Function(_$PresignUploadRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PresignUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? format = null,
    Object? contentType = null,
    Object? contentLength = null,
  }) {
    return _then(
      _$PresignUploadRequestImpl(
        format: null == format
            ? _value.format
            : format // ignore: cast_nullable_to_non_nullable
                  as String,
        contentType: null == contentType
            ? _value.contentType
            : contentType // ignore: cast_nullable_to_non_nullable
                  as String,
        contentLength: null == contentLength
            ? _value.contentLength
            : contentLength // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PresignUploadRequestImpl implements _PresignUploadRequest {
  const _$PresignUploadRequestImpl({
    required this.format,
    required this.contentType,
    required this.contentLength,
  });

  factory _$PresignUploadRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresignUploadRequestImplFromJson(json);

  @override
  final String format;
  @override
  final String contentType;
  @override
  final int contentLength;

  @override
  String toString() {
    return 'PresignUploadRequest(format: $format, contentType: $contentType, contentLength: $contentLength)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresignUploadRequestImpl &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.contentLength, contentLength) ||
                other.contentLength == contentLength));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, format, contentType, contentLength);

  /// Create a copy of PresignUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresignUploadRequestImplCopyWith<_$PresignUploadRequestImpl>
  get copyWith =>
      __$$PresignUploadRequestImplCopyWithImpl<_$PresignUploadRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PresignUploadRequestImplToJson(this);
  }
}

abstract class _PresignUploadRequest implements PresignUploadRequest {
  const factory _PresignUploadRequest({
    required final String format,
    required final String contentType,
    required final int contentLength,
  }) = _$PresignUploadRequestImpl;

  factory _PresignUploadRequest.fromJson(Map<String, dynamic> json) =
      _$PresignUploadRequestImpl.fromJson;

  @override
  String get format;
  @override
  String get contentType;
  @override
  int get contentLength;

  /// Create a copy of PresignUploadRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresignUploadRequestImplCopyWith<_$PresignUploadRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
