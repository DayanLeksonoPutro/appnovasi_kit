import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../core/app_config.dart';
import '../../services/link_service.dart';
import '../../services/rate_service.dart';
import '../../services/share_service.dart';
import '../../widgets/app_title.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.extra = const []});

  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = context.watch<AppConfig>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          _Header(config: config),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(l10n.share),
            onTap: () => context.read<ShareService>().shareApp(),
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(l10n.rate),
            onTap: () => context.read<RateService>().openStore(),
          ),
          if (config.moreAppsUrl != null)
            ListTile(
              leading: const Icon(Icons.apps_outlined),
              title: Text(l10n.moreApps),
              onTap: () => context.read<LinkService>().open(config.moreAppsUrl),
            ),
          if (config.websiteUrl != null)
            ListTile(
              leading: const Icon(Icons.public_outlined),
              title: Text(l10n.website),
              onTap: () => context.read<LinkService>().open(config.websiteUrl),
            ),
          if (config.privacyPolicyUrl != null)
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.privacyPolicy),
              onTap: () =>
                  context.read<LinkService>().open(config.privacyPolicyUrl),
            ),
          if (config.termsUrl != null)
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.termsOfService),
              onTap: () => context.read<LinkService>().open(config.termsUrl),
            ),
          if (extra.isNotEmpty) ...[const Divider(), ...extra],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logo = config.logoAsset;

    return Column(
      children: [
        if (logo != null)
          Image.asset(logo, height: 96, fit: BoxFit.contain)
        else
          CircleAvatar(
            radius: 48,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              config.appName.isEmpty ? '?' : config.appName[0].toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        const SizedBox(height: 8),
        const AppVersionText(),
        const SizedBox(height: 16),
        Text(
          config.appName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (config.description != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              config.description!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
