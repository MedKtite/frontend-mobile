// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download_url_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DownloadUrlResponse _$DownloadUrlResponseFromJson(Map<String, dynamic> json) {
  return _DownloadUrlResponse.fromJson(json);
}

/// @nodoc
mixin _$DownloadUrlResponse {
  String get downloadUrl => throw _privateConstructorUsedError;
  String? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this DownloadUrlResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadUrlResponseCopyWith<DownloadUrlResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadUrlResponseCopyWith<$Res> {
  factory $DownloadUrlResponseCopyWith(
    DownloadUrlResponse value,
    $Res Function(DownloadUrlResponse) then,
  ) = _$DownloadUrlResponseCopyWithImpl<$Res, DownloadUrlResponse>;
  @useResult
  $Res call({String downloadUrl, String? expiresAt});
}

/// @nodoc
class _$DownloadUrlResponseCopyWithImpl<$Res, $Val extends DownloadUrlResponse>
    implements $DownloadUrlResponseCopyWith<$Res> {
  _$DownloadUrlResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? downloadUrl = null, Object? expiresAt = freezed}) {
    return _then(
      _value.copyWith(
            downloadUrl: null == downloadUrl
                ? _value.downloadUrl
                : downloadUrl // ignore: cast_nullable_to_non_nullable
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
abstract class _$$DownloadUrlResponseImplCopyWith<$Res>
    implements $DownloadUrlResponseCopyWith<$Res> {
  factory _$$DownloadUrlResponseImplCopyWith(
    _$DownloadUrlResponseImpl value,
    $Res Function(_$DownloadUrlResponseImpl) then,
  ) = __$$DownloadUrlResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String downloadUrl, String? expiresAt});
}

/// @nodoc
class __$$DownloadUrlResponseImplCopyWithImpl<$Res>
    extends _$DownloadUrlResponseCopyWithImpl<$Res, _$DownloadUrlResponseImpl>
    implements _$$DownloadUrlResponseImplCopyWith<$Res> {
  __$$DownloadUrlResponseImplCopyWithImpl(
    _$DownloadUrlResponseImpl _value,
    $Res Function(_$DownloadUrlResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? downloadUrl = null, Object? expiresAt = freezed}) {
    return _then(
      _$DownloadUrlResponseImpl(
        downloadUrl: null == downloadUrl
            ? _value.downloadUrl
            : downloadUrl // ignore: cast_nullable_to_non_nullable
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
class _$DownloadUrlResponseImpl implements _DownloadUrlResponse {
  const _$DownloadUrlResponseImpl({required this.downloadUrl, this.expiresAt});

  factory _$DownloadUrlResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadUrlResponseImplFromJson(json);

  @override
  final String downloadUrl;
  @override
  final String? expiresAt;

  @override
  String toString() {
    return 'DownloadUrlResponse(downloadUrl: $downloadUrl, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadUrlResponseImpl &&
            (identical(other.downloadUrl, downloadUrl) ||
                other.downloadUrl == downloadUrl) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, downloadUrl, expiresAt);

  /// Create a copy of DownloadUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadUrlResponseImplCopyWith<_$DownloadUrlResponseImpl> get copyWith =>
      __$$DownloadUrlResponseImplCopyWithImpl<_$DownloadUrlResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadUrlResponseImplToJson(this);
  }
}

abstract class _DownloadUrlResponse implements DownloadUrlResponse {
  const factory _DownloadUrlResponse({
    required final String downloadUrl,
    final String? expiresAt,
  }) = _$DownloadUrlResponseImpl;

  factory _DownloadUrlResponse.fromJson(Map<String, dynamic> json) =
      _$DownloadUrlResponseImpl.fromJson;

  @override
  String get downloadUrl;
  @override
  String? get expiresAt;

  /// Create a copy of DownloadUrlResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadUrlResponseImplCopyWith<_$DownloadUrlResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
