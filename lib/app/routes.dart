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
import '../screens/discovery/catalog_book_screen.dart';
import '../screens/discovery/discovery_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/reading/reading_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';

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


  static const reading = '/reading';
  static String readingPath(String bookId) => '$reading/$bookId';

  static const catalogBook = '/catalog-book';
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
      builder: (context, state) =>
          LibraryScreen(autofocusSearch: state.extra as bool? ?? false),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
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
