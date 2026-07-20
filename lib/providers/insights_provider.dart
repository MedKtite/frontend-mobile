import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/insights_response.dart';
import '../services/backend/insights_service.dart';

final insightsProvider = FutureProvider<InsightsResponse>(
  (ref) => ref.watch(insightsServiceProvider).get(),
);
