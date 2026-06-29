
class AuthValidators {
  AuthValidators._();

  static const _emailRegex = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(_emailRegex).hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'At least 8 characters';
    return null;
  }

  static String? displayName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    if (v.trim().length > 80) return 'Name is too long';
    return null;
  }
}
