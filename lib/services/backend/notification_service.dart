import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/notification_model.dart';
import '../../models/notification_preferences_model.dart';

class NotificationService {
  final Dio _dio;

  NotificationService(this._dio);

  Future<List<NotificationItemModel>> getNotifications({
    String tab = 'all',
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/me/notifications',
      queryParameters: {
        'tab': tab,
        'limit': limit,
        'offset': offset,
      },
    );

    final data = res.data ?? [];
    return data
        .map((item) => NotificationItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final res = await _dio.get<Map<String, dynamic>>('/me/notifications/unread-count');
    return (res.data?['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markAsRead(String id) async {
    await _dio.patch<void>('/me/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _dio.patch<void>('/me/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete<void>('/me/notifications/$id');
  }

  Future<NotificationPreferencesModel> getPreferences() async {
    final res = await _dio.get<Map<String, dynamic>>('/me/notifications/preferences');
    return NotificationPreferencesModel.fromJson(res.data ?? {});
  }

  Future<NotificationPreferencesModel> updatePreferences(NotificationPreferencesModel prefs) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/me/notifications/preferences',
      data: prefs.toJson(),
    );
    return NotificationPreferencesModel.fromJson(res.data ?? {});
  }

  Future<void> registerDeviceToken({
    required String pushToken,
    required String platform,
    String? deviceName,
    String? pushPermission,
  }) async {
    await _dio.post<void>(
      '/me/devices',
      data: {
        'push_token': pushToken,
        'platform': platform,
        'device_name': deviceName,
        'push_permission': pushPermission ?? 'granted',
      },
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(dioProvider));
});
