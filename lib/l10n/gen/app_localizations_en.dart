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

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get aboutTitle => 'About';

  @override
  String get fontSize => 'Font size';

  @override
  String get fontSmall => 'Small';

  @override
  String get fontNormal => 'Default';

  @override
  String get fontLarge => 'Large';

  @override
  String get fontFamily => 'Font';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get moreApps => 'More apps';

  @override
  String get website => 'Website';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';
}
