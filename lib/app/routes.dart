import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/book.dart';
import '../models/catalog_book.dart';
import '../screens/auth/check_email_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/discovery/author_details_screen.dart';
import '../screens/discovery/book_detail_screen.dart';
import '../screens/discovery/catalog_book_screen.dart';
import '../screens/discovery/discovery_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
// Two hosts, one reader: mobile runs epub.js in a native WebView with on-disk
// caching (reading_screen.dart); web runs the same reader.html in an iframe
// with backend-streamed bytes (reading_screen_web.dart).
import '../screens/reading/reading_screen_web.dart'
    if (dart.library.io) '../screens/reading/reading_screen.dart';
import '../screens/search/search_screen.dart';
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
  static const search = '/search';
  static const library = '/library';
  static const settings = '/settings';

  /// Marginalia Pro paywall — store IAP via RevenueCat.
  static const paywall = '/paywall';


  static const reading = '/reading';
  static String readingPath(String bookId) => '$reading/$bookId';

  static const catalogBook = '/catalog-book';

  /// Owned-book detail page (library tap → here → reader). Full [Book] via extra.
  static const bookDetail = '/book-detail';

  /// Author profile (portrait, bio, books). Author display name via extra.
  static const author = '/author';
}

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => SplashScreen(
        onComplete: () => context.go(Routes.onboarding),
      ),
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
    // The three main tabs live inside ONE persistent shell: the glass nav bar
    // is built once (in AppShell) and never rebuilds on tab switches; each
    // branch keeps its own state (scroll, search text) in an IndexedStack.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(shell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.search,
            builder: (context, state) => const SearchScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: Routes.library,
            builder: (context, state) =>
                LibraryScreen(autofocusSearch: state.extra as bool? ?? false),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
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
      builder: (context, state) =>
          BookDetailScreen(book: state.extra as Book),
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
      ),
    ),
  ],
);
