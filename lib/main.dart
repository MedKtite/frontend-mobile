import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'app/routes.dart';
import 'app/theme/app_theme.dart';
import 'core/dio_client.dart';
import 'core/widgets/app_background.dart';
import 'providers/theme_provider.dart';
import 'services/frontend/launch_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Safari can deny browser storage (notably in private browsing or with
  // strict content blockers). Startup must still mount the app; otherwise an
  // exception here leaves the browser on a blank white page before runApp.
  var isFirstLaunch = true;
  try {
    isFirstLaunch = await LaunchService.consumeFirstLaunch();
  } catch (e) {
    debugPrint('Launch preference unavailable; using first-launch flow: $e');
  }

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

  runApp(
    ProviderScope(
      overrides: overrides,
      child: MarginaliaApp(isFirstLaunch: isFirstLaunch),
    ),
  );
}

class MarginaliaApp extends ConsumerWidget {
  MarginaliaApp({super.key, required bool isFirstLaunch})
    : router = createAppRouter(isFirstLaunch: isFirstLaunch);

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Marginalia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeProvider),
      routerConfig: router,
      builder: (context, child) =>
          AppBackground(child: child ?? const SizedBox.shrink()),
    );
  }
}
