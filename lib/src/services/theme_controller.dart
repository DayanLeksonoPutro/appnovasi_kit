import 'package:flutter/material.dart';

import '../core/app_config.dart';
import '../core/app_font.dart';
import '../core/app_font_size.dart';
import 'storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._storage, this._config)
    : _mode =
          _fromString(_storage.read<String>(_modeKey)) ??
          _config.defaultThemeMode,
      _fontSize =
          _fromFontSize(_storage.read<String>(_fontSizeKey)) ??
          _config.defaultFontSize,
      _font = _resolveFont(_storage.read<String>(_fontKey), _config);

  static const String _modeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _fontKey = 'font_family';

  final StorageService _storage;
  final AppConfig _config;

  ThemeMode _mode;
  AppFontSize _fontSize;
  AppFont _font;

  ThemeMode get themeMode => _mode;

  Color get accentColor => _config.accentColor;

  AppFontSize get fontSize => _fontSize;

  double get textScale => _fontSize.scale;

  AppFont get font => _font;

  String get fontFamily => _font.fontFamily ?? _config.effectiveFontFamily;

  bool get isDark => _mode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _storage.write(_modeKey, mode.name);
    notifyListeners();
  }

  void setFontSize(AppFontSize fontSize) {
    if (_fontSize == fontSize) return;
    _fontSize = fontSize;
    _storage.write(_fontSizeKey, fontSize.name);
    notifyListeners();
  }

  void setFont(AppFont font) {
    if (_font.name == font.name) return;
    _font = font;
    _storage.write(_fontKey, font.name);
    notifyListeners();
  }

  void toggle() {
    setThemeMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  static ThemeMode? _fromString(String? value) {
    if (value == null) return null;
    for (final mode in ThemeMode.values) {
      if (mode.name == value) return mode;
    }
    return null;
  }

  static AppFontSize? _fromFontSize(String? value) {
    if (value == null) return null;
    for (final size in AppFontSize.values) {
      if (size.name == value) return size;
    }
    return null;
  }

  static AppFont _resolveFont(String? name, AppConfig config) {
    final fonts = config.fonts.isEmpty ? defaultFonts : config.fonts;
    for (final font in fonts) {
      if (font.name == name) return font;
    }
    return fonts.first;
  }
}
