import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';

/// App-wide page background painted behind every routed screen. It follows the
/// light/dark design-system `bg` token; readers can still pin their own palette.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ColoredBox(
      color: colors.bg,
      child: child,
    );
  }
}
