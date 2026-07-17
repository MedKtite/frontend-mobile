import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/login_request.dart';
import '../../models/oauth_login_request.dart';
import '../../models/register_request.dart';
import '../../models/user.dart';


class AuthService {
  final Dio _dio;
  AuthService(this._dio);

  Future<User> register(RegisterRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: req.toJson(),
    );
    return User.fromJson(res.data!);
  }

  Future<User> login(LoginRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: req.toJson(),
    );
    return User.fromJson(res.data!);
  }

  Future<User> loginWithGoogle(OAuthLoginRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/oauth/google',
      data: req.toJson(),
    );
    return User.fromJson(res.data!);
  }

  Future<User> loginWithX(OAuthLoginRequest req) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/oauth/x',
      data: req.toJson(),
    );
    return User.fromJson(res.data!);
  }

  Future<User> refresh() async {
    final res = await _dio.post<Map<String, dynamic>>('/auth/refresh');
    return User.fromJson(res.data!);
  }

  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }

  Future<void> requestPasswordReset(String email) async {
    await _dio.post<void>(
      '/auth/password/forgot',
      data: {'email': email},
    );
  }

  Future<void> resetPassword({
    required String token,
    required String password,
  }) async {
    await _dio.post<void>(
      '/auth/password/reset',
      data: {'token': token, 'password': password},
    );
  }
}

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.watch(dioProvider)));
