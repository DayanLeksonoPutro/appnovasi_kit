import 'package:flutter/material.dart';

import '../features/onboarding/onboarding_config.dart';
import '../routing/navigation_config.dart';
import 'app_font.dart';
import 'app_font_size.dart';
import 'content_config.dart';

class Neutrals {
  const Neutrals({
    required this.background,
    required this.surface,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
  });

  final Color background;
  final Color surface;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
}

const Neutrals lightNeutrals = Neutrals(
  background: Color(0xFFF4F4F5),
  surface: Color(0xFFFFFFFF),
  surfaceDim: Color(0xFFD4D4D8),
  surfaceBright: Color(0xFFFFFFFF),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF4F4F5),
  surfaceContainer: Color(0xFFEBEBED),
  surfaceContainerHigh: Color(0xFFE1E1E4),
  surfaceContainerHighest: Color(0xFFD7D7DB),
  onSurface: Color(0xFF000000),
  onSurfaceVariant: Color(0xFF52525B),
  outline: Color(0xFFB4B4BA),
  outlineVariant: Color(0xFFD7D7DB),
);

const Neutrals darkNeutrals = Neutrals(
  background: Color(0xFF0A0A0A),
  surface: Color(0xFF121212),
  surfaceDim: Color(0xFF0A0A0A),
  surfaceBright: Color(0xFF3F3F46),
  surfaceContainerLowest: Color(0xFF0A0A0A),
  surfaceContainerLow: Color(0xFF1A1A1A),
  surfaceContainer: Color(0xFF202020),
  surfaceContainerHigh: Color(0xFF282828),
  surfaceContainerHighest: Color(0xFF313131),
  onSurface: Color(0xFFFFFFFF),
  onSurfaceVariant: Color(0xFFA1A1AA),
  outline: Color(0xFF3F3F46),
  outlineVariant: Color(0xFF27272A),
);

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
    this.accentColor = defaultAccentColor,
    this.defaultThemeMode = ThemeMode.system,
    this.defaultFontSize = AppFontSize.normal,
    this.fontFamily,
    this.fonts = defaultFonts,
    this.success,
    this.warning,
    this.error,
    this.radiusSmall = 8,
    this.radiusMedium = 12,
    this.radiusLarge = 18,
    this.buttonHeight = 48,
    this.cardElevation = 2,
    this.appBarElevation = 0,
  });

  static const Color defaultAccentColor = Color(0xFF4F46E5);

  final Color accentColor;
  final ThemeMode defaultThemeMode;
  final AppFontSize defaultFontSize;
  final String? fontFamily;
  final List<AppFont> fonts;
  final Color? success;
  final Color? warning;
  final Color? error;
  final double radiusSmall;
  final double radiusMedium;
  final double radiusLarge;
  final double buttonHeight;
  final double cardElevation;
  final double appBarElevation;

  String get effectiveFontFamily => fontFamily ?? 'Poppins';

  ThemeData lightTheme({Color? accentColor, String? fontFamily}) => _buildTheme(
    Brightness.light,
    accentColor ?? this.accentColor,
    fontFamily ?? effectiveFontFamily,
  );

  ThemeData darkTheme({Color? accentColor, String? fontFamily}) => _buildTheme(
    Brightness.dark,
    accentColor ?? this.accentColor,
    fontFamily ?? effectiveFontFamily,
  );

  ThemeData _buildTheme(Brightness brightness, Color accent, String family) {
    final neutral = brightness == Brightness.light
        ? lightNeutrals
        : darkNeutrals;
    final accents = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
    );
    final scheme = accents.copyWith(
      primary: accent,
      onPrimary: _readableOn(accent),
      surface: neutral.surface,
      onSurface: neutral.onSurface,
      onSurfaceVariant: neutral.onSurfaceVariant,
      surfaceDim: neutral.surfaceDim,
      surfaceBright: neutral.surfaceBright,
      surfaceContainerLowest: neutral.surfaceContainerLowest,
      surfaceContainerLow: neutral.surfaceContainerLow,
      surfaceContainer: neutral.surfaceContainer,
      surfaceContainerHigh: neutral.surfaceContainerHigh,
      surfaceContainerHighest: neutral.surfaceContainerHighest,
      surfaceTint: Colors.transparent,
      outline: neutral.outline,
      outlineVariant: neutral.outlineVariant,
      error: error ?? accents.error,
      onError: _readableOn(error ?? accents.error),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: neutral.background,
      fontFamily: family,
    );
  }

  static Color _readableOn(Color color) =>
      color.computeLuminance() > 0.5 ? const Color(0xFF0B1120) : Colors.white;
}

class AppConfig {
  AppConfig({
    String appName = '',
    String packageId = '',
    String? description,
    String? logoAsset,
    Color accentColor = ThemeConfig.defaultAccentColor,
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
  }) : brand =
           brand ??
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
       theme =
           theme ??
           ThemeConfig(
             accentColor: accentColor,
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

  Color get accentColor => theme.accentColor;

  ThemeMode get defaultThemeMode => theme.defaultThemeMode;

  AppFontSize get defaultFontSize => theme.defaultFontSize;

  String? get fontFamily => theme.fontFamily;

  List<AppFont> get fonts => theme.fonts;

  String get effectiveFontFamily => theme.effectiveFontFamily;

  bool get hasOnboarding => onboarding != null && onboarding!.pages.isNotEmpty;

  bool get hasNavigation => navigation != null && navigation!.tabs.isNotEmpty;

  ThemeData lightTheme({Color? accentColor, String? fontFamily}) =>
      theme.lightTheme(accentColor: accentColor, fontFamily: fontFamily);

  ThemeData darkTheme({Color? accentColor, String? fontFamily}) =>
      theme.darkTheme(accentColor: accentColor, fontFamily: fontFamily);

  ResolvedContent contentFor(Locale locale) => content.contentFor(locale);

  String welcomeTitleFor(Locale locale) => content.welcomeTitleFor(locale);

  String heroTitleFor(Locale locale) => content.heroTitleFor(locale);

  String heroSubtitleFor(Locale locale) => content.heroSubtitleFor(locale);

  String appDescriptionFor(Locale locale) => content.appDescriptionFor(locale);
}
