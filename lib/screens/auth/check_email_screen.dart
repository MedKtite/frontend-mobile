import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/glass_panel.dart';

/// "Check your email" recovery confirmation (frame `319:22`).
///
/// Centered envelope badge, the address the link was sent to, an Open Mail CTA,
/// and a resend link gated behind a 30s countdown.
class CheckEmailScreen extends StatefulWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  State<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends State<CheckEmailScreen> {
  static const _resendSeconds = 30;
  static const double _badgeSize = 88;

  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _secondsLeft = _resendSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _toast(String message) => showAppSnack(context, message);

  void _resend() {
    _startCountdown();
    _toast('Recovery link resent');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final canResend = _secondsLeft == 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthBackButton(onPressed: () => context.pop()),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Content on the shared glass card, matching the other
                    // auth screens. (Centered is fine here — no keyboard.)
                    GlassPanel(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    Center(
                      child: Container(
                        width: _badgeSize,
                        height: _badgeSize,
                        decoration: BoxDecoration(
                          color: colors.surface2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mail_outline,
                          size: 32,
                          color: colors.text2,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Check your email.',
                      textAlign: TextAlign.center,
                      style: AppTypography.title1(colors.text),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'We sent a recovery link to ${widget.email}. '
                      'Tap it from your inbox to reset.',
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle(colors.text2),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    AuthPrimaryButton(
                      label: 'Open Mail',
                      onPressed: () => _toast('Open your mail app to continue'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AuthTextLink(
                      label: canResend ? 'Resend link' : 'Resend in ${_secondsLeft}s',
                      muted: !canResend,
                      onTap: canResend ? _resend : null,
                    ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
