import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dio_client.dart';
import '../models/login_request.dart';
import '../models/oauth_login_request.dart';
import '../models/register_request.dart';
import '../models/user.dart';
import '../services/backend/auth_service.dart';
import '../services/backend/book_service.dart';
import 'state/auth_state.dart';


class AuthController extends StateNotifier<AuthState> {
  final AuthService _service;
  final BookService _books;

  AuthController(this._service, this._books) : super(const AuthState.initial()) {
    _restore();
  }

  Future<void> _restore() async {
    state = const AuthState.restoring();
    try {
      final user = await _service.refresh();
      _books.clearListCache();
      state = AuthState.authenticated(user);
    } on ApiError {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final user = await _service.login(
        LoginRequest(email: email, password: password),
      );
      _books.clearListCache();
      state = AuthState.authenticated(user);
    } on ApiError catch (e) {
      state = AuthState.unauthenticated(message: e.message);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    String? timezone,
    bool emailUpdates = false,
  }) async {
    state = const AuthState.loading();
    try {
      final user = await _service.register(
        RegisterRequest(
          email: email,
          password: password,
          displayName: displayName,
          timezone: timezone,
        ),
        emailUpdates: emailUpdates,
      );
      _books.clearListCache();
      state = AuthState.authenticated(user);
    } on ApiError catch (e) {
      state = AuthState.unauthenticated(message: e.message);
    }
  }

  Future<void> loginWithGoogle({required String token, String? timezone}) async {
    await _oauthLogin(
      OAuthLoginRequest(token: token, timezone: timezone),
      _service.loginWithGoogle,
    );
  }

  Future<void> loginWithX({required String token, String? timezone}) async {
    await _oauthLogin(
      OAuthLoginRequest(token: token, timezone: timezone),
      _service.loginWithX,
    );
  }

  Future<void> _oauthLogin(
    OAuthLoginRequest request,
    Future<User> Function(OAuthLoginRequest) login,
  ) async {
    state = const AuthState.loading();
    try {
      final user = await login(request);
      _books.clearListCache();
      state = AuthState.authenticated(user);
    } on ApiError catch (e) {
      state = AuthState.unauthenticated(message: e.message);
    }
  }

  Future<void> logout() async {
    // Best-effort — clear the session locally regardless of the call's outcome.
    try {
      await _service.logout();
    } on ApiError {
      // ignored
    }
    _books.clearListCache();
    state = const AuthState.unauthenticated();
  }

  Future<bool> requestPasswordReset({required String email}) async {
    state = const AuthState.loading();
    try {
      await _service.requestPasswordReset(email);
      state = const AuthState.unauthenticated();
      return true;
    } on ApiError catch (e) {
      state = AuthState.unauthenticated(message: e.message);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      await _service.resetPassword(token: token, password: password);
      state = const AuthState.unauthenticated();
      return true;
    } on ApiError catch (e) {
      state = AuthState.unauthenticated(message: e.message);
      return false;
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(authServiceProvider),
    ref.watch(bookServiceProvider),
  );
});
