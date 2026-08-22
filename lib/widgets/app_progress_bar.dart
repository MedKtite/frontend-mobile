import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/radii.dart';

/// Unified progress bar for Marginalia.
///
/// - If [value] is null, renders an indeterminate loading progress bar.
/// - If [value] is provided (0.0 to 1.0), renders determinate progress.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    this.value,
    this.height = 4,
    this.color,
    this.backgroundColor,
  });

  final double? value;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: AppRadii.brFull,
      child: LinearProgressIndicator(
        value: value?.clamp(0.0, 1.0),
        minHeight: height,
        color: color ?? colors.accent,
        backgroundColor: backgroundColor ?? colors.border,
      ),
    );
  }
}

/// Unified centered progress bar loader for screens, sheets, and content areas.
class AppProgressLoading extends StatelessWidget {
  const AppProgressLoading({
    super.key,
    this.width = 180,
    this.height = 4,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        child: AppProgressBar(height: height),
      ),
    );
  }
}
