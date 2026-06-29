// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presign_upload_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PresignUploadResponse _$PresignUploadResponseFromJson(
  Map<String, dynamic> json,
) {
  return _PresignUploadResponse.fromJson(json);
}

/// @nodoc
mixin _$PresignUploadResponse {
  String get fileKey => throw _privateConstructorUsedError;
  String get uploadUrl => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  String? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this PresignUploadResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresignUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresignUploadResponseCopyWith<PresignUploadResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresignUploadResponseCopyWith<$Res> {
  factory $PresignUploadResponseCopyWith(
    PresignUploadResponse value,
    $Res Function(PresignUploadResponse) then,
  ) = _$PresignUploadResponseCopyWithImpl<$Res, PresignUploadResponse>;
  @useResult
  $Res call({
    String fileKey,
    String uploadUrl,
    String method,
    String? expiresAt,
  });
}

/// @nodoc
class _$PresignUploadResponseCopyWithImpl<
  $Res,
  $Val extends PresignUploadResponse
>
    implements $PresignUploadResponseCopyWith<$Res> {
  _$PresignUploadResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresignUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileKey = null,
    Object? uploadUrl = null,
    Object? method = null,
    Object? expiresAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            fileKey: null == fileKey
                ? _value.fileKey
                : fileKey // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadUrl: null == uploadUrl
                ? _value.uploadUrl
                : uploadUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PresignUploadResponseImplCopyWith<$Res>
    implements $PresignUploadResponseCopyWith<$Res> {
  factory _$$PresignUploadResponseImplCopyWith(
    _$PresignUploadResponseImpl value,
    $Res Function(_$PresignUploadResponseImpl) then,
  ) = __$$PresignUploadResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String fileKey,
    String uploadUrl,
    String method,
    String? expiresAt,
  });
}

/// @nodoc
class __$$PresignUploadResponseImplCopyWithImpl<$Res>
    extends
        _$PresignUploadResponseCopyWithImpl<$Res, _$PresignUploadResponseImpl>
    implements _$$PresignUploadResponseImplCopyWith<$Res> {
  __$$PresignUploadResponseImplCopyWithImpl(
    _$PresignUploadResponseImpl _value,
    $Res Function(_$PresignUploadResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PresignUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fileKey = null,
    Object? uploadUrl = null,
    Object? method = null,
    Object? expiresAt = freezed,
  }) {
    return _then(
      _$PresignUploadResponseImpl(
        fileKey: null == fileKey
            ? _value.fileKey
            : fileKey // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadUrl: null == uploadUrl
            ? _value.uploadUrl
            : uploadUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PresignUploadResponseImpl implements _PresignUploadResponse {
  const _$PresignUploadResponseImpl({
    required this.fileKey,
    required this.uploadUrl,
    required this.method,
    this.expiresAt,
  });

  factory _$PresignUploadResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresignUploadResponseImplFromJson(json);

  @override
  final String fileKey;
  @override
  final String uploadUrl;
  @override
  final String method;
  @override
  final String? expiresAt;

  @override
  String toString() {
    return 'PresignUploadResponse(fileKey: $fileKey, uploadUrl: $uploadUrl, method: $method, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresignUploadResponseImpl &&
            (identical(other.fileKey, fileKey) || other.fileKey == fileKey) &&
            (identical(other.uploadUrl, uploadUrl) ||
                other.uploadUrl == uploadUrl) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fileKey, uploadUrl, method, expiresAt);

  /// Create a copy of PresignUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresignUploadResponseImplCopyWith<_$PresignUploadResponseImpl>
  get copyWith =>
      __$$PresignUploadResponseImplCopyWithImpl<_$PresignUploadResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PresignUploadResponseImplToJson(this);
  }
}

abstract class _PresignUploadResponse implements PresignUploadResponse {
  const factory _PresignUploadResponse({
    required final String fileKey,
    required final String uploadUrl,
    required final String method,
    final String? expiresAt,
  }) = _$PresignUploadResponseImpl;

  factory _PresignUploadResponse.fromJson(Map<String, dynamic> json) =
      _$PresignUploadResponseImpl.fromJson;

  @override
  String get fileKey;
  @override
  String get uploadUrl;
  @override
  String get method;
  @override
  String? get expiresAt;

  /// Create a copy of PresignUploadResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresignUploadResponseImplCopyWith<_$PresignUploadResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
