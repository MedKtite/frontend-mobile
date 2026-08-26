import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

/// Design-system compliant Progress Ring (design-system.md §8 & §14).
///
/// Specs:
/// - Stroke: 1.5px · round line cap
/// - Track: rgba(28,28,30,0.12) light · rgba(255,255,255,0.12) dark
/// - Fill: #1C1C1E light · #F2F0EC dark
/// - Visible: Only when 0 < progress < 1 — never empty or full (when [visibleOnlyWhenInProgress] is true)
/// - Fill animation: 600ms ease-out (design-system.md §10)
class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    super.key,
    this.value,
    this.size = 36.0,
    this.strokeWidth = 1.5,
    this.trackColor,
    this.fillColor,
    this.showLabel = false,
    this.visibleOnlyWhenInProgress = true,
    this.labelStyle,
    this.animate = true,
  });

  /// Factory constructor that accepts a 0-100 percentage (e.g. from `book.progressPct`).
  factory AppProgressRing.fromPercent({
    Key? key,
    double? percent,
    double size = 36.0,
    double strokeWidth = 1.5,
    Color? trackColor,
    Color? fillColor,
    bool showLabel = false,
    bool visibleOnlyWhenInProgress = true,
    TextStyle? labelStyle,
    bool animate = true,
  }) {
    final val = percent == null ? null : percent / 100.0;
    return AppProgressRing(
      key: key,
      value: val,
      size: size,
      strokeWidth: strokeWidth,
      trackColor: trackColor,
      fillColor: fillColor,
      showLabel: showLabel,
      visibleOnlyWhenInProgress: visibleOnlyWhenInProgress,
      labelStyle: labelStyle,
      animate: animate,
    );
  }

  /// Progress value between 0.0 and 1.0. If null, renders an indeterminate spinner.
  final double? value;

  /// Diameter of the ring in logical pixels.
  final double size;

  /// Stroke width (default 1.5px per design system).
  final double strokeWidth;

  /// Background circle color. Defaults to rgba(28,28,30,.12) light / rgba(255,255,255,.12) dark.
  final Color? trackColor;

  /// Progress arc color. Defaults to #1C1C1E light / #F2F0EC dark.
  final Color? fillColor;

  /// Whether to show the percentage text underneath the ring (e.g. "55%").
  final bool showLabel;

  /// When true, renders nothing when progress is not in (0, 1) range.
  final bool visibleOnlyWhenInProgress;

  /// Custom text style for the label.
  final TextStyle? labelStyle;

  /// Whether to animate progress changes over 600ms ease-out.
  final bool animate;

  static Color defaultTrackColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? const Color.fromRGBO(255, 255, 255, 0.12)
        : const Color.fromRGBO(28, 28, 30, 0.12);
  }

  static Color defaultFillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFF2F0EC) : const Color(0xFF1C1C1E);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTrack = trackColor ?? defaultTrackColor(context);
    final effectiveFill = fillColor ?? defaultFillColor(context);

    // Indeterminate mode (when value is null)
    if (value == null) {
      return _IndeterminateRing(
        size: size,
        strokeWidth: strokeWidth,
        trackColor: effectiveTrack,
        fillColor: effectiveFill,
      );
    }

    final clamped = value!.clamp(0.0, 1.0);

    // Rule: Visible only when 0 < progress < 1 — never empty or full
    if (visibleOnlyWhenInProgress && (clamped <= 0.0 || clamped >= 1.0)) {
      return const SizedBox.shrink();
    }

    final ringWidget = animate
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: clamped),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, animValue, _) {
              return CustomPaint(
                size: Size(size, size),
                painter: _ProgressRingPainter(
                  progress: animValue,
                  strokeWidth: strokeWidth,
                  trackColor: effectiveTrack,
                  fillColor: effectiveFill,
                ),
              );
            },
          )
        : CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: clamped,
              strokeWidth: strokeWidth,
              trackColor: effectiveTrack,
              fillColor: effectiveFill,
            ),
          );

    if (!showLabel) {
      return SizedBox(
        width: size,
        height: size,
        child: ringWidget,
      );
    }

    final colors = context.appColors;
    final pctText = '${(clamped * 100).round()}%';
    final effectiveTextStyle = labelStyle ??
        AppTypography.caption(colors.text2).copyWith(
          fontSize: (size * 0.32).clamp(10.0, 14.0),
          fontWeight: FontWeight.w500,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: ringWidget,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          pctText,
          textAlign: TextAlign.center,
          style: effectiveTextStyle,
        ),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    if (radius <= 0) return;

    // Background track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      // Start at 12 o'clock (-pi / 2) and sweep clockwise
      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillColor != fillColor;
  }
}

/// Indeterminate spinner variant matching the 1.5px stroke round cap aesthetic.
class _IndeterminateRing extends StatefulWidget {
  const _IndeterminateRing({
    required this.size,
    required this.strokeWidth,
    required this.trackColor,
    required this.fillColor,
  });

  final double size;
  final double strokeWidth;
  final Color trackColor;
  final Color fillColor;

  @override
  State<_IndeterminateRing> createState() => _IndeterminateRingState();
}

class _IndeterminateRingState extends State<_IndeterminateRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _IndeterminatePainter(
            rotationValue: _controller.value,
            strokeWidth: widget.strokeWidth,
            trackColor: widget.trackColor,
            fillColor: widget.fillColor,
          ),
        );
      },
    );
  }
}

class _IndeterminatePainter extends CustomPainter {
  const _IndeterminatePainter({
    required this.rotationValue,
    required this.strokeWidth,
    required this.trackColor,
    required this.fillColor,
  });

  final double rotationValue;
  final double strokeWidth;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    if (radius <= 0) return;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    // Spinning Arc (approx 90 deg)
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final startAngle = -math.pi / 2 + (rotationValue * 2 * math.pi);
    const sweepAngle = math.pi * 0.65;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _IndeterminatePainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillColor != fillColor;
  }
}
