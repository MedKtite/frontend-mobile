import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

/// Brand splash shown on cold-launch / session restore.
///
/// The wordmark, tagline, and version fade up on a stagger (design-system.md
/// §17 — "Initial → Name in → Tagline in → Final"). After [_holdDuration] the
/// screen auto-advances via [onComplete] (→ Onboarding on first launch, → Home
/// for a returning user once auth state exists).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  /// Invoked once, after the brand reveal has settled.
  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Total time on screen before auto-advancing (§Splash: 2000 ms).
  static const _holdDuration = Duration(milliseconds: 2200);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _advanceTimer = Timer(_holdDuration, () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StaggerItem(
                    controller: _controller,
                    interval: const Interval(0.0, 0.45, curve: Curves.easeOut),
                    child: Text(
                      'Marginalia',
                      style: AppTypography.wordmark(colors.text),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _StaggerItem(
                    controller: _controller,
                    interval: const Interval(0.25, 0.7, curve: Curves.easeOut),
                    child: Text(
                      'Your reading life, in full.',
                      style: AppTypography.subtitle(colors.text2),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                child: _StaggerItem(
                  controller: _controller,
                  interval: const Interval(0.55, 1.0, curve: Curves.easeOut),
                  child: Text(
                    'VERSION 1.0',
                    style: AppTypography.overline(colors.text3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades + lifts its [child] in over the slice of [controller] given by
/// [interval] (opacity 0→1, 8px upward slide).
class _StaggerItem extends StatelessWidget {
  const _StaggerItem({
    required this.controller,
    required this.interval,
    required this.child,
  });

  final AnimationController controller;
  final Interval interval;
  final Widget child;

  static const double _lift = 8;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = interval.transform(controller.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * _lift),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
