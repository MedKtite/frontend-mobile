import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/secure_storage.dart';

/// Persists the app language independently of the system locale.
class LanguageController extends StateNotifier<Locale> {
  LanguageController() : super(const Locale('en')) {
    _restore();
  }

  static const _storageKey = 'app_language_code';

  Future<void> _restore() async {
    try {
      final saved = await SecureStorage.read(_storageKey);
      if (saved != null && ['en', 'fr', 'es', 'ar'].contains(saved)) {
        state = Locale(saved);
      }
    } catch (_) {
      // Keep default ('en')
    }
  }

  Future<void> setLanguage(String code) async {
    state = Locale(code);
    try {
      await SecureStorage.write(_storageKey, code);
    } catch (_) {
      // The visible preference still applies for this session
    }
  }
}

final languageProvider = StateNotifierProvider<LanguageController, Locale>(
  (ref) => LanguageController(),
);
