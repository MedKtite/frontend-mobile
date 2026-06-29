import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routes.dart';
import 'app/theme/app_theme.dart';
import 'core/dio_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dio needs a writable directory for the persistent cookie jar (mobile /
  // desktop). If that isn't available (e.g. web), boot without it — splash and
  // onboarding don't touch the network; auth screens do and require mobile.
  final overrides = <Override>[];
  try {
    final dio = await DioFactory.create();
    overrides.add(dioProvider.overrideWithValue(dio));
  } catch (e) {
    debugPrint('Dio bootstrap skipped (auth disabled until available): $e');
  }

  runApp(ProviderScope(overrides: overrides, child: const MarginaliaApp()));
}

class MarginaliaApp extends StatelessWidget {
  const MarginaliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Marginalia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
