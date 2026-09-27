import 'package:appnovasi_kit/appnovasi_kit.dart';
import 'package:flutter/material.dart';

const appConfig = AppConfig(
  appName: 'Appnovasi Demo',
  packageId: 'com.appnovasi.example',
  description:
      'A config-only Flutter boilerplate showcasing theme, locale, ads, IAP, '
      'onboarding and navigation.',
  seedColor: Color(0xFF4F46E5),
  defaultFontSize: AppFontSize.normal,
  supportedLocales: [Locale('en'), Locale('id')],
  defaultLocale: Locale('en'),
  bannerUnitId: 'ca-app-pub-3940256099942544/6300978111',
  interstitialUnitId: 'ca-app-pub-3940256099942544/1033173712',
  productIds: ['remove_ads'],
  playStoreUrl:
      'https://play.google.com/store/apps/details?id=com.appnovasi.example',
  appStoreUrl: 'https://apps.apple.com/app/id000000000',
  moreAppsUrl: 'https://play.google.com/store/apps/developer?id=Appnovasi',
  websiteUrl: 'https://example.com',
  privacyPolicyUrl: 'https://example.com/privacy',
  termsUrl: 'https://example.com/terms',
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
          const AdBanner(),
          const SizedBox(height: 16),
          Text(l10n.shareMessage(appConfig.appName)),
        ],
      ),
    );
  }
}
