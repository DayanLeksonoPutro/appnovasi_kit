import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../../core/app_config.dart';
import '../../core/app_font.dart';
import '../../core/app_font_size.dart';
import '../../services/locale_controller.dart';
import '../../services/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, this.extra = const []});

  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = context.watch<AppConfig>();
    final theme = context.watch<ThemeController>();
    final locale = context.watch<LocaleController>();
    final locales = config.supportedLocales;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          if (locales.length > 1)
            _Row<Locale>(
              icon: Icons.language_outlined,
              title: l10n.languageLabel,
              value: locales.contains(locale.locale)
                  ? locale.locale
                  : config.defaultLocale,
              items: [
                for (final item in locales)
                  DropdownMenuItem(
                    value: item,
                    child: Text(_localeLabel(item)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<LocaleController>().setLocale(value);
                }
              },
            ),
          _Row<ThemeMode>(
            icon: Icons.brightness_6_outlined,
            title: l10n.themeLabel,
            value: theme.themeMode,
            items: [
              for (final mode in ThemeMode.values)
                DropdownMenuItem(
                  value: mode,
                  child: Text(_themeLabel(l10n, mode)),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeController>().setThemeMode(value);
              }
            },
          ),
          _Row<AppFontSize>(
            icon: Icons.format_size_outlined,
            title: l10n.fontSize,
            value: theme.fontSize,
            items: [
              for (final size in AppFontSize.values)
                DropdownMenuItem(
                  value: size,
                  child: Text(_fontSizeLabel(l10n, size)),
                ),
            ],
            onChanged: (value) {
              if (value != null) {
                context.read<ThemeController>().setFontSize(value);
              }
            },
          ),
          if (config.fonts.isNotEmpty)
            _Row<AppFont>(
              icon: Icons.text_fields_outlined,
              title: l10n.fontFamily,
              value: theme.font,
              items: [
                for (final font in config.fonts)
                  DropdownMenuItem(value: font, child: Text(font.name)),
              ],
              onChanged: (value) {
                if (value != null) {
                  context.read<ThemeController>().setFont(value);
                }
              },
            ),
          ...extra,
        ],
      ),
    );
  }

  static String _themeLabel(AppLocalizations l10n, ThemeMode mode) =>
      switch (mode) {
        ThemeMode.system => l10n.themeSystem,
        ThemeMode.light => l10n.themeLight,
        ThemeMode.dark => l10n.themeDark,
      };

  static String _fontSizeLabel(AppLocalizations l10n, AppFontSize size) =>
      switch (size) {
        AppFontSize.small => l10n.fontSmall,
        AppFontSize.normal => l10n.fontNormal,
        AppFontSize.large => l10n.fontLarge,
      };

  static String _localeLabel(Locale locale) => locale.countryCode == null
      ? locale.languageCode.toUpperCase()
      : '${locale.languageCode}_${locale.countryCode}'.toUpperCase();
}

class _Row<T> extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: DropdownButton<T>(
        underline: const SizedBox.shrink(),
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
