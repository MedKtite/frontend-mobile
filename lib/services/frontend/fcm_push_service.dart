import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../backend/notification_service.dart';

/// Service responsible for managing Firebase Cloud Messaging (FCM) on device.
/// Designed to fail gracefully when Firebase configuration / credentials are not yet wired,
/// allowing the app to operate seamlessly in offline/mock mode.
class FcmPushService {
  final NotificationService _notificationService;

  FcmPushService(this._notificationService);

  Future<void> initialize() async {
    try {
      if (kIsWeb) return;

      final platform = Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
              ? 'android'
              : 'web';

      // Example registration placeholder. When Firebase is initialized,
      // FirebaseMessaging.instance.getToken() provides the token.
      debugPrint('[FCM] Initialized push listener for platform: $platform');
    } catch (e) {
      debugPrint('[FCM] Push service initialization deferred: $e');
    }
  }

  Future<void> syncTokenWithBackend(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await _notificationService.registerDeviceToken(
        pushToken: token,
        platform: platform,
        deviceName: '${Platform.operatingSystem} device',
        pushPermission: 'granted',
      );
      debugPrint('[FCM] Device push token registered successfully with backend');
    } catch (e) {
      debugPrint('[FCM] Failed to sync push token with backend: $e');
    }
  }
}

final fcmPushServiceProvider = Provider<FcmPushService>((ref) {
  return FcmPushService(ref.watch(notificationServiceProvider));
});
