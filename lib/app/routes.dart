import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../screens/auth/check_email_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/reading/reading_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';

/// Route vocabulary ([Routes]) and the app-wide [GoRouter] ([appRouter]) in one
/// file. Reference the [Routes] constants instead of bare strings so a typo is a
/// compile error and renames stay in one place. Screens import this file only
/// for the [Routes] vocabulary — the resulting screen↔routes import cycle is
/// resolved lazily by Dart and is harmless (no top-level init depends on it).
abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const checkEmail = '/check-email';
  static const resetPassword = '/reset-password';
  static const home = '/home';
  static const search = '/search';
  static const library = '/library';
  static const settings = '/settings';

  /// Reading view. The actual GoRoute path is `'$reading/:bookId'`; build a
  /// concrete location with [readingPath].
  static const reading = '/reading';
  static String readingPath(String bookId) => '$reading/$bookId';
}

/// App-wide [GoRouter]. Splash is the entry; it auto-advances into onboarding.
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => SplashScreen(
        // First launch → onboarding. (Returning user → Home once auth lands.)
        onComplete: () => context.go(Routes.onboarding),
      ),
    ),
    GoRoute(
      path: Routes.onboarding,
      // Dissolve in from the splash (§17 — the repeated wordmark morphs).
      // OnboardingScreen links to Login/Register itself (see its CTAs).
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
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: Routes.forgotPassword,
      builder: (context, state) =>
          ForgotPasswordScreen(initialEmail: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: Routes.checkEmail,
      builder: (context, state) =>
          CheckEmailScreen(email: state.extra as String? ?? ''),
    ),
    GoRoute(
      path: Routes.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: Routes.library,
      // The Add sheet can request the search field be focused on arrival.
      builder: (context, state) =>
          LibraryScreen(autofocusSearch: state.extra as bool? ?? false),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      // Library hands over the full Book via `extra`; Home passes only the id
      // (ReadingScreen fetches it). Push onto the current tab so back returns.
      path: '${Routes.reading}/:bookId',
      builder: (context, state) => ReadingScreen(
        bookId: state.pathParameters['bookId']!,
        initialBook: state.extra as Book?,
      ),
    ),
  ],
);
