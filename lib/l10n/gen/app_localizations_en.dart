// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String shareMessage(String appName) {
    return 'Check out $appName!';
  }

  @override
  String get share => 'Share';

  @override
  String get rate => 'Rate';

  @override
  String get rateTitle => 'Rate this app';

  @override
  String get rateMessage =>
      'If you enjoy using this app, please take a moment to rate it. Thank you for your support!';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageLabel => 'Language';
}
