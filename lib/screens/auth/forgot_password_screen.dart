import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../services/frontend/auth_validators.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/auth_text_field.dart';

/// Forgot password — request a recovery link (frame `319:2`).
///
/// Sends the entered address to the "Check your email" confirmation. (The
/// backend has no recovery endpoint yet, so the send itself is a stub.)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  /// Pre-fills the field with the address typed on the Login screen, if any.
  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _backToSignIn() =>
      context.canPop() ? context.pop() : context.go(Routes.login);

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // TODO: call the recovery endpoint once it exists; for now go straight to
    // the confirmation screen with the address to display.
    context.push(Routes.checkEmail, extra: _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AuthScaffold(
        title: 'Forgot your password?',
        subtitle: "We'll send you a recovery link. Open it from your inbox.",
        onBack: _backToSignIn,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _email,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              validator: AuthValidators.email,
            ),
            const SizedBox(height: AppSpacing.xl),
            AuthPrimaryButton(label: 'Send recovery link', onPressed: _submit),
            const SizedBox(height: AppSpacing.lg),
            AuthTextLink(label: 'Back to sign in', onTap: _backToSignIn),
          ],
        ),
      ),
    );
  }
}
