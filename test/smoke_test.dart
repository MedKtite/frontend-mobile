// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:go_router/go_router.dart';

// import 'package:marginalia/app/routes.dart';
// import 'package:marginalia/app/theme/app_theme.dart';
// import 'package:marginalia/core/errors/failure.dart';
// import 'package:marginalia/models/book.dart';
// import 'package:marginalia/models/book_create_request.dart';
// import 'package:marginalia/models/book_update_request.dart';
// import 'package:marginalia/models/catalog_book.dart';
// import 'package:marginalia/models/highlight.dart';
// import 'package:marginalia/models/login_request.dart';
// import 'package:marginalia/models/search_hit.dart';
// import 'package:marginalia/models/search_response.dart';
// import 'package:marginalia/models/oauth_login_request.dart';
// import 'package:marginalia/models/register_request.dart';
// import 'package:marginalia/models/user.dart';
// import 'package:marginalia/screens/auth/check_email_screen.dart';
// import 'package:marginalia/screens/auth/forgot_password_screen.dart';
// import 'package:marginalia/screens/auth/login_screen.dart';
// import 'package:marginalia/screens/auth/register_screen.dart';
// import 'package:marginalia/screens/auth/reset_password_screen.dart';
// import 'package:marginalia/screens/home/home_screen.dart';
// import 'package:marginalia/screens/library/catalog_search_screen.dart';
// import 'package:marginalia/screens/library/library_screen.dart';
// import 'package:marginalia/screens/onboarding/onboarding_screen.dart';
// import 'package:marginalia/screens/reading/reading_screen.dart';
// import 'package:marginalia/screens/search/search_screen.dart';
// import 'package:marginalia/screens/settings/settings_screen.dart';
// import 'package:marginalia/screens/splash/splash_screen.dart';

// import 'package:marginalia/widgets/book_cover.dart';

// /// Render smoke tests — confirm the brand surfaces build and settle without
// /// throwing (overflow, paint errors) in BOTH themes. Not pixel verification.
// ///
// /// Fonts fall back to the test default (no network in `flutter test`); that's
// /// fine — we're checking layout, not glyphs.
// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();

//   Widget wrap(Widget child, ThemeData theme) =>
//       MaterialApp(theme: theme, home: child);

//   // Auth screens watch authControllerProvider, which builds the real repo (and
//   // Dio). Override the repository with a no-network fake so the form renders.
//   Widget wrapAuth(Widget child, ThemeData theme) => ProviderScope(
//         overrides: [
//           authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
//         ],
//         child: MaterialApp(theme: theme, home: child),
//       );

//   for (final name in ['light', 'dark']) {
//     ThemeData theme() => name == 'light' ? AppTheme.light() : AppTheme.dark();

//     testWidgets('onboarding renders & swipes — $name', (tester) async {
//       await tester.pumpWidget(wrap(const OnboardingScreen(), theme()));
//       await tester.pumpAndSettle();

//       // Page 1 (Welcome) chrome.
//       expect(find.text('Marginalia'), findsOneWidget);
//       expect(find.text('Begin'), findsOneWidget);

//       // Advance through the pager to the final page.
//       await tester.tap(find.text('Begin'));
//       await tester.pumpAndSettle();
//       expect(find.text('Every book you read.'), findsOneWidget);

//       await tester.tap(find.text('Continue'));
//       await tester.pumpAndSettle();
//       expect(find.text('Leave your mark.'), findsOneWidget);

//       await tester.tap(find.text('Continue'));
//       await tester.pumpAndSettle();
//       expect(find.text('2,138'), findsOneWidget);
//       expect(find.text('Create account'), findsOneWidget);
//       expect(find.text('Sign in'), findsOneWidget);
//     });

//     testWidgets('splash renders & auto-advances — $name', (tester) async {
//       var completed = false;
//       await tester.pumpWidget(
//         wrap(SplashScreen(onComplete: () => completed = true), theme()),
//       );

//       expect(find.text('Marginalia'), findsOneWidget);
//       expect(find.text('VERSION 1.0'), findsOneWidget);

//       // Let the stagger animation finish, then cross the hold threshold.
//       await tester.pump(const Duration(milliseconds: 1300));
//       await tester.pump(const Duration(milliseconds: 1000));
//       expect(completed, isTrue);

