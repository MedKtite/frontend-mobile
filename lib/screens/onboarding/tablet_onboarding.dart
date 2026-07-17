import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';

/// iPad onboarding from Figma frames 452:781–464:781. The phone flow remains
/// unchanged; [OnboardingScreen] selects this layout at a 600dp shortest side.
class TabletOnboardingScreen extends StatefulWidget {
  const TabletOnboardingScreen({super.key});

  @override
  State<TabletOnboardingScreen> createState() => _TabletOnboardingScreenState();
}

class _TabletOnboardingScreenState extends State<TabletOnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next(int page) => _controller.animateToPage(
    page + 1,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBg,
      body: PageView(
        controller: _controller,
        children: [
          _WelcomePage(
            onBegin: () => _next(0),
            onSignIn: () => context.push(Routes.login),
          ),
          _LibraryPage(onContinue: () => _next(1)),
          _AnnotationPage(onContinue: () => _next(2)),
          _PromisePage(
            onCreateAccount: () => context.push(Routes.register),
            onSignIn: () => context.push(Routes.login),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onBegin, required this.onSignIn});

  final VoidCallback onBegin;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final portrait = box.maxHeight > box.maxWidth;
        return _NightSurface(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      portrait ? -AppSpacing.xxxl : -AppSpacing.xl,
                    ),
                    child: Text(
                      'M',
                      style: AppTypography.onboardingWatermark(
                        AppColors.onboardingGold.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, portrait ? -AppSpacing.xxxl : 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 1,
                          color: AppColors.onboardingGold,
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'Marginalia',
                          style: AppTypography.onboardingWordmark(
                            AppColors.onboardingText,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Your reading life, in full.',
                          style: AppTypography.onboardingSubtitle(
                            AppColors.onboardingText2,
                          ).copyWith(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: portrait ? 111 : 51,
                child: _Footer(
                  page: 0,
                  actions: [
                    _Button(label: 'Begin', onPressed: onBegin),
                    TextButton(
                      onPressed: onSignIn,
                      child: Text(
                        'Already have an account',
                        style: AppTypography.label(
                          AppColors.onboardingText3,
                        ).copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LibraryPage extends StatelessWidget {
  const _LibraryPage({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final portrait = box.maxHeight > box.maxWidth;
        final copy = _LibraryCopy(onContinue: onContinue);
        return _NightSurface(
          child: portrait
              ? Column(
                  children: [
                    const Expanded(
                      child: _BookFan(alignment: Alignment(0, 0.2)),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.tabletPortraitGutter,
                        ),
                        child: Align(alignment: Alignment.topLeft, child: copy),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    const Expanded(flex: 11, child: _BookFan()),
                    Expanded(
                      flex: 10,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.xl,
                          right: AppSpacing.tabletGutter,
                        ),
                        child: copy,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _LibraryCopy extends StatelessWidget {
  const _LibraryCopy({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormatPills(),
        const SizedBox(height: AppSpacing.xl),
        Text.rich(
          TextSpan(
            style: AppTypography.onboardingHero(
              AppColors.onboardingText,
            ).copyWith(fontSize: 46, height: 1.08),
            children: const [
              TextSpan(text: 'Every book you read.\n'),
              TextSpan(
                text: 'Every word you hear.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'One unified library. Seamlessly synced across every device you own.',
          style: AppTypography.onboardingSubtitle(AppColors.onboardingText2),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        _Footer(
          page: 1,
          align: CrossAxisAlignment.start,
          actions: [_Button(label: 'Continue', onPressed: onContinue)],
        ),
      ],
    );
  }
}

class _BookFan extends StatelessWidget {
  const _BookFan({this.alignment = Alignment.center});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 400,
        height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: const [
            _Cover('Bluets', 'Maggie Nelson', Color(0xFF3C5A8C), -120, -0.19),
            _Cover('Stoner', 'John Williams', Color(0xFF7A5C3A), 120, 0.19),
            _Cover(
              'The Overstory',
              'Richard Powers',
              Color(0xFF2D4A3E),
              0,
              0,
              hero: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cover colors are book content, not interface colors.
class _Cover extends StatelessWidget {
  const _Cover(
    this.title,
    this.author,
    this.color,
    this.dx,
    this.angle, {
    this.hero = false,
  });

  final String title;
  final String author;
  final Color color;
  final double dx;
  final double angle;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(dx, 0),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: hero ? 164 : 140,
          height: hero ? 246 : 210,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadii.brXs,
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: AppSpacing.xxl,
                offset: const Offset(0, AppSpacing.md),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.title3(
                  AppColors.onboardingText,
                ).copyWith(fontSize: hero ? 20 : 17),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                author,
                style: AppTypography.caption(
                  AppColors.onboardingText.withValues(alpha: 0.7),
                ).copyWith(fontSize: hero ? 11 : 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormatPills extends StatelessWidget {
  const _FormatPills();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: const [_Pill('Ebooks'), _Pill('Audiobooks'), _Pill('PDFs')],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.onboardingText3),
        borderRadius: AppRadii.brMd,
      ),
      child: Text(
        label,
        style: AppTypography.caption(
          AppColors.onboardingText2,
        ).copyWith(fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _AnnotationPage extends StatelessWidget {
  const _AnnotationPage({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final portrait = box.maxHeight > box.maxWidth;
        return _NightSurface(
          child: portrait
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.tabletPortraitGutter,
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      const _AnnotationTitle(centered: true),
                      const Spacer(),
                      const _PassageCard(),
                      const Spacer(),
                      const _Tags(),
                      const SizedBox(height: AppSpacing.xxxl),
                      _Footer(
                        page: 2,
                        actions: [
                          _Button(label: 'Continue', onPressed: onContinue),
                        ],
                      ),
                      const Spacer(flex: 4),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.tabletGutter,
                          right: AppSpacing.xxxl,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _AnnotationTitle(),
                            const SizedBox(height: AppSpacing.xxxl),
                            const _Tags(),
                            const SizedBox(height: AppSpacing.xxxl),
                            _Footer(
                              page: 2,
                              align: CrossAxisAlignment.start,
                              actions: [
                                _Button(
                                  label: 'Continue',
                                  onPressed: onContinue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(child: Center(child: _PassageCard())),
                    const SizedBox(width: AppSpacing.tabletGutter),
                  ],
                ),
        );
      },
    );
  }
}

class _AnnotationTitle extends StatelessWidget {
  const _AnnotationTitle({this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Leave your mark.',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: AppTypography.onboardingHero(AppColors.onboardingText),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Seven colors. Infinite meaning.',
          style: AppTypography.onboardingSubtitle(AppColors.onboardingText2),
        ),
      ],
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags();

  static const values = <(String, Color)>[
    ('URGENT', AppColors.tagUrgent),
    ('CURIOUS', AppColors.tagCurious),
    ('RESONANT', AppColors.tagResonant),
    ('BEAUTIFUL', AppColors.tagBeautiful),
    ('REFERENCE', AppColors.tagReference),
    ('DISAGREE', AppColors.tagDisagree),
    ('REVISIT', AppColors.tagRevisit),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 380,
      child: Wrap(
        spacing: AppSpacing.xl,
        runSpacing: AppSpacing.xl + 2,
        children: [for (final tag in values) _Tag(tag.$1, tag.$2)],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.34),
                  blurRadius: AppSpacing.xl,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.overline(
              AppColors.onboardingText3,
            ).copyWith(fontSize: 9.5, letterSpacing: 0.8),
          ),
        ],
      ),
    );
  }
}

class _PassageCard extends StatelessWidget {
  const _PassageCard();

  @override
  Widget build(BuildContext context) {
    final quote = AppTypography.onboardingSubtitle(
      AppColors.onboardingText,
    ).copyWith(fontSize: 22, height: 1.6);
    return Container(
      width: 440,
      padding: const EdgeInsets.fromLTRB(50, 34, 38, 34),
      decoration: BoxDecoration(
        color: AppColors.onboardingSurface,
        borderRadius: AppRadii.brXl,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 60,
            offset: const Offset(0, AppSpacing.lg),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -34,
            top: -AppSpacing.xs,
            bottom: -AppSpacing.xs,
            child: Container(
              width: 3,
              decoration: const BoxDecoration(
                color: AppColors.tagBeautiful,
                borderRadius: AppRadii.brFull,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: quote,
                  children: const [
                    TextSpan(text: 'For some time I have been moving toward '),
                    TextSpan(
                      text: 'a desire to be inarticulate',
                      style: TextStyle(color: AppColors.tagBeautiful),
                    ),
                    TextSpan(text: ', to escape '),
                    TextSpan(
                      text: 'the constant pressure of the metaphor',
                      style: TextStyle(color: AppColors.tagResonant),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'BLUETS · MAGGIE NELSON',
                style: AppTypography.overline(
                  AppColors.onboardingText3,
                ).copyWith(letterSpacing: 1.4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromisePage extends StatelessWidget {
  const _PromisePage({required this.onCreateAccount, required this.onSignIn});

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final portrait = box.maxHeight > box.maxWidth;
        final footer = _Footer(
          page: 3,
          align: portrait
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          actions: [
            _Button(label: 'Create account', onPressed: onCreateAccount),
            _Button(label: 'Sign in', onPressed: onSignIn, ghost: true),
          ],
        );
        return ColoredBox(
          color: AppColors.onboardingSurface,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _RingsPainter()),
              ),
              if (portrait)
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -AppSpacing.xxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Stat(centered: true),
                        const SizedBox(height: AppSpacing.xxxl),
                        const _PromiseCopy(centered: true),
                        const SizedBox(height: AppSpacing.xxxl),
                        footer,
                      ],
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: AppSpacing.tabletGutter),
                        child: _Stat(),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: AppSpacing.tabletGutter,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _PromiseCopy(),
                            const SizedBox(height: AppSpacing.xxxl),
                            footer,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '2,138',
          style: AppTypography.onboardingStat(AppColors.onboardingGold),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'passages saved across 47 books',
          style: AppTypography.onboardingSubtitle(
            AppColors.onboardingText2,
          ).copyWith(fontSize: 20),
        ),
      ],
    );
  }
}

class _PromiseCopy extends StatelessWidget {
  const _PromiseCopy({this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 440,
      child: Column(
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(width: 44, height: 1, color: AppColors.onboardingGold),
          const SizedBox(height: AppSpacing.xl),
          Text.rich(
            TextSpan(
              style: AppTypography.onboardingHeroCompact(
                AppColors.onboardingText,
              ),
              children: const [
                TextSpan(text: 'Your thoughts grow\n'),
                TextSpan(
                  text: 'with the book.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Add notes to any passage. Return months later. '
            'Watch your thinking deepen.',
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: AppTypography.onboardingSubtitle(
              AppColors.onboardingText2,
            ).copyWith(fontSize: 17, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.page,
    required this.actions,
    this.align = CrossAxisAlignment.center,
  });

  final int page;
  final List<Widget> actions;
  final CrossAxisAlignment align;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      children: [
        _Dots(page),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.md,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: actions,
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots(this.page);

  final int page;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 4; i++) ...[
          Container(
            width: i == page ? AppSpacing.xxl - 2 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == page
                  ? AppColors.onboardingGold
                  : AppColors.onboardingText3,
              borderRadius: AppRadii.brFull,
            ),
          ),
          if (i < 3) const SizedBox(width: 7),
        ],
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onPressed,
    this.ghost = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool ghost;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: AppTypography.onboardingButton(
        ghost ? AppColors.onboardingText2 : AppColors.onboardingBg,
      ),
    );
    return SizedBox(
      height: 49,
      child: ghost
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.onboardingText3),
                padding: const EdgeInsets.symmetric(horizontal: 42),
                shape: const StadiumBorder(),
              ),
              child: child,
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.onboardingText,
                padding: const EdgeInsets.symmetric(horizontal: 42),
                shape: const StadiumBorder(),
              ),
              child: child,
            ),
    );
  }
}

class _NightSurface extends StatelessWidget {
  const _NightSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: AppColors.onboardingBg, child: child);
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final portrait = size.height > size.width;
    final center = portrait
        ? Offset(size.width / 2, size.height * 0.31)
        : Offset(size.width * 0.8, size.height / 2);
    final base = math.min(size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.onboardingGold.withValues(alpha: 0.08);
    canvas
      ..drawCircle(center, base * 0.25, paint)
      ..drawCircle(center, base / 3, paint);
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) => false;
}
