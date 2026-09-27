import 'package:flutter/material.dart';

import '../core/app_config.dart';
import 'storage_service.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._storage, AppConfig config)
    : _mode =
          _fromString(_storage.read<String>(_key)) ?? config.defaultThemeMode;

  static const String _key = 'theme_mode';

  final StorageService _storage;
  ThemeMode _mode;

  ThemeMode get themeMode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _storage.write(_key, mode.name);
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
}
