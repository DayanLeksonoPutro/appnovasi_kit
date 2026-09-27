import 'dart:io';

import 'package:appnovasi_kit/appnovasi_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('appnovasi_kit_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('AppConfig builds light and dark themes with bundled font', () {
    const config = AppConfig(appName: 'Demo', packageId: 'com.demo');
    expect(config.effectiveFontFamily, 'Poppins');
    expect(config.lightTheme().colorScheme.brightness, Brightness.light);
    expect(config.darkTheme().colorScheme.brightness, Brightness.dark);
  });

  test('ThemeController persists and toggles the theme mode', () async {
    final storage = StorageService();
    await storage.init();
    final controller = ThemeController(
      storage,
      const AppConfig(appName: 'Demo', packageId: 'com.demo'),
    );

    controller.setThemeMode(ThemeMode.dark);
    expect(controller.themeMode, ThemeMode.dark);
    expect(storage.read<String>('theme_mode'), 'dark');

    controller.toggle();
    expect(controller.themeMode, ThemeMode.light);
  });

  test('LocaleController resolves a supported locale', () async {
    final storage = StorageService();
    await storage.init();
    const config = AppConfig(
      appName: 'Demo',
      packageId: 'com.demo',
      supportedLocales: [Locale('en'), Locale('id')],
      defaultLocale: Locale('en'),
    );
    final controller = LocaleController(storage, config);

    controller.setLocale(const Locale('id'));
    expect(controller.locale, const Locale('id'));
    expect(storage.read<String>('locale'), 'id');
  });
}
