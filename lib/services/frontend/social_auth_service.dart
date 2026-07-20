import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class SocialAuthException implements Exception {
  const SocialAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SocialAuthService {
  static const _googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
  static const _xClientId = String.fromEnvironment('X_CLIENT_ID');
  static const _xCallbackScheme = 'marginalia-auth';
  static const _xRedirectUri = '$_xCallbackScheme://oauth/x';

  bool _googleInitialized = false;

  Future<String?> signInWithGoogle() async {
    if (_googleServerClientId.isEmpty) {
      throw const SocialAuthException(
        'Google sign-in is not configured for this build.',
      );
    }
    try {
      if (!_googleInitialized) {
        await GoogleSignIn.instance.initialize(
          clientId: _googleClientId.isEmpty ? null : _googleClientId,
          serverClientId: _googleServerClientId,
        );
        _googleInitialized = true;
      }
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null || token.isEmpty) {
        throw const SocialAuthException(
          'Google did not return an identity token.',
        );
      }
      return token;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw SocialAuthException(e.description ?? 'Google sign-in failed.');
    }
  }

  Future<String?> signInWithX() async {
    if (_xClientId.isEmpty) {
      throw const SocialAuthException(
        'X sign-in is not configured for this build.',
      );
    }

    final verifier = _randomUrlSafeString(64);
    final challenge = base64Url
        .encode(sha256.convert(ascii.encode(verifier)).bytes)
        .replaceAll('=', '');
    final state = _randomUrlSafeString(32);
    final authorizationUri = Uri.https('x.com', '/i/oauth2/authorize', {
      'response_type': 'code',
      'client_id': _xClientId,
      'redirect_uri': _xRedirectUri,
      'scope': 'tweet.read users.read',
      'state': state,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    });

    String callback;
    try {
      callback = await FlutterWebAuth2.authenticate(
        url: authorizationUri.toString(),
        callbackUrlScheme: _xCallbackScheme,
      );
    } catch (e) {
      if (e.toString().toLowerCase().contains('cancel')) return null;
      throw const SocialAuthException('X sign-in could not be opened.');
    }

    final callbackUri = Uri.parse(callback);
    if (callbackUri.queryParameters['state'] != state) {
      throw const SocialAuthException('X sign-in response was invalid.');
    }
    final providerError = callbackUri.queryParameters['error'];
    if (providerError != null) {
      if (providerError == 'access_denied') return null;
      throw SocialAuthException('X sign-in failed: $providerError');
    }
    final code = callbackUri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const SocialAuthException('X did not return an authorization code.');
    }

    final response = await http.post(
      Uri.https('api.x.com', '/2/oauth2/token'),
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'code': code,
        'grant_type': 'authorization_code',
        'client_id': _xClientId,
        'redirect_uri': _xRedirectUri,
        'code_verifier': verifier,
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const SocialAuthException('X could not complete sign-in.');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final token = payload['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const SocialAuthException('X did not return an access token.');
    }
    return token;
  }

  String _randomUrlSafeString(int byteCount) {
    final random = Random.secure();
    final bytes = List<int>.generate(byteCount, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }
}
