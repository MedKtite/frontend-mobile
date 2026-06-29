import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens/colors.dart';
import '../core/storage/secure_storage.dart';

/// Reader typography preferences (the "Aa" sheet — Figma 297:2). Persisted so a
/// reader's font/size/spacing/theme survive across books and launches.

enum ReaderFont { serif, sans }

enum ReaderSize { small, medium, large, xlarge }

enum ReaderSpacing { tight, normal, loose }

enum ReaderThemeMode { light, sepia, dark, black }

/// The reading-surface palette per [ReaderThemeMode] — independent of the app's
/// own light/dark theme. Light/Dark reuse the app tokens; Black is Dark on pure
/// black; only Sepia is bespoke (paper warmth, from the Figma swatch).
@immutable
class ReaderPalette {
  const ReaderPalette({
    required this.bg,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.border,
    required this.surface2,
  });

  final Color bg, text, text2, text3, accent, border, surface2;

  static const light = ReaderPalette(
    bg: AppColors.lightBg,
    text: AppColors.lightText,
    text2: AppColors.lightText2,
    text3: AppColors.lightText3,
    accent: AppColors.lightAccent,
    border: AppColors.lightBorder,
    surface2: AppColors.lightSurface2,
  );

  static const sepia = ReaderPalette(
    bg: Color(0xFFE8D8B8),
    text: Color(0xFF3D2F20),
    text2: Color(0x993D2F20),
    text3: Color(0x593D2F20),
    accent: Color(0xFF9A7B3A),
    border: Color(0x143D2F20),
    surface2: Color(0xFFDCC9A4),
  );

  static const dark = ReaderPalette(
    bg: AppColors.darkBg,
    text: AppColors.darkText,
    text2: AppColors.darkText2,
    text3: AppColors.darkText3,
    accent: AppColors.darkAccent,
    border: AppColors.darkBorder,
    surface2: AppColors.darkSurface2,
  );

  static const black = ReaderPalette(
    bg: Color(0xFF000000),
    text: AppColors.darkText,
    text2: AppColors.darkText2,
    text3: AppColors.darkText3,
    accent: AppColors.darkAccent,
    border: AppColors.darkBorder,
    surface2: Color(0xFF141416),
  );

  static ReaderPalette of(ReaderThemeMode m) => switch (m) {
        ReaderThemeMode.light => light,
        ReaderThemeMode.sepia => sepia,
        ReaderThemeMode.dark => dark,
        ReaderThemeMode.black => black,
      };
}

@immutable
class ReadingSettings {
  const ReadingSettings({
    this.font = ReaderFont.serif,
    this.size = ReaderSize.medium,
    this.spacing = ReaderSpacing.normal,
    this.theme = ReaderThemeMode.light,
  });

  final ReaderFont font;
  final ReaderSize size;
  final ReaderSpacing spacing;
  final ReaderThemeMode theme;

  static const defaults = ReadingSettings();

  double get fontSize => switch (size) {
        ReaderSize.small => 16,
        ReaderSize.medium => 18,
        ReaderSize.large => 21,
        ReaderSize.xlarge => 24,
      };

  double get lineHeight => switch (spacing) {
        ReaderSpacing.tight => 1.4,
        ReaderSpacing.normal => 1.65,
        ReaderSpacing.loose => 1.95,
      };

  ReaderPalette get palette => ReaderPalette.of(theme);

  /// The reflowable EPUB body style: family + size + line-height + ink color.
  TextStyle bodyTextStyle() {
    final base = TextStyle(
      fontSize: fontSize,
      height: lineHeight,
      color: palette.text,
    );
    return font == ReaderFont.serif
        ? GoogleFonts.sourceSerif4(textStyle: base)
        : GoogleFonts.inter(textStyle: base);
  }

  ReadingSettings copyWith({
    ReaderFont? font,
    ReaderSize? size,
    ReaderSpacing? spacing,
    ReaderThemeMode? theme,
  }) =>
      ReadingSettings(
        font: font ?? this.font,
        size: size ?? this.size,
        spacing: spacing ?? this.spacing,
        theme: theme ?? this.theme,
      );

  Map<String, dynamic> toJson() => {
        'font': font.name,
        'size': size.name,
        'spacing': spacing.name,
        'theme': theme.name,
      };

  factory ReadingSettings.fromJson(Map<String, dynamic> j) => ReadingSettings(
        font: _byName(ReaderFont.values, j['font'], ReaderFont.serif),
        size: _byName(ReaderSize.values, j['size'], ReaderSize.medium),
        spacing: _byName(ReaderSpacing.values, j['spacing'], ReaderSpacing.normal),
        theme: _byName(ReaderThemeMode.values, j['theme'], ReaderThemeMode.light),
      );

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }
}

class ReadingSettingsController extends StateNotifier<ReadingSettings> {
  ReadingSettingsController() : super(ReadingSettings.defaults) {
    _load();
  }

  static const _key = 'reading_settings';

  Future<void> _load() async {
    final raw = await SecureStorage.read(_key);
    if (raw == null) return;
    try {
      state = ReadingSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      /* corrupt value — keep defaults */
    }
  }

  void _persist() => SecureStorage.write(_key, jsonEncode(state.toJson()));

  void setFont(ReaderFont v) {
    state = state.copyWith(font: v);
    _persist();
  }

  void setSize(ReaderSize v) {
    state = state.copyWith(size: v);
    _persist();
  }

  void setSpacing(ReaderSpacing v) {
    state = state.copyWith(spacing: v);
    _persist();
  }

  void setTheme(ReaderThemeMode v) {
    state = state.copyWith(theme: v);
    _persist();
  }
}

final readingSettingsProvider =
    StateNotifierProvider<ReadingSettingsController, ReadingSettings>(
        (ref) => ReadingSettingsController());
