import 'package:appnovasi_kit/appnovasi_kit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const appConfig = AppConfig(
  appName: 'Appnovasi Demo',
  packageId: 'com.appnovasi.example',
  seedColor: Color(0xFF4F46E5),
  supportedLocales: [Locale('en'), Locale('id')],
  defaultLocale: Locale('en'),
  bannerUnitId: 'ca-app-pub-3940256099942544/6300978111',
  interstitialUnitId: 'ca-app-pub-3940256099942544/1033173712',
  productIds: ['remove_ads'],
  playStoreUrl:
      'https://play.google.com/store/apps/details?id=com.appnovasi.example',
  appStoreUrl: 'https://apps.apple.com/app/id000000000',
  privacyPolicyUrl: 'https://example.com/privacy',
  termsUrl: 'https://example.com/terms',
);

Future<void> main() async {
  await AppKit.initialize(appConfig);
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppKitApp(config: appConfig, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.watch<ThemeController>();
    final locale = context.watch<LocaleController>();

    return Scaffold(
      appBar: AppBar(title: Text(appConfig.appName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const AdBanner(),
          const SizedBox(height: 16),
          Text(l10n.shareMessage(appConfig.appName)),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [ShareButton(), RateButton()],
          ),
          const Divider(height: 48),
          SwitchListTile(
            title: Text(l10n.themeDark),
            value: theme.isDark,
            onChanged: (_) => context.read<ThemeController>().toggle(),
          ),
          ListTile(
            title: Text(l10n.languageLabel),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('EN')),
                ButtonSegment(value: 'id', label: Text('ID')),
              ],
              selected: {locale.locale.languageCode},
              onSelectionChanged: (selection) => context
                  .read<LocaleController>()
                  .setLocale(Locale(selection.first)),
            ),
          ),
        ],
      ),
    );
  }
}
