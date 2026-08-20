import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';

class SupportService {
  final Dio _dio;

  SupportService(this._dio);

  Future<Map<String, dynamic>> submitFeedback({
    required String category,
    required String message,
    String? email,
    String? appVersion,
    String? deviceModel,
    String? osVersion,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/support/feedback',
      data: {
        'category': category,
        'message': message,
        if (email != null) 'email': email,
        if (appVersion != null) 'app_version': appVersion,
        if (deviceModel != null) 'device_model': deviceModel,
        if (osVersion != null) 'os_version': osVersion,
      },
    );
    return res.data ?? {};
  }
}

final supportServiceProvider = Provider<SupportService>((ref) {
  return SupportService(ref.watch(dioProvider));
});
