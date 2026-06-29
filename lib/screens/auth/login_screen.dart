import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/frontend/auth_validators.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/auth_text_field.dart';

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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(authProvider.notifier).login(
          email: _email.text.trim(),
          password: _password.text,
        );
  }

  void _comingSoon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$what — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final loading = ref.watch(authProvider) is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthAuthenticated) {
        context.go(Routes.home);
      } else if (next is AuthUnauthenticated ) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text( 'An error occurred.')));
      }
    });

    return Center(
      
      child: Form(
      key: _formKey,
      child: AuthScaffold(
        title: 'Welcome back',
        subtitle: 'Sign in to continue your reading.',
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.onboarding),
        body: 
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.md),
          ),
          child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email Address',
                  style: AppTypography.caption( colors.text2),
                ),
                const SizedBox(height: AppSpacing.sm),
            AuthTextField(
              controller: _email,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.email,
            ),  ],
            ),
            const SizedBox(height: AppSpacing.md),
              Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password',
                  style: AppTypography.caption( colors.text2),
                ),
                const SizedBox(height: AppSpacing.sm),
            AuthTextField(
              controller: _password,
              hint: 'Password',
              obscure: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: AuthValidators.password,
            ),]),
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
                onTap: () =>
                    context.push(Routes.forgotPassword, extra: _email.text.trim()),
                child: Text(
                  'Forgot password?',
                  style: AppTypography.label(colors.text2),
                ),
              ),]),
            
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
              onPressed: () => _comingSoon('Google sign-in'),
            ),
            const SizedBox(height: AppSpacing.md),
            SocialAuthButton(
              glyph: 'devicon_twitter',
              label: 'Continue with X',
              onPressed: () => _comingSoon('X sign-in'),
            ),
          ],
        ),),
        footer: AuthFooterLink(
          prompt: "Don't have an account?",
          action: 'Register',
          onTap: () => context.pushReplacement(Routes.register),
        ),
      ),
      ),
    );
  }
}
