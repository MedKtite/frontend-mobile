import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_client.dart';
import '../../models/insights_response.dart';

class InsightsService {
  const InsightsService(this._dio);

  final Dio _dio;

  Future<InsightsResponse> get() async {
    final response = await _dio.get<Map<String, dynamic>>('/me/insights');
    return InsightsResponse.fromJson(response.data!);
  }
}

final insightsServiceProvider = Provider<InsightsService>(
  (ref) => InsightsService(ref.watch(dioProvider)),
);
