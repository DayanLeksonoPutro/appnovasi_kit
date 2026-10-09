// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String shareMessage(String appName) {
    return 'Cek aplikasi $appName!';
  }

  @override
  String get share => 'Bagikan';

  @override
  String get rate => 'Beri Rating';

  @override
  String get rateTitle => 'Beri rating aplikasi ini';

  @override
  String get rateMessage =>
      'Jika Anda menikmati aplikasi ini, luangkan waktu untuk memberi rating. Terima kasih atas dukungannya!';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get onboardingNext => 'Berikutnya';

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingGetStarted => 'Mulai';

  @override
  String get aboutTitle => 'Tentang';

  @override
  String get fontSize => 'Ukuran font';

  @override
  String get fontSmall => 'Kecil';

  @override
  String get fontNormal => 'Standar';

  @override
  String get fontLarge => 'Besar';

  @override
  String get fontFamily => 'Jenis font';

  @override
  String get darkMode => 'Mode gelap';

  @override
  String get moreApps => 'Aplikasi lainnya';

  @override
  String get website => 'Situs web';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get termsOfService => 'Ketentuan Layanan';
}
