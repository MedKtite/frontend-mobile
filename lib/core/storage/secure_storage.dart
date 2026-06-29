import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around flutter_secure_storage. Not used for the auth refresh
/// token (that's in cookies) — kept here for future non-cookie secrets like
/// a saved device push token or biometric prefs.
class SecureStorage {
  SecureStorage._();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> read(String key) => _storage.read(key: key);

  static Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  static Future<void> delete(String key) => _storage.delete(key: key);
}
