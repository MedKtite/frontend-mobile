import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/secure_storage.dart';

/// Persists the app-wide appearance preference independently of reader themes.
class ThemeController extends StateNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system) {
    _restore();
  }

  static const _storageKey = 'app_theme_mode';

  Future<void> _restore() async {
    try {
      final saved = await SecureStorage.read(_storageKey);
      state = ThemeMode.values.where((mode) => mode.name == saved).firstOrNull ??
          ThemeMode.system;
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      await SecureStorage.write(_storageKey, mode.name);
    } catch (_) {
      // The visible preference still applies for this session if persistence
      // is unavailable on the current platform.
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeController, ThemeMode>(
  (ref) => ThemeController(),
);
