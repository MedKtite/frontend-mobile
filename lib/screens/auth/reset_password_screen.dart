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
import '../../widgets/auth_scaffold.dart';
import '../../widgets/glass_panel.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});

  final String token;

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
        'This recovery link is invalid. Request a new one.',
        type: SnackType.error,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final reset = await ref.read(authProvider.notifier).resetPassword(
          token: widget.token,
          password: _password.text,
        );
    if (!mounted) return;
    if (reset) {
      showAppSnack(
        context,
        'Password updated — sign in to continue',
        type: SnackType.success,
      );
      context.go(Routes.login);
      return;
    }
    final state = ref.read(authProvider);
    if (state is AuthUnauthenticated && state.message != null) {
      showAppSnack(context, state.message!, type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final loading = ref.watch(authProvider) is AuthLoading;

    return Form(
      key: _formKey,
      child: AuthScaffold(
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.login),
        body: GlassPanel(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Set a new password',
                style: AppTypography.title1(colors.text),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose a new password to finish resetting your account.',
                style: AppTypography.subtitle(colors.text2),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _password,
                hint: 'New password',
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
              const SizedBox(height: AppSpacing.xl),
              AuthPrimaryButton(
                label: 'Reset password',
                loading: loading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
