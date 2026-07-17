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

/// Login — authenticate a returning user (frame `78:66`).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref
        .read(authProvider.notifier)
        .login(email: _email.text.trim(), password: _password.text);
  }

  String? _passwordValidator(String? value) {
    return AuthValidators.password(value) ?? _passwordError;
  }

  void _clearPasswordError(String _) {
    if (_passwordError != null) setState(() => _passwordError = null);
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
        final message = next.message ?? 'An error occurred.';
        if (message.toLowerCase().contains('incorrect email or password')) {
          setState(() => _passwordError = message);
          _formKey.currentState?.validate();
        } else {
          showAppSnack(context, message, type: SnackType.error);
        }
      }
    });

    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final loginCard = _buildLoginCard(colors, loading, showHeading: !isTablet);
    final footer = AuthFooterLink(
      prompt: "Don't have an account?",
      action: 'Register',
      onTap: () => context.pushReplacement(Routes.register),
    );
    void onBack() {
      context.canPop() ? context.pop() : context.go(Routes.onboarding);
    }

    return Form(
      key: _formKey,
      child: isTablet
          ? _TabletLoginLayout(loginCard: loginCard, footer: footer)
          : AuthScaffold(onBack: onBack, body: loginCard, footer: footer),
    );
  }

  Widget _buildLoginCard(
    AppColorsExtension colors,
    bool loading, {
    required bool showHeading,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeading) ...[
            Text('Welcome back', style: AppTypography.title1(colors.text)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sign in to continue your reading.',
              style: AppTypography.subtitle(colors.text2),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email Address', style: AppTypography.caption(colors.text2)),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _email,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: AuthValidators.email,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password', style: AppTypography.caption(colors.text2)),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _password,
                hint: 'Password',
                obscure: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: _clearPasswordError,
                validator: _passwordValidator,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (_) => _comingSoon('Remember me'),
                  ),
                  GestureDetector(
                    onTap: () => _comingSoon('Remember me'),
                    child: Text(
                      'Remember me',
                      style: AppTypography.label(colors.text2),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push(
                  Routes.forgotPassword,
                  extra: _email.text.trim(),
                ),
                child: Text(
                  'Forgot password?',
                  style: AppTypography.label(colors.text2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthPrimaryButton(
            label: 'Sign in',
            loading: loading,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.xl),
          const OrDivider(),
          const SizedBox(height: AppSpacing.xl),
          SocialAuthButton(
            glyph: 'google',
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
  }
}

class _TabletLoginLayout extends StatelessWidget {
  const _TabletLoginLayout({required this.loginCard, required this.footer});

  final Widget loginCard;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final landscape = MediaQuery.sizeOf(context).aspectRatio > 1;
    final welcome = const _TabletWelcomePanel();
    final form = AuthScaffold(showBack: false, body: loginCard, footer: footer);

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

class _TabletWelcomePanel extends StatelessWidget {
  const _TabletWelcomePanel();

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
                  'Welcome back\nto Marginalia.',
                  style: AppTypography.onboardingHero(AppColors.onboardingText),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Your library, your colors, and every passage you’ve marked '
                  '— exactly where you left them.',
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
