import 'package:flutter/material.dart';

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.packageId,
    this.seedColor = const Color(0xFF4F46E5),
    this.defaultThemeMode = ThemeMode.system,
    this.fontFamily,
    this.supportedLocales = const [Locale('en')],
    this.defaultLocale = const Locale('en'),
    this.bannerUnitId,
    this.interstitialUnitId,
    this.appOpenUnitId,
    this.productIds = const [],
    this.playStoreUrl,
    this.appStoreUrl,
    this.privacyPolicyUrl,
    this.termsUrl,
  });

  final String appName;
  final String packageId;
  final Color seedColor;
  final ThemeMode defaultThemeMode;
  final String? fontFamily;
  final List<Locale> supportedLocales;
  final Locale defaultLocale;
  final String? bannerUnitId;
  final String? interstitialUnitId;
  final String? appOpenUnitId;
  final List<String> productIds;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final String? privacyPolicyUrl;
  final String? termsUrl;

  String get effectiveFontFamily => fontFamily ?? 'Poppins';

  bool get hasAds =>
      bannerUnitId != null ||
      interstitialUnitId != null ||
      appOpenUnitId != null;

  ThemeData lightTheme() => _buildTheme(Brightness.light);

  ThemeData darkTheme() => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: effectiveFontFamily,
    );
  }
}
