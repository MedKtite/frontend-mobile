/// Converts backend/authentication failures into calm, user-facing copy.
class AuthErrorMessages {
  AuthErrorMessages._();

  static const invalidCredentials =
      'Those sign-in details don’t look right. Check them and try again.';
  static const accountAlreadyExists =
      'An account with this email may already exist. Try signing in instead.';
  static const recoveryUnavailable =
      'We couldn’t send the recovery link right now. Please try again shortly.';
  static const resetUnavailable =
      'We couldn’t update your password. The link may have expired.';
  static const generic = 'Something went wrong. Please try again in a moment.';

  static String from(String? raw, {required AuthErrorContext context}) {
    final message = raw?.toLowerCase() ?? '';
    if (message.contains('incorrect email or password') ||
        message.contains('invalid credentials') ||
        message.contains('bad credentials') ||
        message.contains('unauthorized')) {
      return invalidCredentials;
    }
    if (message.contains('already exists') ||
        message.contains('already registered') ||
        message.contains('duplicate email')) {
      return accountAlreadyExists;
    }
    return switch (context) {
      AuthErrorContext.recovery => recoveryUnavailable,
      AuthErrorContext.resetPassword => resetUnavailable,
      AuthErrorContext.signIn || AuthErrorContext.register => generic,
    };
  }
}

enum AuthErrorContext { signIn, register, recovery, resetPassword }
