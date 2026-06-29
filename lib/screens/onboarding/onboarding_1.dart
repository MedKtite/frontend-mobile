import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

/// Onboarding page 2 — "Every book you read." (Library / formats pitch.)

class Onboarding1 extends StatelessWidget {
  const Onboarding1({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 3),
          const Center(child: _DemoCover()),
          const SizedBox(height: AppSpacing.xl),
          const Center(child: _FormatPills()),
          const Spacer(flex: 4),
          Text('Every book you read.', style: AppTypography.display(colors.text)),
          Text(
            'Every word you hear.',
            style: AppTypography.display(colors.text)
                .copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'One unified library. Seamlessly synced.',
            style: AppTypography.subtitle(colors.text2),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

/// Illustrative book cover (The Overstory). Cover colors are per-book content,
/// not system tokens (design-system.md §8 — "flat color panel + type only").
class _DemoCover extends StatelessWidget {
  const _DemoCover();

  // §8: width 88 default · height = width × 1.5. Scaled up for the hero slot.
  static const double _width = 118;
  static const double _height = _width * 1.5;
  static const Color _coverBg = Color(0xFF2E4034);
  static const Color _coverFg = Color(0xFFEDE9E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _width,
      height: _height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _coverBg,
        borderRadius: AppRadii.brXs,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The\nOverstory', style: AppTypography.title2(_coverFg)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'RICHARD POWERS',
            style: AppTypography.overline(_coverFg.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}

class _FormatPills extends StatelessWidget {
  const _FormatPills();

  static const _labels = ['Ebooks', 'Audiobooks', 'PDFs'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [for (final l in _labels) _Pill(label: l)],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: AppRadii.brFull,
      ),
      child: Text(
        label,
        style: AppTypography.caption(colors.text2)
            .copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}
