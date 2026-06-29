import 'package:flutter/material.dart';

import '../app/theme/tokens/colors.dart';
import '../app/theme/tokens/spacing.dart';
import '../app/theme/tokens/typography.dart';

/// Onboarding page 1 — brand welcome.
///
/// A giant faded "M" sits behind a centered wordmark, gold rule, and italic
/// tagline. Rendered as a page body inside `OnboardingScreen`; the bottom
/// chrome (Begin · "Already have an account") is supplied by the host.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Brand rule above the wordmark — component-spec dimensions.
  static const double _ruleWidth = 32;
  static const double _ruleHeight = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Faded "M" backdrop at 3.5% text opacity (§17).
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.92,
              heightFactor: 0.5,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  'M',
                  style: AppTypography.display(
                    colors.text.withValues(alpha: 0.035),
                  ),
                ),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _ruleWidth,
                height: _ruleHeight,
                color: colors.gilt,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Marginalia', style: AppTypography.wordmark(colors.text)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your reading life, in full.',
                style: AppTypography.subtitle(colors.text2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
