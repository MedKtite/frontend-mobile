import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/subscription.dart';

/// Raw HTTP for /me/subscription. The tier is WRITTEN only by the RevenueCat
/// webhook on the backend — the client just reads it.
class SubscriptionService {
  final Dio _dio;
  SubscriptionService(this._dio);

  Future<Subscription> get() async {
    final res = await _dio.get<Map<String, dynamic>>('/me/subscription');
    return Subscription.fromJson(res.data ?? const {});
  }
}

final subscriptionServiceProvider = Provider<SubscriptionService>(
    (ref) => SubscriptionService(ref.watch(dioProvider)));
