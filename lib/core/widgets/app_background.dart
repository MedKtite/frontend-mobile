import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';

/// App-wide page background painted behind every routed screen. It renders the
/// ambient background texture (light or dark based on theme) with a fallback
/// to the design-system `bg` token; readers can still pin their own palette.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  static const String darkBgImage = 'lib/assets/images/bg_dark.jpg';
  static const String lightBgImage = 'lib/assets/images/bg_light.jpg';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgImage = isDark ? darkBgImage : lightBgImage;

    return Container(
      decoration: BoxDecoration(
        color: colors.bg,
        image: DecorationImage(
          image: AssetImage(bgImage),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: child,
    );
  }
}
