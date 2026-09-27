import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_config.dart';
import '../routing/navigation_config.dart';
import 'app_color_theme.dart';
import 'app_font.dart';
import 'app_font_size.dart';

class AppConfig {
  const AppConfig({
    required this.appName,
    required this.packageId,
    this.description,
    this.logoAsset,
    this.seedColor = const Color(0xFF4F46E5),
    this.colorThemes = defaultColorThemes,
    this.defaultThemeMode = ThemeMode.system,
    this.defaultFontSize = AppFontSize.normal,
    this.fontFamily,
    this.fonts = defaultFonts,
    this.supportedLocales = const [Locale('en')],
    this.defaultLocale = const Locale('en'),
    this.bannerUnitId,
    this.interstitialUnitId,
    this.appOpenUnitId,
    this.productIds = const [],
    this.playStoreUrl,
    this.appStoreUrl,
    this.moreAppsUrl,
    this.websiteUrl,
    this.privacyPolicyUrl,
    this.termsUrl,
    this.onboarding,
    this.navigation,
  });

  final String appName;
  final String packageId;
  final String? description;
  final String? logoAsset;
  final Color seedColor;
  final List<AppColorTheme> colorThemes;
  final ThemeMode defaultThemeMode;
  final AppFontSize defaultFontSize;
  final String? fontFamily;
  final List<AppFont> fonts;
  final List<Locale> supportedLocales;
  final Locale defaultLocale;
  final String? bannerUnitId;
  final String? interstitialUnitId;
  final String? appOpenUnitId;
  final List<String> productIds;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final String? moreAppsUrl;
  final String? websiteUrl;
  final String? privacyPolicyUrl;
  final String? termsUrl;
  final OnboardingConfig? onboarding;
  final BottomNavConfig? navigation;

  String get effectiveFontFamily => fontFamily ?? 'Poppins';

  bool get hasOnboarding => onboarding != null && onboarding!.pages.isNotEmpty;

  bool get hasNavigation => navigation != null && navigation!.tabs.isNotEmpty;

  bool get hasAds =>
      bannerUnitId != null ||
      interstitialUnitId != null ||
      appOpenUnitId != null;

  ThemeData lightTheme({Color? seedColor, String? fontFamily}) => _buildTheme(
    Brightness.light,
    seedColor ?? this.seedColor,
    fontFamily ?? effectiveFontFamily,
  );

  ThemeData darkTheme({Color? seedColor, String? fontFamily}) => _buildTheme(
    Brightness.dark,
    seedColor ?? this.seedColor,
    fontFamily ?? effectiveFontFamily,
  );

  ThemeData _buildTheme(Brightness brightness, Color color, String family) {
    final scheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: family,
    );
  }
}
