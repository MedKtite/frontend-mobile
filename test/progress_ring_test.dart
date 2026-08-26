import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marginalia/app/theme/app_theme.dart';
import 'package:marginalia/widgets/app_progress_ring.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child, [ThemeData? theme]) {
    return MaterialApp(
      theme: theme ?? AppTheme.light(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppProgressRing visibility rule', () {
    testWidgets('hides when progress is 0.0 or <= 0', (tester) async {
      await tester.pumpWidget(wrap(const AppProgressRing(value: 0.0)));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppProgressRing),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });

    testWidgets('hides when progress is 1.0 or >= 1', (tester) async {
      await tester.pumpWidget(wrap(const AppProgressRing(value: 1.0)));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppProgressRing),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    });

    testWidgets('renders when 0 < progress < 1 (e.g. 0.18, 0.55, 0.86)', (tester) async {
      for (final val in [0.18, 0.55, 0.86]) {
        await tester.pumpWidget(wrap(AppProgressRing(value: val, animate: false)));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
            of: find.byType(AppProgressRing),
            matching: find.byType(CustomPaint),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('renders when visibleOnlyWhenInProgress is false', (tester) async {
      await tester.pumpWidget(
        wrap(const AppProgressRing(value: 0.0, visibleOnlyWhenInProgress: false, animate: false)),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AppProgressRing),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });
  });

  group('AppProgressRing label formatting', () {
    testWidgets('shows percentage label beneath ring when showLabel is true', (tester) async {
      await tester.pumpWidget(
        wrap(const AppProgressRing(value: 0.18, showLabel: true, animate: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('18%'), findsOneWidget);

      await tester.pumpWidget(
        wrap(const AppProgressRing(value: 0.55, showLabel: true, animate: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('55%'), findsOneWidget);

      await tester.pumpWidget(
        wrap(const AppProgressRing(value: 0.86, showLabel: true, animate: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('86%'), findsOneWidget);
    });

    testWidgets('fromPercent factory initializes value and label correctly', (tester) async {
      await tester.pumpWidget(
        wrap(AppProgressRing.fromPercent(percent: 55.0, showLabel: true, animate: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('55%'), findsOneWidget);
    });
  });

  group('AppProgressRing theme colors & specifications', () {
    testWidgets('light mode tokens match specs', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final track = AppProgressRing.defaultTrackColor(capturedContext);
      final fill = AppProgressRing.defaultFillColor(capturedContext);

      expect(track, const Color.fromRGBO(28, 28, 30, 0.12));
      expect(fill, const Color(0xFF1C1C1E));
    });

    testWidgets('dark mode tokens match specs', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final track = AppProgressRing.defaultTrackColor(capturedContext);
      final fill = AppProgressRing.defaultFillColor(capturedContext);

      expect(track, const Color.fromRGBO(255, 255, 255, 0.12));
      expect(fill, const Color(0xFFF2F0EC));
    });
  });

  group('AppProgressRing indeterminate mode', () {
    testWidgets('renders indeterminate spinning ring when value is null', (tester) async {
      await tester.pumpWidget(wrap(const AppProgressRing(value: null)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.descendant(
          of: find.byType(AppProgressRing),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });
  });
}