//       // Unmount to cancel the pending timer / dispose the controller.
//       await tester.pumpWidget(const SizedBox.shrink());
//     });

//     testWidgets('login renders — $name', (tester) async {
//       await tester.pumpWidget(wrapAuth(const LoginScreen(), theme()));
//       await tester.pumpAndSettle();

//       expect(find.text('Welcome back'), findsOneWidget);
//       expect(find.text('Sign in'), findsOneWidget);
//       expect(find.text('Forgot password?'), findsOneWidget);
//       expect(find.text('Continue with Google'), findsOneWidget);
//       expect(find.text('Continue with X'), findsOneWidget);
//       expect(find.text('Register'), findsOneWidget);
//     });

//     testWidgets('register renders — $name', (tester) async {
//       await tester.pumpWidget(wrapAuth(const RegisterScreen(), theme()));
//       await tester.pumpAndSettle();

//       // 'Create account' is both the title and the button label.
//       expect(find.text('Create account'), findsNWidgets(2));
//       expect(find.text('Begin your reading life.'), findsOneWidget);
//       expect(find.text('Continue with Google'), findsOneWidget);
//       expect(find.text('Sign in'), findsOneWidget); // footer link
//     });

//     testWidgets('forgot password renders — $name', (tester) async {
//       await tester.pumpWidget(wrap(const ForgotPasswordScreen(), theme()));
//       await tester.pumpAndSettle();

//       expect(find.text('Forgot your password?'), findsOneWidget);
//       expect(find.text('Send recovery link'), findsOneWidget);
//       expect(find.text('Back to sign in'), findsOneWidget);
//     });

//     testWidgets('check email renders — $name', (tester) async {
//       await tester.pumpWidget(
//         wrap(const CheckEmailScreen(email: 'reader@example.com'), theme()),
//       );
//       await tester.pump(); // periodic resend timer — don't pumpAndSettle

//       expect(find.text('Check your email.'), findsOneWidget);
//       expect(find.textContaining('reader@example.com'), findsOneWidget);
//       expect(find.text('Open Mail'), findsOneWidget);
//       expect(find.textContaining('Resend in'), findsOneWidget);

//       await tester.pumpWidget(const SizedBox.shrink()); // dispose → cancel timer
//     });

//     testWidgets('reset password renders — $name', (tester) async {
//       await tester.pumpWidget(wrap(const ResetPasswordScreen(), theme()));
//       await tester.pumpAndSettle();

//       expect(find.text('Set a new password'), findsOneWidget);
//       expect(find.text('New password'), findsOneWidget);
//       expect(find.text('Confirm password'), findsOneWidget);
//       expect(find.text('Reset password'), findsOneWidget);
//     });

//     testWidgets('home empty renders — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
//             bookRepositoryProvider.overrideWithValue(
//                 _FakeBookRepository(const Ok<List<Book>>([]))),
//             highlightRepositoryProvider.overrideWithValue(
//                 _FakeHighlightRepository(const Ok<List<Highlight>>([]))),
//           ],
//           child: MaterialApp(theme: theme(), home: const HomeScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.text('Your library begins here.'), findsOneWidget);
//       expect(find.text('Add your first book'), findsOneWidget);
//       expect(find.text('EPUB'), findsOneWidget);
//       expect(find.text('Home'), findsOneWidget); // glass nav
//       expect(find.text('Profile'), findsOneWidget);
//     });

//     testWidgets('home populated renders from backend — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             authRepositoryProvider
//                 .overrideWithValue(_FakeAuthRepository(authUser: _sampleUser)),
//             bookRepositoryProvider.overrideWithValue(_FakeBookRepository(
//                 const Ok<List<Book>>([_readingBook, _audioBook]))),
//             highlightRepositoryProvider.overrideWithValue(
//                 _FakeHighlightRepository(const Ok<List<Highlight>>([_highlight]))),
//           ],
//           child: MaterialApp(theme: theme(), home: const HomeScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       // Greeting from the authenticated user; sections derived from the books.
//       expect(find.textContaining('Mounir'), findsWidgets);
//       expect(find.text('CONTINUE READING'), findsOneWidget);
//       expect(find.text('Resume'), findsOneWidget);
//       expect(find.text('72%'), findsOneWidget); // progressPct
//       expect(find.text('PASSAGE OF THE DAY'), findsOneWidget);
//       expect(find.textContaining('fallen in love with a color'), findsWidgets);
//       expect(find.text('STILL LISTENING TO'), findsOneWidget);
//     });

