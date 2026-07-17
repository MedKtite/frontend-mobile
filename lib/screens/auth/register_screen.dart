import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/frontend/auth_validators.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/glass_panel.dart';

/// Register — create an account (frame `78:122`).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _acceptedTerms = false;
  bool _emailUpdates = false; // reading digests & product news (opt-in)

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != _password.text) return 'Passwords do not match';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      showAppSnack(
        context,
        'Please accept the Terms & Privacy to continue.',
        type: SnackType.warning,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    // TODO(backend): persist _emailUpdates once RegisterRequest carries an
    // email-opt-in flag (notification_preferences).
    ref
        .read(authProvider.notifier)
        .register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
        );
  }

  void _comingSoon(String what) => showAppSnack(context, '$what — coming soon');

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final loading = ref.watch(authProvider) is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthAuthenticated) {
        context.go(Routes.home);
      } else if (next is AuthUnauthenticated) {
        showAppSnack(
          context,
          next.message ?? 'An error occurred.',
          type: SnackType.error,
        );
      }
    });

    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final registerCard = GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isTablet) ...[
            Text('Create account', style: AppTypography.title1(colors.text)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Begin your reading life.',
              style: AppTypography.subtitle(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          AppTextField(
            controller: _name,
            hint: 'Name',
            keyboardType: TextInputType.name,
            validator: AuthValidators.displayName,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _email,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: AuthValidators.email,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _password,
            hint: 'Password',
            obscure: true,
            validator: AuthValidators.password,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _confirm,
            hint: 'Confirm password',
            obscure: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            validator: _confirmValidator,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ConsentRow(
            value: _acceptedTerms,
            onChanged: (v) => setState(() => _acceptedTerms = v),
            label: 'I accept the Terms of Service and Privacy Policy.',
          ),
          _ConsentRow(
            value: _emailUpdates,
            onChanged: (v) => setState(() => _emailUpdates = v),
            label: 'Email me reading digests and product updates.',
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthPrimaryButton(
            label: 'Create account',
            loading: loading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.xl),
          const OrDivider(),
          const SizedBox(height: AppSpacing.xl),
          SocialAuthButton(
            glyph: 'google', // assets are google.svg / devicon_twitter.svg
            label: 'Continue with Google',
            monochrome: false,
            onPressed: () => _comingSoon('Google sign-in'),
          ),
          const SizedBox(height: AppSpacing.md),
          SocialAuthButton(
            glyph: 'devicon_twitter',
            label: 'Continue with X',
            onPressed: () => _comingSoon('X sign-in'),
          ),
        ],
      ),
    );
    final footer = AuthFooterLink(
      prompt: 'Already have an account?',
      action: 'Sign in',
      onTap: () => context.pushReplacement(Routes.login),
    );
    void onBack() {
      context.canPop() ? context.pop() : context.go(Routes.onboarding);
    }

    return Form(
      key: _formKey,
      child: isTablet
          ? _TabletRegisterLayout(registerCard: registerCard, footer: footer)
          : AuthScaffold(onBack: onBack, body: registerCard, footer: footer),
    );
  }
}

class _TabletRegisterLayout extends StatelessWidget {
  const _TabletRegisterLayout({
    required this.registerCard,
    required this.footer,
  });

  final Widget registerCard;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.sizeOf(context).aspectRatio > 1;
    final welcome = const _TabletRegisterWelcomePanel();
    final form = AuthScaffold(
      showBack: false,
      body: registerCard,
      footer: footer,
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: landscape
              ? Row(
                  children: [
                    Expanded(child: welcome),
                    const SizedBox(width: AppSpacing.xxl),
                    Expanded(child: form),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: welcome),
                    const SizedBox(height: AppSpacing.xxl),
                    Expanded(flex: 2, child: form),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TabletRegisterWelcomePanel extends StatelessWidget {
  const _TabletRegisterWelcomePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppColors.onboardingBg,
        borderRadius: AppRadii.brXl,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                'M',
                style: AppTypography.onboardingWatermark(
                  AppColors.onboardingGold.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppSpacing.xxxl,
                  height: 1,
                  color: AppColors.onboardingGold,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'Begin your reading\nlife with Marginalia.',
                  style: AppTypography.onboardingHero(AppColors.onboardingText),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Build your library, collect meaningful passages, and keep '
                  'every thought beside the words that inspired it.',
                  style: AppTypography.onboardingSubtitle(
                    AppColors.onboardingText2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact checkbox + wrapping label; the whole row toggles.
class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Text(label, style: AppTypography.caption(colors.text2)),
          ),
        ],
      ),
    );
  }
}
