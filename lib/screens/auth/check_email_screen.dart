import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/glass_panel.dart';

/// "Check your email" recovery confirmation (frame `319:22`).
///
/// Centered envelope badge, the address the link was sent to, an Open Mail CTA,
/// and a resend link gated behind a 30s countdown.
class CheckEmailScreen extends ConsumerStatefulWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen> {
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

  Future<void> _resend() async {
    final sent = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(email: widget.email);
    if (!mounted) return;
    if (sent) {
      _startCountdown();
      _toast('Recovery link resent');
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
    final canResend = _secondsLeft == 0 && !loading;

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
                            'If an account exists for ${widget.email}, we sent '
                            'a recovery link. Tap it from your inbox to reset.',
                            textAlign: TextAlign.center,
                            style: AppTypography.subtitle(colors.text2),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          AuthPrimaryButton(
                            label: 'Open Mail',
                            onPressed: () =>
                                _toast('Open your mail app to continue'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AuthTextLink(
                            label: canResend
                                ? 'Resend link'
                                : loading
                                    ? 'Sending…'
                                    : 'Resend in ${_secondsLeft}s',
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
