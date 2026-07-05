import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/tokens/colors.dart';

/// App-wide page background: the paper-texture artwork (bg_light / bg_dark by
/// theme) painted behind every routed screen via MaterialApp.builder. Screens
/// keep transparent scaffolds so it shows through; the reading screen opts out
/// by pinning its own opaque reader-palette color.
///
/// The two assets are ~1.1 MB SVGs wrapping a full-page JPEG — parse them ONCE
/// at bootstrap with [precacheAppBackground], never per screen.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  static const lightAsset = 'lib/assets/images/bg_light.svg';
  static const darkAsset = 'lib/assets/images/bg_dark.svg';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid token base under the artwork — no flash while the first
        // frame rasterizes, and edges stay on-color if the art letterboxes.
        ColoredBox(color: colors.bg),
        SvgPicture.asset(
          isLight ? lightAsset : darkAsset,
          fit: BoxFit.cover,
        ),
        child,
      ],
    );
  }
}

/// Parses both background assets into flutter_svg's byte cache before the
/// first frame, so no screen ever shows the texture popping in.
Future<void> precacheAppBackground() async {
  for (final asset in [AppBackground.lightAsset, AppBackground.darkAsset]) {
    final loader = SvgAssetLoader(asset);
    await svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
  }
}
