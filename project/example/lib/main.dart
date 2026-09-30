import 'package:appnovasi_kit/appnovasi_kit.dart';
import 'package:flutter/material.dart';

final appConfig = AppConfig(
  brand: BrandConfig(
    appName: 'Appnovasi Demo',
    packageId: 'com.appnovasi.example',
    description:
        'A config-only Flutter boilerplate showcasing theme, locale, IAP, onboarding, and navigation.',
    slogan: 'Build faster. Launch smarter.',
    supportEmail: 'hello@appnovasi.example',
    websiteUrl: 'https://example.com',
    privacyPolicyUrl: 'https://example.com/privacy',
    termsUrl: 'https://example.com/terms',
    playStoreUrl:
        'https://play.google.com/store/apps/details?id=com.appnovasi.example',
    appStoreUrl: 'https://apps.apple.com/app/id000000000',
    moreAppsUrl: 'https://play.google.com/store/apps/developer?id=Appnovasi',
  ),
  theme: ThemeConfig(
    seedColor: const Color(0xFF4F46E5),
    defaultThemeMode: ThemeMode.system,
    defaultFontSize: AppFontSize.normal,
    fontFamily: 'Poppins',
    primary: const Color(0xFF4F46E5),
    secondary: const Color(0xFF0EA5E9),
    background: const Color(0xFFF8FAFC),
    surface: Colors.white,
    surfaceVariant: const Color(0xFFE2E8F0),
    success: const Color(0xFF16A34A),
    warning: const Color(0xFFF59E0B),
    error: const Color(0xFFDC2626),
    textPrimary: const Color(0xFF0F172A),
    textSecondary: const Color(0xFF475569),
    radiusMedium: 14,
    buttonHeight: 48,
  ),
  content: ContentConfig(
    welcomeTitle: const LocalizedText({
      'en': 'Welcome to Appnovasi',
      'id': 'Selamat datang di Appnovasi',
    }),
    heroTitle: const LocalizedText({
      'en': 'Build a better app in less time',
      'id': 'Bangun aplikasi yang lebih baik dengan lebih cepat',
    }),
    heroSubtitle: const LocalizedText({
      'en': 'Theme, localization, onboarding, and settings are already ready.',
      'id': 'Tema, lokalisasi, onboarding, dan pengaturan sudah siap.',
    }),
    appDescription: const LocalizedText({
      'en':
          'A config-only Flutter boilerplate designed to accelerate product development.',
      'id':
          'Boilerplate Flutter config-only yang dirancang untuk mempercepat pengembangan produk.',
    }),
    supportEmail: 'hello@appnovasi.example',
    supportPhone: '+628123456789',
  ),
  supportedLocales: const [Locale('en'), Locale('id')],
  defaultLocale: const Locale('en'),
  productIds: const ['remove_ads'],
  onboarding: OnboardingConfig(
    pages: [
      OnboardingPage(
        title: 'Welcome',
        description: 'Explore the main features of the app.',
        icon: Icons.waving_hand,
      ),
      OnboardingPage(
        title: 'Make it yours',
        description: 'Switch theme and language anytime.',
        icon: Icons.palette_outlined,
      ),
    ],
  ),
  navigation: BottomNavConfig(
    tabs: [
      NavTab(
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        path: '/home',
      ),
      NavTab(
        label: 'About',
        icon: Icons.info_outline,
        selectedIcon: Icons.info,
        path: '/about',
      ),
      NavTab(
        label: 'Settings',
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        path: '/settings',
      ),
    ],
  ),
);

Future<void> main() async {
  await AppKit.initialize(appConfig);
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppKitApp(
      config: appConfig,
      routes: {
        '/home': (context) => const HomePage(),
        '/about': (context) => const AboutScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const AppTitle(),
        actions: const [ShareIconButton(), RateIconButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.shareMessage(appConfig.appName)),
        ],
      ),
    );
  }
}
