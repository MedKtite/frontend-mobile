import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/frontend/auth_validators.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/glass_panel.dart';

/// Forgot password — request a recovery link (frame `319:2`).
///
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  /// Pre-fills the field with the address typed on the Login screen, if any.
  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _backToSignIn() =>
      context.canPop() ? context.pop() : context.go(Routes.login);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final sent = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(email: _email.text.trim());
    if (sent && mounted) {
      context.push(Routes.checkEmail, extra: _email.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final loading = ref.watch(authProvider) is AuthLoading;

    return Form(
      key: _formKey,
      child: AuthScaffold(
        onBack: _backToSignIn,
        body: GlassPanel(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Forgot your password?',
                style: AppTypography.title1(colors.text),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "We'll send you a recovery link. Open it from your inbox.",
                style: AppTypography.subtitle(colors.text2),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _email,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: AuthValidators.email,
              ),
              const SizedBox(height: AppSpacing.xl),
              AuthPrimaryButton(
                label: 'Send recovery link',
                loading: loading,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.lg),
              AuthTextLink(label: 'Back to sign in', onTap: _backToSignIn),
            ],
          ),
        ),
      ),
    );
  }
}
