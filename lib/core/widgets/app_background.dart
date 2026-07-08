import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';

/// App-wide page background: the gradient artwork (bg_light / bg_dark by
/// theme) painted behind every routed screen via MaterialApp.builder. Screens
/// keep transparent scaffolds so it shows through; the reading screen opts out
/// by pinning its own opaque reader-palette color.
///
/// Both variants are precached on first build so theme switches and screen
/// pushes never show the texture popping in.
class AppBackground extends StatefulWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  static const lightAsset = 'lib/assets/images/bg_light.jpg';
  static const darkAsset = 'lib/assets/images/bg_dark.jpg';

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> {
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      precacheImage(const AssetImage(AppBackground.lightAsset), context);
      precacheImage(const AssetImage(AppBackground.darkAsset), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid token base under the artwork — no flash while the first
        // frame decodes, and edges stay on-color if the art letterboxes.
        ColoredBox(color: colors.bg),
        Image.asset(
          isLight ? AppBackground.lightAsset : AppBackground.darkAsset,
          fit: BoxFit.cover,
        ),
        widget.child,
      ],
    );
  }
}
