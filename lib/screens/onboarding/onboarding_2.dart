import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

/// Onboarding page 3 — "Leave your mark." (Tagging / annotation pitch.)
///
/// Title + subtitle, the seven tag colors in a row that bleeds off the right
/// edge, and a sample Bluets highlight card with gold underlines.
class Onboarding2 extends StatelessWidget {
  const Onboarding2({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leave your mark.', style: AppTypography.display(colors.text)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Seven colors. Infinite meaning.',
                style: AppTypography.subtitle(colors.text2),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _TagRow(),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
          child: _BluetsCard(),
        ),
        const Spacer(),
      ],
    );
  }
}

class _TagRow extends StatelessWidget {
  const _TagRow();

  // Matches the seven seeded system tags (design-system.md §2 / schema.sql).
  static const _tags = <(String, Color)>[
    ('Urgent', AppColors.tagUrgent),
    ('Curious', AppColors.tagCurious),
    ('Resonant', AppColors.tagResonant),
    ('Beautiful', AppColors.tagBeautiful),
    ('Reference', AppColors.tagReference),
    ('Disagree', AppColors.tagDisagree),
    ('Revisit', AppColors.tagRevisit),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
      ),
      child: Row(
        children: [
          for (final (label, color) in _tags)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xl),
              child: _TagItem(label: label, color: color),
            ),
        ],
      ),
    );
  }
}

class _TagItem extends StatelessWidget {
  const _TagItem({required this.label, required this.color});

  final String label;
  final Color color;

  // §8 tag dot active size; matches AppSpacing.xxl (28).
  static const double _dotSize = AppSpacing.xxl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(label.toUpperCase(), style: AppTypography.overline(colors.text2)),
      ],
    );
  }
}

/// Sample highlight card — gold accent bar, italic serif passage with gold
/// underlines on the highlighted spans, and a source byline.
class _BluetsCard extends StatelessWidget {
  const _BluetsCard();

  // Thin gold accent bar at the card's leading edge.
  static const double _barWidth = 3;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final base = AppTypography.subtitle(colors.text);
    final marked = base.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: colors.gilt,
      decorationThickness: 2,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.quote,
        borderRadius: AppRadii.brMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: _barWidth, color: colors.gilt),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: base,
                        children: [
                          const TextSpan(
                            text: 'For some time I have been moving toward ',
                          ),
                          TextSpan(
                            text: 'a desire to be inarticulate',
                            style: marked,
                          ),
                          const TextSpan(text: ', to escape '),
                          TextSpan(
                            text: 'the constant pressure of the metaphor',
                            style: marked,
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'BLUETS · MAGGIE NELSON',
                      style: AppTypography.overline(colors.text3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
