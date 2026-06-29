// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'oauth_login_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OAuthLoginRequest _$OAuthLoginRequestFromJson(Map<String, dynamic> json) {
  return _OAuthLoginRequest.fromJson(json);
}

/// @nodoc
mixin _$OAuthLoginRequest {
  String get token => throw _privateConstructorUsedError;
  String? get timezone => throw _privateConstructorUsedError;

  /// Serializes this OAuthLoginRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OAuthLoginRequestCopyWith<OAuthLoginRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OAuthLoginRequestCopyWith<$Res> {
  factory $OAuthLoginRequestCopyWith(
    OAuthLoginRequest value,
    $Res Function(OAuthLoginRequest) then,
  ) = _$OAuthLoginRequestCopyWithImpl<$Res, OAuthLoginRequest>;
  @useResult
  $Res call({String token, String? timezone});
}

/// @nodoc
class _$OAuthLoginRequestCopyWithImpl<$Res, $Val extends OAuthLoginRequest>
    implements $OAuthLoginRequestCopyWith<$Res> {
  _$OAuthLoginRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null, Object? timezone = freezed}) {
    return _then(
      _value.copyWith(
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            timezone: freezed == timezone
                ? _value.timezone
                : timezone // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OAuthLoginRequestImplCopyWith<$Res>
    implements $OAuthLoginRequestCopyWith<$Res> {
  factory _$$OAuthLoginRequestImplCopyWith(
    _$OAuthLoginRequestImpl value,
    $Res Function(_$OAuthLoginRequestImpl) then,
  ) = __$$OAuthLoginRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String? timezone});
}

/// @nodoc
class __$$OAuthLoginRequestImplCopyWithImpl<$Res>
    extends _$OAuthLoginRequestCopyWithImpl<$Res, _$OAuthLoginRequestImpl>
    implements _$$OAuthLoginRequestImplCopyWith<$Res> {
  __$$OAuthLoginRequestImplCopyWithImpl(
    _$OAuthLoginRequestImpl _value,
    $Res Function(_$OAuthLoginRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? token = null, Object? timezone = freezed}) {
    return _then(
      _$OAuthLoginRequestImpl(
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        timezone: freezed == timezone
            ? _value.timezone
            : timezone // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OAuthLoginRequestImpl implements _OAuthLoginRequest {
  const _$OAuthLoginRequestImpl({required this.token, this.timezone});

  factory _$OAuthLoginRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OAuthLoginRequestImplFromJson(json);

  @override
  final String token;
  @override
  final String? timezone;

  @override
  String toString() {
    return 'OAuthLoginRequest(token: $token, timezone: $timezone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OAuthLoginRequestImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, timezone);

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OAuthLoginRequestImplCopyWith<_$OAuthLoginRequestImpl> get copyWith =>
      __$$OAuthLoginRequestImplCopyWithImpl<_$OAuthLoginRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OAuthLoginRequestImplToJson(this);
  }
}

abstract class _OAuthLoginRequest implements OAuthLoginRequest {
  const factory _OAuthLoginRequest({
    required final String token,
    final String? timezone,
  }) = _$OAuthLoginRequestImpl;

  factory _OAuthLoginRequest.fromJson(Map<String, dynamic> json) =
      _$OAuthLoginRequestImpl.fromJson;

  @override
  String get token;
  @override
  String? get timezone;

  /// Create a copy of OAuthLoginRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OAuthLoginRequestImplCopyWith<_$OAuthLoginRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