//     testWidgets('home error shows retry — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
//             bookRepositoryProvider.overrideWithValue(_FakeBookRepository(
//                 const Err<List<Book>>(NetworkFailure('backend down')))),
//             highlightRepositoryProvider.overrideWithValue(
//                 _FakeHighlightRepository(const Ok<List<Highlight>>([]))),
//           ],
//           child: MaterialApp(theme: theme(), home: const HomeScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.text("Couldn't load your library."), findsOneWidget);
//       expect(find.text('Try again'), findsOneWidget);
//     });

//     testWidgets('settings renders with user — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             authRepositoryProvider
//                 .overrideWithValue(_FakeAuthRepository(authUser: _sampleUser)),
//           ],
//           child: MaterialApp(theme: theme(), home: const SettingsScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.text('Settings'), findsOneWidget);
//       expect(find.text('Mounir Ktite'), findsOneWidget); // displayName
//       expect(find.textContaining('ktite.m3@gmail.com'), findsWidgets);
//       expect(find.text('PRO'), findsOneWidget);
//       expect(find.text('Theme'), findsOneWidget);
//       expect(find.text('Sign out'), findsOneWidget);
//     });

//     testWidgets('library loaded renders from backend — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             bookRepositoryProvider.overrideWithValue(_FakeBookRepository(
//                 const Ok<List<Book>>([_readingBook, _audioBook]))),
//           ],
//           child: MaterialApp(theme: theme(), home: const LibraryScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.text('2 volumes'), findsOneWidget);
//       expect(find.text('All 2'), findsOneWidget); // chip with live count
//       expect(find.text('Reading 1'), findsOneWidget);
//       expect(find.text('RECENTLY ADDED'), findsOneWidget);
//       expect(find.textContaining('Bluets'), findsWidgets);
//     });

//     testWidgets('reading view renders — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           child: MaterialApp(
//             theme: theme(),
//             home: const ReadingScreen(bookId: 'b1', initialBook: _readingBook),
//           ),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.text('Bluets'), findsOneWidget); // top-bar title from the book
//       expect(find.text('CHAPTER ONE'), findsOneWidget);
//       expect(find.text('1.'), findsOneWidget);
//       expect(find.text('Aa'), findsOneWidget);
//       expect(find.textContaining('the page might answer back'), findsWidgets);
//       expect(find.text('72% read'), findsOneWidget); // progressPct, no pageCount
//       expect(find.text('12 min left in chapter'), findsOneWidget);
//     });

//     testWidgets('library empty renders — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             bookRepositoryProvider.overrideWithValue(
//                 _FakeBookRepository(const Ok<List<Book>>([]))),
//           ],
//           child: MaterialApp(theme: theme(), home: const LibraryScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.text('Your library is empty.'), findsOneWidget);
//       expect(find.textContaining('Tap +'), findsOneWidget);
//     });

//     testWidgets('library error shows retry — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             bookRepositoryProvider.overrideWithValue(_FakeBookRepository(
//                 const Err<List<Book>>(NetworkFailure('down')))),
//           ],
//           child: MaterialApp(theme: theme(), home: const LibraryScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.text("Couldn't load your library."), findsOneWidget);
//       expect(find.text('Try again'), findsOneWidget);
//     });

//     testWidgets('search empty state — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           child: MaterialApp(theme: theme(), home: const SearchScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       expect(find.text('SUGGESTIONS'), findsOneWidget);
//       expect(find.text('Try a book title'), findsOneWidget);
//       expect(find.text('All'), findsOneWidget); // scope chip (no count yet)
//     });

//     testWidgets('search results render mixed hits — $name', (tester) async {
//       await tester.pumpWidget(
//         ProviderScope(
//           overrides: [
//             searchRepositoryProvider.overrideWithValue(
//                 _FakeSearchRepository(const Ok<SearchResponse>(_sampleSearch))),
//           ],
//           child: MaterialApp(theme: theme(), home: const SearchScreen()),
//         ),
//       );
//       await tester.pumpAndSettle();

