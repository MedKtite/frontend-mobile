import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/frontend/auth_validators.dart';
import '../../services/frontend/auth_error_messages.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/glass_panel.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token, this.email});

  final String token;
  final String? email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _confirmValidator(String? v) {
    final base = AuthValidators.password(v);
    if (base != null) return base;
    if (v != _password.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.token.isEmpty) {
      showAppSnack(
        context,
        'Verification code is missing. Please enter your code again.',
        type: SnackType.error,
      );
      context.pop();
      return;
    }

    FocusScope.of(context).unfocus();
    final reset = await ref
        .read(authProvider.notifier)
        .resetPassword(
          token: widget.token,
          password: _password.text,
          email: widget.email,
        );

    if (!mounted) return;

    if (reset) {
      showAppSnack(
        context,
        'Password updated successfully! Sign in to continue.',
        type: SnackType.success,
      );
      context.go(Routes.login);
      return;
    }

    final state = ref.read(authProvider);
    if (state is AuthUnauthenticated && state.message != null) {
      showAppSnack(
        context,
        AuthErrorMessages.from(
          state.message,
          context: AuthErrorContext.resetPassword,
        ),
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final loading = ref.watch(authProvider) is AuthLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: AuthBackButton(onPressed: () => context.pop()),
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassPanel(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 32,
                            color: colors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Set a new password',
                        textAlign: TextAlign.center,
                        style: AppTypography.title1(colors.text),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.email != null && widget.email!.isNotEmpty
                            ? 'Create a new password for ${widget.email}'
                            : 'Choose a strong password with at least 6 characters.',
                        textAlign: TextAlign.center,
                        style: AppTypography.subtitle(colors.text2),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),

                      Text(
                        'NEW PASSWORD',
                        style: AppTypography.overline(colors.text3),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        controller: _password,
                        hint: 'New password (min. 6 characters)',
                        obscure: true,
                        validator: AuthValidators.password,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'CONFIRM PASSWORD',
                        style: AppTypography.overline(colors.text3),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppTextField(
                        controller: _confirm,
                        hint: 'Confirm your new password',
                        obscure: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: _confirmValidator,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      AuthPrimaryButton(
                        label: 'Save New Password',
                        loading: loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
