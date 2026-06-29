import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/dio_client.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../services/backend/auth_service.dart';
import 'state/auth_state.dart';


class AuthController extends StateNotifier<AuthState> {
  final AuthService _service;

  AuthController(this._service) : super(const AuthState.initial()) {
    _restore();
  }

  Future<void> _restore() async {
    state = const AuthState.restoring();
    try {
      final user = await _service.refresh();
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
      );
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
    state = const AuthState.unauthenticated();
  }
}

final authProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});
