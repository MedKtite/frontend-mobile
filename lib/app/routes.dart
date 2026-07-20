import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marginalia/screens/notifications/notifications.dart';

import '../models/book.dart';
import '../models/catalog_book.dart';
import '../providers/auth_provider.dart';
import '../providers/state/auth_state.dart';
import '../screens/auth/check_email_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/discovery/discovery_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/library/author_details_screen.dart';
import '../screens/library/book_detail_screen.dart';
import '../screens/library/catalog_book_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/reading/reading_screen_web.dart'
    if (dart.library.io) '../screens/reading/reading_screen.dart';
import '../screens/listening/listening_screen.dart';
import '../screens/margins/margins_screen.dart';
import '../screens/settings/paywall_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../widgets/app_shell.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const checkEmail = '/check-email';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const discovery = '/discovery';

  /// Margins — the annotation hub (was the Search tab).
  static const margins = '/margins';
  static const library = '/library';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const insights = '/insights';

  /// Marginalia Pro paywall — store IAP via RevenueCat.
  static const paywall = '/paywall';

  static const reading = '/reading';
  static String readingPath(String bookId) => '$reading/$bookId';
  static String readingSamplePath({
    required String identifier,
    required String title,
  }) => Uri(
    path: readingPath('sample'),
    queryParameters: {'sampleIdentifier': identifier, 'sampleTitle': title},
  ).toString();

  /// Full-screen audio player (Figma 235:2 "Reading · audio").
  static const listening = '/listening';
  static String listeningPath(String bookId) => '$listening/$bookId';

  static const catalogBook = '/catalog-book';

  /// Owned-book detail page (library tap → here → reader). Full [Book] via extra.
  static const bookDetail = '/book-detail';

  /// Author profile (portrait, bio, books). Author display name via extra.
  static const author = '/author';
}

GoRouter createAppRouter({required bool isFirstLaunch}) => GoRouter(
  initialLocation: isFirstLaunch ? Routes.onboarding : Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const _StartupSplash(),
    ),
    GoRoute(
      path: Routes.onboarding,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const _AuthGuard(child: LoginScreen()),
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => const _AuthGuard(child: RegisterScreen()),
    ),
    GoRoute(
      path: Routes.forgotPassword,
      builder: (context, state) => _AuthGuard(
        child: ForgotPasswordScreen(initialEmail: state.extra as String? ?? ''),
      ),
    ),
    GoRoute(
      path: Routes.checkEmail,
      builder: (context, state) => _AuthGuard(
        child: CheckEmailScreen(email: state.extra as String? ?? ''),
      ),
    ),
    GoRoute(
      path: Routes.resetPassword,
      builder: (context, state) =>
          ResetPasswordScreen(token: state.uri.queryParameters['token'] ?? ''),
    ),
    // The main tabs live inside ONE persistent shell: the glass nav bar
    // is built once (in AppShell) and never rebuilds on tab switches; each
    // branch keeps its own state (scroll, search text) in an IndexedStack.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(shell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.discovery,
              builder: (context, state) => DiscoveryScreen(
                initialCategory: state.uri.queryParameters['category'],
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.library,
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.margins,
              builder: (context, state) => const MarginsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.insights,
              builder: (context, state) => const InsightsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: Routes.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: Routes.paywall,
      builder: (context, state) => const PaywallScreen(),
    ),
    GoRoute(
      path: Routes.author,
      builder: (context, state) =>
          AuthorDetailsScreen(name: state.extra as String),
    ),
    GoRoute(
      path: Routes.bookDetail,
      builder: (context, state) => BookDetailScreen(book: state.extra as Book),
    ),
    GoRoute(
      path: Routes.catalogBook,
      builder: (context, state) =>
          CatalogBookScreen(book: state.extra as CatalogBook),
    ),
    GoRoute(
      path: '${Routes.reading}/:bookId',
      builder: (context, state) => ReadingScreen(
        bookId: state.pathParameters['bookId']!,
        initialBook: state.extra as Book?,
        sampleIdentifier: state.uri.queryParameters['sampleIdentifier'],
        sampleTitle: state.uri.queryParameters['sampleTitle'],
      ),
    ),
    GoRoute(
      path: '${Routes.listening}/:bookId',
      builder: (context, state) => ListeningScreen(
        bookId: state.pathParameters['bookId']!,
        initialBook: state.extra as Book?,
      ),
    ),
  ],
);

class _StartupSplash extends ConsumerStatefulWidget {
  const _StartupSplash();

  @override
  ConsumerState<_StartupSplash> createState() => _StartupSplashState();
}

class _StartupSplashState extends ConsumerState<_StartupSplash> {
  bool _splashComplete = false;
  bool _navigated = false;

  void _continueFrom(AuthState auth) {
    if (!_splashComplete || _navigated || !mounted) return;

    final destination = switch (auth) {
      AuthAuthenticated() => Routes.home,
      AuthUnauthenticated() => Routes.login,
      _ => null,
    };
    if (destination == null) return;

    _navigated = true;
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    ref.listen<AuthState>(authProvider, (_, next) => _continueFrom(next));

    return SplashScreen(
      onComplete: () {
        _splashComplete = true;
        _continueFrom(auth);
      },
    );
  }
}

/// Auth pages never flash for a session already restored from its cookies.
class _AuthGuard extends ConsumerWidget {
  const _AuthGuard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (auth is AuthAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(Routes.home);
      });
      return const SizedBox.shrink();
    }
    if (auth is AuthInitial || auth is AuthRestoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return child;
  }
}
