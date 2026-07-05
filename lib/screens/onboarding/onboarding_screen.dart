import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../welcome_screen.dart';
import 'onboarding_1.dart';
import 'onboarding_2.dart';
import 'onboarding_3.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 4;

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index) => _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );

  void _next() {
    if (_page < _pageCount - 1) _goTo(_page + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  WelcomeScreen(),
                  Onboarding1(),
                  Onboarding2(),
                  Onboarding3(),
                ],
              ),
            ),
            _BottomChrome(
              page: _page,
              pageCount: _pageCount,
              onDotTap: _goTo,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

/// Fixed bottom area: progress dots above a per-page call-to-action.
class _BottomChrome extends StatelessWidget {
  const _BottomChrome({
    required this.page,
    required this.pageCount,
    required this.onDotTap,
    required this.onNext,
  });

  final int page;
  final int pageCount;
  final ValueChanged<int> onDotTap;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DotsIndicator(
            count: pageCount,
            activeIndex: page,
            onTap: onDotTap,
          ),
          const SizedBox(height: AppSpacing.xl),
          _Cta(page: page, onNext: onNext),
        ],
      ),
    );
  }
}

/// Swaps the call-to-action with the active page:

class _Cta extends StatelessWidget {
  const _Cta({required this.page, required this.onNext});

  final int page;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    switch (page) {
      case 0:
        return Column(
          children: [
            _PrimaryButton(label: 'Begin', onPressed: onNext),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.push(Routes.login),
              child: Text(
                'Already have an account',
                style: AppTypography.label(colors.text2),
              ),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            _PrimaryButton(
              label: 'Create account',
              onPressed: () => context.push(Routes.register),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                // style: OutlinedButton.styleFrom(
                //   backgroundColor: colors.surface,
                // ),
                
                onPressed: () => context.push(Routes.login),
                child: const Text('Sign in'),
              ),
            ),
          ],
        );
      default:
        return _PrimaryButton(label: 'Continue', onPressed: onNext);
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}


class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.activeIndex,
    required this.onTap,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int> onTap;

  // Component-spec dimensions (§17); active width matches AppSpacing.xl (20).
  static const double _dotSize = 6;
  static const double _activeWidth = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return GestureDetector(
          onTap: () => onTap(i),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              width: active ? _activeWidth : _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(
                color: active ? colors.gilt : colors.text3,
                borderRadius: AppRadii.brFull,
              ),
            ),
          ),
        );
      }),
    );
  }
}
