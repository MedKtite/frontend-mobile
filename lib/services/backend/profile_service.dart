import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/user.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  Future<User> getProfile() async {
    final res = await _dio.get<Map<String, dynamic>>('/me/profile');
    return User.fromJson(res.data ?? {});
  }

  Future<User> updateProfile({
    required String displayName,
    String? shortName,
    String? timezone,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/me/profile',
      data: {
        'display_name': displayName,
        if (shortName != null) 'short_name': shortName,
        if (timezone != null) 'timezone': timezone,
      },
    );
    return User.fromJson(res.data ?? {});
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      '/me/password',
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<void> deleteAccount() async {
    await _dio.delete<void>('/me');
  }

  Future<User> uploadAvatar({
    required List<int> bytes,
    required String filename,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final res = await _dio.post<Map<String, dynamic>>(
      '/me/avatar',
      data: formData,
    );
    return User.fromJson(res.data ?? {});
  }

  Future<User> deleteAvatar() async {
    final res = await _dio.delete<Map<String, dynamic>>('/me/avatar');
    return User.fromJson(res.data ?? {});
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(dioProvider));
});