//       await tester.enterText(find.byType(TextField), 'solitude');
//       await tester.testTextInput.receiveAction(TextInputAction.search);
//       await tester.pumpAndSettle();

//       expect(find.text('3 RESULTS'), findsOneWidget);
//       expect(find.text('All 3'), findsOneWidget); // chip with count
//       expect(find.text('Bluets'), findsWidgets); // book hit
//       expect(find.textContaining('HIGHLIGHT'), findsWidgets);
//       expect(find.textContaining('solitude'), findsWidgets); // bolded snippet
//     });
//   }

//   testWidgets('onboarding page 1 links to Login', (tester) async {
//     await tester.pumpWidget(
//       MaterialApp.router(
//         theme: AppTheme.light(),
//         routerConfig: _onboardingNavRouter(),
//       ),
//     );
//     await tester.pumpAndSettle();

//     await tester.tap(find.text('Already have an account'));
//     await tester.pumpAndSettle();
//     expect(find.text('LOGIN STUB'), findsOneWidget);
//   });

//   testWidgets('onboarding final page links to Register', (tester) async {
//     await tester.pumpWidget(
//       MaterialApp.router(
//         theme: AppTheme.light(),
//         routerConfig: _onboardingNavRouter(),
//       ),
//     );
//     await tester.pumpAndSettle();

//     // Swipe through to the final (Insight) page via the CTA.
//     await tester.tap(find.text('Begin'));
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('Continue'));
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('Continue'));
//     await tester.pumpAndSettle();

//     await tester.tap(find.text('Create account'));
//     await tester.pumpAndSettle();
//     expect(find.text('REGISTER STUB'), findsOneWidget);
//   });

//   testWidgets('login links to forgot password', (tester) async {
//     final router = GoRouter(
//       initialLocation: Routes.login,
//       routes: [
//         GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
//         GoRoute(
//           path: Routes.forgotPassword,
//           builder: (_, s) =>
//               ForgotPasswordScreen(initialEmail: s.extra as String? ?? ''),
//         ),
//       ],
//     );
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
//         ],
//         child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
//       ),
//     );
//     await tester.pumpAndSettle();

//     await tester.tap(find.text('Forgot password?'));
//     await tester.pumpAndSettle();
//     expect(find.text('Forgot your password?'), findsOneWidget);
//   });

//   testWidgets('home Profile tab opens Settings', (tester) async {
//     final router = GoRouter(
//       initialLocation: Routes.home,
//       routes: [
//         GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
//         GoRoute(
//           path: Routes.settings,
//           builder: (_, __) => const SettingsScreen(),
//         ),
//       ],
//     );
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           authRepositoryProvider
//               .overrideWithValue(_FakeAuthRepository(authUser: _sampleUser)),
//           bookRepositoryProvider.overrideWithValue(
//               _FakeBookRepository(const Ok<List<Book>>([]))),
//           highlightRepositoryProvider.overrideWithValue(
//               _FakeHighlightRepository(const Ok<List<Highlight>>([]))),
//         ],
//         child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
//       ),
//     );
//     await tester.pumpAndSettle();

//     await tester.tap(find.text('Profile'));
//     await tester.pumpAndSettle();
//     expect(find.text('Settings'), findsOneWidget);
//     expect(find.text('Mounir Ktite'), findsOneWidget);
//   });

//   testWidgets('settings sign out → login', (tester) async {
//     final router = GoRouter(
//       initialLocation: Routes.settings,
//       routes: [
//         GoRoute(
//           path: Routes.settings,
//           builder: (_, __) => const SettingsScreen(),
//         ),
//         GoRoute(
//           path: Routes.login,
//           builder: (_, __) =>
//               const Scaffold(body: Center(child: Text('LOGIN STUB'))),
//         ),
//       ],
//     );
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           authRepositoryProvider
//               .overrideWithValue(_FakeAuthRepository(authUser: _sampleUser)),
//         ],
//         child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
//       ),
//     );
//     await tester.pumpAndSettle();
//     expect(find.text('Sign out'), findsOneWidget);

