import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../services/frontend/auth_validators.dart';
import '../../widgets/auth_scaffold.dart';
import '../../core/widgets/app_text_field.dart';
import '../../widgets/glass_panel.dart';

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
    final colors = context.appColors;
    return Form(
      key: _formKey,
      child: AuthScaffold(
        // Heading lives INSIDE the glass card, matching the login screen.
        onBack: _backToSignIn,
        body: GlassPanel(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Forgot your password?',
                style: AppTypography.title1(colors.text)),
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
            AuthPrimaryButton(label: 'Send recovery link', onPressed: _submit),
            const SizedBox(height: AppSpacing.lg),
            AuthTextLink(label: 'Back to sign in', onTap: _backToSignIn),
          ],
        ),),
      ),
    );
  }
}
