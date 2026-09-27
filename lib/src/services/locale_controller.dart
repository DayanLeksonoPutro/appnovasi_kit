import 'package:flutter/material.dart';

import '../core/app_config.dart';
import 'storage_service.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._storage, AppConfig config)
    : _locale = _resolve(_storage.read<String>(_key), config);

  static const String _key = 'locale';

  final StorageService _storage;
  Locale _locale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    _storage.write(_key, locale.languageCode);
    notifyListeners();
  }

  static Locale _resolve(String? code, AppConfig config) {
    if (code != null) {
      for (final locale in config.supportedLocales) {
        if (locale.languageCode == code) return locale;
      }
    }
    return config.defaultLocale;
  }
}
