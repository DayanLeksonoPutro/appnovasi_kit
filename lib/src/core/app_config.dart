import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_config.dart';
import '../routing/navigation_config.dart';
import 'app_color_theme.dart';
import 'app_font.dart';
import 'app_font_size.dart';
import 'content_config.dart';

class BrandConfig {
  const BrandConfig({
    this.appName = '',
    this.packageId = '',
    this.description,
    this.logoAsset,
    this.slogan,
    this.iconAsset,
    this.supportEmail,
    this.websiteUrl,
    this.privacyPolicyUrl,
    this.termsUrl,
    this.playStoreUrl,
    this.appStoreUrl,
    this.moreAppsUrl,
    this.socialInstagram,
    this.socialX,
    this.socialLinkedIn,
  });

  final String appName;
  final String packageId;
  final String? description;
  final String? logoAsset;
  final String? slogan;
  final String? iconAsset;
  final String? supportEmail;
  final String? websiteUrl;
  final String? privacyPolicyUrl;
  final String? termsUrl;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final String? moreAppsUrl;
  final String? socialInstagram;
  final String? socialX;
  final String? socialLinkedIn;
}

class ThemeConfig {
  const ThemeConfig({
    this.seedColor = const Color(0xFF4F46E5),
    this.colorThemes = defaultColorThemes,
    this.defaultThemeMode = ThemeMode.system,
    this.defaultFontSize = AppFontSize.normal,
    this.fontFamily,
    this.fonts = defaultFonts,
    this.primary,
    this.primaryContainer,
    this.secondary,
    this.background,
    this.surface,
    this.surfaceVariant,
    this.success,
    this.warning,
    this.error,
    this.textPrimary,
    this.textSecondary,
    this.radiusSmall = 8,
    this.radiusMedium = 12,
    this.radiusLarge = 18,
    this.buttonHeight = 48,
    this.cardElevation = 2,
    this.appBarElevation = 0,
  });

  final Color seedColor;
  final List<AppColorTheme> colorThemes;
  final ThemeMode defaultThemeMode;
  final AppFontSize defaultFontSize;
  final String? fontFamily;
  final List<AppFont> fonts;
  final Color? primary;
  final Color? primaryContainer;
  final Color? secondary;
  final Color? background;
  final Color? surface;
  final Color? surfaceVariant;
  final Color? success;
  final Color? warning;
  final Color? error;
  final Color? textPrimary;
  final Color? textSecondary;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double buttonHeight;
  final double cardElevation;
  final double appBarElevation;

  Color get effectivePrimary => primary ?? seedColor;

  Color get effectiveBackground => background ?? const Color(0xFFF8FAFC);

  Color get effectiveSurface => surface ?? Colors.white;

  Color get effectiveTextPrimary => textPrimary ?? const Color(0xFF0F172A);

  Color get effectiveTextSecondary => textSecondary ?? const Color(0xFF475569);

  String get effectiveFontFamily => fontFamily ?? 'Poppins';

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

class AppConfig {
  AppConfig({
    String appName = '',
    String packageId = '',
    String? description,
    String? logoAsset,
    Color seedColor = const Color(0xFF4F46E5),
    List<AppColorTheme> colorThemes = defaultColorThemes,
    ThemeMode defaultThemeMode = ThemeMode.system,
    AppFontSize defaultFontSize = AppFontSize.normal,
    String? fontFamily,
    List<AppFont> fonts = defaultFonts,
    this.supportedLocales = const [Locale('en')],
    this.defaultLocale = const Locale('en'),
    this.productIds = const [],
    String? playStoreUrl,
    String? appStoreUrl,
    String? moreAppsUrl,
    String? websiteUrl,
    String? privacyPolicyUrl,
    String? termsUrl,
    this.onboarding,
    this.navigation,
    ContentConfig? content,
    BrandConfig? brand,
    ThemeConfig? theme,
  }) : brand = brand ??
            BrandConfig(
              appName: appName,
              packageId: packageId,
              description: description,
              logoAsset: logoAsset,
              websiteUrl: websiteUrl,
              privacyPolicyUrl: privacyPolicyUrl,
              termsUrl: termsUrl,
              playStoreUrl: playStoreUrl,
              appStoreUrl: appStoreUrl,
              moreAppsUrl: moreAppsUrl,
            ),
       theme = theme ??
            ThemeConfig(
              seedColor: seedColor,
              colorThemes: colorThemes,
              defaultThemeMode: defaultThemeMode,
              defaultFontSize: defaultFontSize,
              fontFamily: fontFamily,
              fonts: fonts,
            ),
       content = content ?? const ContentConfig();

  final BrandConfig brand;
  final ThemeConfig theme;
  final ContentConfig content;
  final List<Locale> supportedLocales;
  final Locale defaultLocale;
  final List<String> productIds;
  final OnboardingConfig? onboarding;
  final BottomNavConfig? navigation;

  String get appName => brand.appName;

  String get packageId => brand.packageId;

  String? get description => brand.description;

  String? get logoAsset => brand.logoAsset;

  String? get websiteUrl => brand.websiteUrl;

  String? get privacyPolicyUrl => brand.privacyPolicyUrl;

  String? get termsUrl => brand.termsUrl;

  String? get playStoreUrl => brand.playStoreUrl;

  String? get appStoreUrl => brand.appStoreUrl;

  String? get moreAppsUrl => brand.moreAppsUrl;

  Color get seedColor => theme.seedColor;

  List<AppColorTheme> get colorThemes => theme.colorThemes;

  ThemeMode get defaultThemeMode => theme.defaultThemeMode;

  AppFontSize get defaultFontSize => theme.defaultFontSize;

  String? get fontFamily => theme.fontFamily;

  List<AppFont> get fonts => theme.fonts;

  String get effectiveFontFamily => theme.effectiveFontFamily;

  bool get hasOnboarding => onboarding != null && onboarding!.pages.isNotEmpty;

  bool get hasNavigation => navigation != null && navigation!.tabs.isNotEmpty;

  ThemeData lightTheme({Color? seedColor, String? fontFamily}) => theme.lightTheme(
    seedColor: seedColor,
    fontFamily: fontFamily,
  );

  ThemeData darkTheme({Color? seedColor, String? fontFamily}) => theme.darkTheme(
    seedColor: seedColor,
    fontFamily: fontFamily,
  );

  ResolvedContent contentFor(Locale locale) => content.contentFor(locale);

  String welcomeTitleFor(Locale locale) => content.welcomeTitleFor(locale);

  String heroTitleFor(Locale locale) => content.heroTitleFor(locale);

  String heroSubtitleFor(Locale locale) => content.heroSubtitleFor(locale);

  String appDescriptionFor(Locale locale) => content.appDescriptionFor(locale);
}
