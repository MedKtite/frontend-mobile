import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../services/frontend/auth_validators.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/auth_text_field.dart';

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
    return Form(
      key: _formKey,
      child: AuthScaffold(
        title: 'Set a new password',
        subtitle: 'Choose a new password to finish resetting your account.',
        onBack: () =>
            context.canPop() ? context.pop() : context.go(Routes.login),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _password,
              hint: 'New password',
              obscure: true,
              validator: AuthValidators.password,
            ),
            const SizedBox(height: AppSpacing.md),
            AuthTextField(
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
        ),
      ),
    );
  }
}
