import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/frontend/auth_validators.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/auth_text_field.dart';

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

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(authProvider.notifier).register(
          email: _email.text.trim(),
          password: _password.text,
          displayName: _name.text.trim(),
        );
  }

  void _comingSoon(String what) =>
      showAppSnack(context, '$what — coming soon');

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider) is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthAuthenticated) {
        context.go(Routes.home);
      } else if (next is AuthUnauthenticated) {
        showAppSnack(context, next.message ?? 'An error occurred.',
            type: SnackType.error);
      }
    });

    return Form(
      key: _formKey,
      child: AuthScaffold(
        title: 'Create account',
        subtitle: 'Begin your reading life.',
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.onboarding),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _name,
              hint: 'Name',
              keyboardType: TextInputType.name,
              validator: AuthValidators.displayName,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              controller: _email,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
              controller: _password,
              hint: 'Password',
              obscure: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: AuthValidators.password,
            ),
            const SizedBox(height: AppSpacing.xl),
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
        footer: AuthFooterLink(
          prompt: 'Already have an account?',
          action: 'Sign in',
          onTap: () => context.pushReplacement(Routes.login),
        ),
      ),
    );
  }
}