//     await tester.ensureVisible(find.text('Sign out'));
//     await tester.pumpAndSettle();
//     await tester.tap(find.text('Sign out'));
//     await tester.pumpAndSettle();
//     expect(find.text('LOGIN STUB'), findsOneWidget);
//   });

//   testWidgets('library filter chip narrows the grid', (tester) async {
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           bookRepositoryProvider.overrideWithValue(_FakeBookRepository(
//               const Ok<List<Book>>([_readingBook, _audioBook]))),
//         ],
//         child: MaterialApp(theme: AppTheme.light(), home: const LibraryScreen()),
//       ),
//     );
//     await tester.pumpAndSettle();
//     expect(find.text('RECENTLY ADDED'), findsOneWidget);

//     await tester.tap(find.text('Listening 1'));
//     await tester.pumpAndSettle();
//     expect(find.text('LISTENING'), findsOneWidget);
//     expect(find.textContaining('On Photography'), findsWidgets);
//     expect(find.textContaining('Bluets'), findsNothing); // filtered out
//   });

//   testWidgets('library FAB opens add-to-library sheet', (tester) async {
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           bookRepositoryProvider.overrideWithValue(
//               _FakeBookRepository(const Ok<List<Book>>([_readingBook]))),
//         ],
//         child: MaterialApp(theme: AppTheme.light(), home: const LibraryScreen()),
//       ),
//     );
//     await tester.pumpAndSettle();

//     await tester.tap(find.byType(FloatingActionButton));
//     await tester.pumpAndSettle();
//     expect(find.text('Add to library'), findsOneWidget);
//     expect(find.text('Upload a file'), findsOneWidget);
//     expect(find.text('Log a physical book'), findsOneWidget);
//   });

//   testWidgets('Home ↔ Library tab switch via glass nav', (tester) async {
//     final router = GoRouter(
//       initialLocation: Routes.home,
//       routes: [
//         GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
//         GoRoute(path: Routes.library, builder: (_, __) => const LibraryScreen()),
//       ],
//     );
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
//           bookRepositoryProvider.overrideWithValue(
//               _FakeBookRepository(const Ok<List<Book>>([_readingBook]))),
//           highlightRepositoryProvider.overrideWithValue(
//               _FakeHighlightRepository(const Ok<List<Highlight>>([]))),
//         ],
//         child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
//       ),
//     );
//     await tester.pumpAndSettle();
//     expect(find.text('CONTINUE READING'), findsOneWidget); // on Home

//     await tester.tap(find.text('Library')); // nav → Library tab
//     await tester.pumpAndSettle();
//     expect(find.text('RECENTLY ADDED'), findsOneWidget); // on Library

//     await tester.tap(find.text('Home')); // nav → back to Home
//     await tester.pumpAndSettle();
//     expect(find.text('CONTINUE READING'), findsOneWidget);
//   });

//   // Library hands the full Book over via `extra` (no fetch).
//   testWidgets('library cover opens the reader', (tester) async {
//     final router = GoRouter(
//       initialLocation: Routes.library,
//       routes: [
//         GoRoute(path: Routes.library, builder: (_, __) => const LibraryScreen()),
//         GoRoute(
//           path: '${Routes.reading}/:bookId',
//           builder: (_, s) => ReadingScreen(
//             bookId: s.pathParameters['bookId']!,
//             initialBook: s.extra as Book?,
//           ),
//         ),
//       ],
//     );
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           bookRepositoryProvider.overrideWithValue(
//               _FakeBookRepository(const Ok<List<Book>>([_readingBook]))),
//         ],
//         child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
//       ),
//     );
//     await tester.pumpAndSettle();

//     await tester.tap(find.byType(BookCover).first);
//     await tester.pumpAndSettle();
//     expect(find.text('CHAPTER ONE'), findsOneWidget); // reader open
//     expect(find.text('12 min left in chapter'), findsOneWidget);
//   });

//   // Home's "Continue reading" passes only the id → the reader fetches the Book.
//   testWidgets('home resume opens the reader', (tester) async {
//     final router = GoRouter(
//       initialLocation: Routes.home,
//       routes: [
//         GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
//         GoRoute(
//           path: '${Routes.reading}/:bookId',
//           builder: (_, s) => ReadingScreen(
//             bookId: s.pathParameters['bookId']!,
//             initialBook: s.extra as Book?,
//           ),
//         ),
//       ],
//     );
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
//           bookRepositoryProvider.overrideWithValue(
//               _FakeBookRepository(const Ok<List<Book>>([_readingBook]))),
//           highlightRepositoryProvider.overrideWithValue(
//               _FakeHighlightRepository(const Ok<List<Highlight>>([]))),
//         ],
//         child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
//       ),
//     );
//     await tester.pumpAndSettle();
//     expect(find.text('Resume'), findsOneWidget);

//     await tester.tap(find.text('Resume'));
//     await tester.pumpAndSettle();
//     expect(find.text('CHAPTER ONE'), findsOneWidget); // reader open (fetched)
//   });

//   testWidgets('library cover + re-shelves the book', (tester) async {
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           bookRepositoryProvider.overrideWithValue(
//               _FakeBookRepository(const Ok<List<Book>>([_readingBook]))),
//         ],
//         child: MaterialApp(theme: AppTheme.light(), home: const LibraryScreen()),
//       ),
//     );
//     await tester.pumpAndSettle();

//     await tester.tap(find.byKey(const ValueKey('shelf-b1')));
//     await tester.pumpAndSettle();
//     expect(find.text('Add to shelf'), findsOneWidget); // shelf picker

//     await tester.tap(find.text('Reading'));
//     await tester.pumpAndSettle();
//     expect(find.textContaining('Moved'), findsWidgets); // confirmation
//   });

//   testWidgets('catalog search screen finds and adds a book', (tester) async {
//     await tester.pumpWidget(
//       ProviderScope(
//         overrides: [
//           bookRepositoryProvider.overrideWithValue(
//               _FakeBookRepository(const Ok<List<Book>>([]))),
//           catalogRepositoryProvider.overrideWithValue(_FakeCatalogRepository(
//               const Ok<List<CatalogBook>>(
//                   [CatalogBook(title: 'The Overstory', author: 'Richard Powers')]))),
//         ],
//         child:
//             MaterialApp(theme: AppTheme.light(), home: const CatalogSearchScreen()),
//       ),
//     );
//     await tester.pumpAndSettle();
//     expect(find.text('Add a book'), findsOneWidget);

//     await tester.enterText(find.byType(TextField), 'overstory');
//     await tester.testTextInput.receiveAction(TextInputAction.search);
//     await tester.pumpAndSettle();
//     expect(find.text('The Overstory'), findsWidgets);

//     await tester.tap(find.text('Add'));
//     await tester.pumpAndSettle();
//     expect(find.text('Add to shelf'), findsOneWidget); // shelf picker

//     await tester.tap(find.text('Reading'));
//     await tester.pumpAndSettle();
//     expect(find.textContaining('Added'), findsWidgets); // confirmation
//   });
// }

// /// Minimal router that hosts onboarding with stub auth destinations, so the
// /// onboarding CTAs' navigation can be exercised without the real auth stack.
// GoRouter _onboardingNavRouter() => GoRouter(
//       initialLocation: Routes.onboarding,
//       routes: [
//         GoRoute(
//           path: Routes.onboarding,
//           builder: (_, __) => const OnboardingScreen(),
//         ),
//         GoRoute(
//           path: Routes.login,
//           builder: (_, __) =>
//               const Scaffold(body: Center(child: Text('LOGIN STUB'))),
//         ),
//         GoRoute(
//           path: Routes.register,
//           builder: (_, __) =>
//               const Scaffold(body: Center(child: Text('REGISTER STUB'))),
//         ),
//       ],
//     );

// const _sampleUser = User(
//   id: '1',
//   email: 'ktite.m3@gmail.com',
//   displayName: 'Mounir Ktite',
//   shortName: 'Mounir',
//   avatarInitial: 'M',
// );

// /// No-network stand-in so auth-aware screens render without Dio. When
// /// [authUser] is set, `refresh()` resolves authenticated; otherwise offline.
// class _FakeAuthRepository implements AuthRepository {
//   _FakeAuthRepository({this.authUser});

//   final User? authUser;

//   Future<Result<User>> _result() async => authUser != null
//       ? Ok<User>(authUser!)
//       : Err<User>(const NetworkFailure('offline'));

//   @override
//   Future<Result<User>> refresh() => _result();

//   @override
//   Future<Result<User>> login(LoginRequest req) => _result();

//   @override
//   Future<Result<User>> register(RegisterRequest req) => _result();

//   @override
//   Future<Result<User>> loginWithGoogle(OAuthLoginRequest req) => _result();

//   @override
//   Future<Result<User>> loginWithX(OAuthLoginRequest req) => _result();

//   @override
//   Future<Result<void>> logout() async => const Ok(null);
// }

// const _readingBook = Book(
//   id: 'b1',
//   title: 'Bluets',
//   author: 'Maggie Nelson',
//   format: 'epub',
//   status: 'reading',
//   progressPct: 72.0,
//   coverDominantColor: '#34507A',
//   lastOpenedAt: '2026-06-05T10:00:00Z',
// );

// const _audioBook = Book(
//   id: 'b2',
//   title: 'On Photography',
//   author: 'Susan Sontag',
//   format: 'm4b',
//   status: 'listening',
//   progressPct: 30.0,
//   coverDominantColor: '#E3C04A',
//   lastOpenedAt: '2026-06-04T10:00:00Z',
// );

// const _highlight = Highlight(
//   id: 'h1',
//   bookId: 'b1',
//   passageText:
//       'Suppose I were to begin by saying that I had fallen in love with a color.',
//   textChapterRef: 'p. 1',
//   colorTag: 'curious',
//   createdAt: '2026-06-05T10:00:00Z',
// );

// class _FakeBookRepository implements BookRepository {
//   _FakeBookRepository(this._result);
//   final Result<List<Book>> _result;
//   @override
//   Future<Result<List<Book>>> list({String? status}) async => _result;
//   @override
//   Future<Result<Book>> create(BookCreateRequest req) async =>
//       Ok<Book>(Book(id: 'new', title: req.title, author: req.author, format: req.format));
//   @override
//   Future<Result<Book>> update(String id, BookUpdateRequest req) async =>
//       Ok<Book>(Book(id: id, title: 'Bluets', format: 'physical', status: req.status));
//   @override
//   Future<Result<Book>> getOne(String id) async {
//     final books = switch (_result) {
//       Ok(:final value) => value,
//       _ => const <Book>[],
//     };
//     final match = books.where((b) => b.id == id);
//     return Ok<Book>(match.isNotEmpty ? match.first : _readingBook);
//   }
// }

// class _FakeHighlightRepository implements HighlightRepository {
//   _FakeHighlightRepository(this._result);
//   final Result<List<Highlight>> _result;
//   @override
//   Future<Result<List<Highlight>>> recent({int limit = 20}) async => _result;
// }

// class _FakeCatalogRepository implements CatalogRepository {
//   _FakeCatalogRepository(this._result);
//   final Result<List<CatalogBook>> _result;
//   @override
//   Future<Result<List<CatalogBook>>> search(String q, {int limit = 20}) async =>
//       _result;
// }

// const _sampleSearch = SearchResponse(
//   query: 'solitude',
//   scope: 'all',
//   totalHits: 3,
//   counts: SearchCounts(books: 1, highlights: 1, notes: 1),
//   results: [
//     SearchHit(
//         type: 'book',
//         id: '1',
//         title: 'Bluets',
//         bookAuthor: 'Maggie Nelson',
//         status: 'reading',
//         format: 'epub',
//         coverDominantColor: '#34507A'),
//     SearchHit(
//         type: 'highlight',
//         id: '2',
//         bookId: '1',
//         bookTitle: 'One Hundred Years of Solitude',
//         snippet: 'He was condemned to the eternal <mark>solitude</mark> that grew…',
//         chapterRef: 'p. 142'),
//     SearchHit(
//         type: 'note',
//         id: '3',
//         bookId: '1',
//         bookTitle: 'Bluets',
//         snippet: 'Solitude here feels chosen, not imposed.'),
//   ],
// );

// class _FakeSearchRepository implements SearchRepository {
//   _FakeSearchRepository(this._result);
//   final Result<SearchResponse> _result;
//   @override
//   Future<Result<SearchResponse>> search(String q,
//           {String scope = 'all', int limit = 20}) async =>
//       _result;
// }
