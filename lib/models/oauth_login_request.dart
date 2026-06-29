import 'package:freezed_annotation/freezed_annotation.dart';

part 'oauth_login_request.freezed.dart';
part 'oauth_login_request.g.dart';

/// Body of POST /auth/oauth/google and /auth/oauth/x.
/// [token] is the provider's ID/access token; the backend verifies it.
@freezed
class OAuthLoginRequest with _$OAuthLoginRequest {
  const factory OAuthLoginRequest({
    required String token,
    String? timezone,
  }) = _OAuthLoginRequest;

  factory OAuthLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$OAuthLoginRequestFromJson(json);
}
