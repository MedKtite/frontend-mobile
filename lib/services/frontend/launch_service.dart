import 'package:shared_preferences/shared_preferences.dart';

/// Owns local-only startup flags.
class LaunchService {
  LaunchService._();

  static const _hasLaunchedKey = 'has_launched';

  /// Returns true only once for this installation and records the launch
  /// before the UI starts, so every later start can show the splash screen.
  static Future<bool> consumeFirstLaunch() async {
    final preferences = await SharedPreferences.getInstance();
    final isFirstLaunch = !(preferences.getBool(_hasLaunchedKey) ?? false);
    if (isFirstLaunch) {
      await preferences.setBool(_hasLaunchedKey, true);
    }
    return isFirstLaunch;
  }
}
