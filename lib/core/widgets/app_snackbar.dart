import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

/// Semantic snackbar variants: leading icon + tone from the status tokens.
enum SnackType { success, error, warning, info }

/// The app-styled floating snackbar. Two entry points:
/// - [showAppSnack] when a BuildContext is at hand (hides any current one);
/// - [appSnackBar] to hand to a ScaffoldMessenger captured before an await:
///     messenger..hideCurrentSnackBar()
///              ..showSnackBar(appSnackBar('Saved', SnackType.success));
SnackBar appSnackBar(String message, SnackType type) => SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      duration: const Duration(seconds: 3),
      content: _SnackContent(message: message, type: type),
    );

void showAppSnack(BuildContext context, String message,
    {SnackType type = SnackType.info}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(appSnackBar(message, type));
}

/// Card-style body: surface, tone-tinted hairline + icon, label ink. Builds
/// under the messenger's context, so tokens resolve to the active theme.
class _SnackContent extends StatelessWidget {
  const _SnackContent({required this.message, required this.type});

  final String message;
  final SnackType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final (icon, tone) = switch (type) {
      SnackType.success => (Icons.check_circle_rounded, colors.success),
      SnackType.error => (Icons.error_rounded, colors.danger),
      SnackType.warning => (Icons.warning_amber_rounded, colors.warning),
      SnackType.info => (Icons.info_rounded, colors.accent),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: tone.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: tone),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label(colors.text),
            ),
          ),
        ],
      ),
    );
  }
}
