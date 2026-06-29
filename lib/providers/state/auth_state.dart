import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/user.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.restoring() = AuthRestoring;
  const factory AuthState.unauthenticated({String? message}) =
      AuthUnauthenticated;
  const factory AuthState.authenticated(User user) = AuthAuthenticated;
  const factory AuthState.loading() = AuthLoading;
}
