import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/typography.dart';

/// Circular author portrait with an initials fallback (missing/broken photo).
class AuthorAvatar extends StatelessWidget {
  const AuthorAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 64,
  });

  final String name;
  final String? imageUrl;
  final double size;

  String get _initials {
    final words =
        name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return (words.first[0] + words.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface2,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        _initials,
        style: AppTypography.serif(TextStyle(
          color: colors.text2,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w500,
        )),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        frameBuilder: (_, child, frame, wasSync) =>
            wasSync || frame != null ? child : fallback,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}
