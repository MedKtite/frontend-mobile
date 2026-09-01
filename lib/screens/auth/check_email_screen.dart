import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../app/theme/tokens/colors.dart';
import '../../app/theme/tokens/radii.dart';
import '../../app/theme/tokens/spacing.dart';
import '../../app/theme/tokens/typography.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/state/auth_state.dart';
import '../../services/frontend/auth_error_messages.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/glass_panel.dart';

class CheckEmailScreen extends ConsumerStatefulWidget {
  const CheckEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<CheckEmailScreen> createState() => _CheckEmailScreenState();
}

class _CheckEmailScreenState extends ConsumerState<CheckEmailScreen>
    with WidgetsBindingObserver {
  static const _resendSeconds = 30;

  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  String _lastCheckedClipboard = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCountdown();
    // Check clipboard for 6-digit code when opening
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkClipboardForCode());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForCode();
    }
  }

  Future<void> _checkClipboardForCode() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isNotEmpty &&
          text != _lastCheckedClipboard &&
          RegExp(r'^\d{6}$').hasMatch(text)) {
        _lastCheckedClipboard = text;
        _populateCode(text);
        if (mounted) {
          showAppSnack(context, 'Code $text pasted from clipboard',
              type: SnackType.success);
        }
      }
    } catch (_) {
      // clipboard error ignored
    }
  }

  void _populateCode(String code) {
    if (code.length != 6) return;
    for (var i = 0; i < 6; i++) {
      _codeControllers[i].text = code[i];
    }
    FocusScope.of(context).unfocus();
  }

  String get _currentCode =>
      _codeControllers.map((c) => c.text.trim()).join();

  void _startCountdown() {
    setState(() => _secondsLeft = _resendSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    final sent = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(email: widget.email);
    if (!mounted) return;
    if (sent) {
      _startCountdown();
      showAppSnack(context, 'New 6-digit code sent to your inbox',
          type: SnackType.success);
    } else {
      final state = ref.read(authProvider);
      if (state is AuthUnauthenticated && state.message != null) {
        showAppSnack(
          context,
          AuthErrorMessages.from(state.message,
              context: AuthErrorContext.recovery),
          type: SnackType.error,
        );
      }
    }
  }

  void _proceedToNewPassword() {
    final code = _currentCode;
    if (code.length != 6) {
      showAppSnack(context, 'Please enter all 6 digits of the reset code.',
          type: SnackType.error);
      return;
    }
    context.push(
      Routes.resetPassword,
      extra: {'code': code, 'email': widget.email},
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final loading = ref.watch(authProvider) is AuthLoading;
    final canResend = _secondsLeft == 0 && !loading;
    final isCodeComplete = _currentCode.length == 6;

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
                          Icons.mark_email_unread_outlined,
                          size: 32,
                          color: colors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Enter 6-digit code',
                      textAlign: TextAlign.center,
                      style: AppTypography.title1(colors.text),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'We sent a verification code to\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle(colors.text2),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // 6-Digit PIN Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44,
                          height: 54,
                          child: TextField(
                            controller: _codeControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: AppTypography.title2(colors.text).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: colors.surface,
                              border: OutlineInputBorder(
                                borderRadius: AppRadii.brMd,
                                borderSide: BorderSide(color: colors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadii.brMd,
                                borderSide:
                                    BorderSide(color: colors.accent, width: 2),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {}); // refresh complete state
                              if (value.isNotEmpty) {
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  _focusNodes[index].unfocus();
                                  _proceedToNewPassword();
                                }
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    AuthPrimaryButton(
                      label: 'Continue',
                      loading: loading,
                      onPressed: isCodeComplete ? _proceedToNewPassword : null,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Center(
                      child: AuthTextLink(
                        label: canResend
                            ? 'Resend 6-digit code'
                            : loading
                                ? 'Sending…'
                                : 'Resend code in ${_secondsLeft}s',
                        muted: !canResend,
                        onTap: canResend ? _resend : null,
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
