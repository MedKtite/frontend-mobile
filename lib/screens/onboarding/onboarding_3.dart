import 'package:flutter/material.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

/// Onboarding page 4 — "Your thoughts grow." (Insights pitch.)

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _RingsPainter(colors.text.withValues(alpha: 0.05)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text('2,138', style: AppTypography.statNumber(colors.gilt)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'passages saved across 47 books',
                style: AppTypography.subtitle(colors.text2),
              ),
              const Spacer(flex: 4),
              Text('Your thoughts grow', style: AppTypography.display(colors.text,)),
              Text(
                'with the book.',
                style: AppTypography.display(colors.text)
                    .copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Add notes to any passage. Return months later. '
                'Watch your thinking deepen.',
                style: AppTypography.subtitle(colors.text2),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ],
      ),
    );
  }
}


class _RingsPainter extends CustomPainter {
  const _RingsPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;

    final center = Offset(size.width * 0.82, size.height * 0.16);
    for (final r in [size.width * 0.30, size.width * 0.46, size.width * 0.62]) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.color != color;
}
