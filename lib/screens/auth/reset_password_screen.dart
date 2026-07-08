import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../services/frontend/auth_validators.dart';
import '../../widgets/auth_scaffold.dart';
import '../../core/widgets/app_text_field.dart';
import '../../widgets/glass_panel.dart';

/// Reset password — set a new password (not in Figma; built on the auth
/// vocabulary). This is the destination of the emailed recovery link, so in
/// production it arrives with a token (deep link). Submit is stubbed until the
/// backend exposes a reset endpoint.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // TODO: call the reset endpoint with the recovery token once it exists.
    context.go(Routes.login);
    showAppSnack(context, 'Password updated — sign in to continue',
        type: SnackType.success);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Form(
      key: _formKey,
      child: AuthScaffold(
        // Heading lives INSIDE the glass card, matching the login screen.
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.login),
        body: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set a new password',
                style: AppTypography.title1(colors.text)),
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
            AuthPrimaryButton(label: 'Reset password', onPressed: _submit),
          ],
        ),),
      ),
    );
  }
}
