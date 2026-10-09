import 'dart:io';

import 'package:appnovasi_kit/appnovasi_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

Widget _pump(
  Widget child, {
  required StorageService storage,
  AppConfig? config,
  AppInfoService info = const AppInfoService(
    version: '1.2.3',
    buildNumber: '45',
  ),
}) {
  final resolvedConfig =
      config ?? AppConfig(appName: 'Demo App', packageId: 'com.demo');

  return MultiProvider(
    providers: [
      Provider<AppConfig>.value(value: resolvedConfig),
      Provider<AppInfoService>.value(value: info),
      Provider<StorageService>.value(value: storage),
      ChangeNotifierProvider<ThemeController>(
        create: (_) => ThemeController(storage, resolvedConfig),
      ),
      ChangeNotifierProvider<LocaleController>(
        create: (_) => LocaleController(storage, resolvedConfig),
      ),
      Provider<ShareService>(create: (_) => ShareService(resolvedConfig)),
      Provider<RateService>(create: (_) => RateService(resolvedConfig)),
      Provider<LinkService>(create: (_) => const LinkService()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dir;

  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('appnovasi_kit_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('AppConfig supports BrandConfig and ThemeConfig objects', () {
    final config = AppConfig(
      brand: BrandConfig(
        appName: 'NusaPay',
        packageId: 'com.nusapay.app',
        slogan: 'Mudah bayar, aman, cepat',
      ),
      theme: ThemeConfig(
        accentColor: Color(0xFF0F766E),
        success: Color(0xFF16A34A),
        warning: Color(0xFFF59E0B),
        error: Color(0xFFDC2626),
      ),
    );

    expect(config.brand.appName, 'NusaPay');
    expect(config.brand.packageId, 'com.nusapay.app');
    expect(config.theme.accentColor, const Color(0xFF0F766E));
    expect(config.appName, 'NusaPay');
    expect(config.packageId, 'com.nusapay.app');
  });

  test('AppConfig supports localized ContentConfig values', () {
    final config = AppConfig(
      appName: 'Demo',
      packageId: 'com.demo',
      content: ContentConfig(
        welcomeTitle: LocalizedText({'en': 'Welcome', 'id': 'Selamat datang'}),
        heroTitle: LocalizedText({
          'en': 'Manage everything in one place',
          'id': 'Kelola semuanya dalam satu tempat',
        }),
        appDescription: LocalizedText({
          'en': 'A modern app for daily life.',
          'id': 'Aplikasi modern untuk kehidupan sehari-hari.',
        }),
      ),
    );

    expect(config.content.welcomeTitleFor(const Locale('en')), 'Welcome');
    expect(
      config.content.welcomeTitleFor(const Locale('id')),
      'Selamat datang',
    );
    expect(
      config.content.heroTitleFor(const Locale('id')),
      'Kelola semuanya dalam satu tempat',
    );
    expect(
      config.content.appDescriptionFor(const Locale('en')),
      'A modern app for daily life.',
    );
    expect(
      config.contentFor(const Locale('id')).welcomeTitle,
      'Selamat datang',
    );
  });

  test('AppConfig builds light and dark themes with bundled font', () {
    final config = AppConfig(appName: 'Demo', packageId: 'com.demo');
    expect(config.effectiveFontFamily, 'Poppins');
    expect(config.lightTheme().colorScheme.brightness, Brightness.light);
    expect(config.darkTheme().colorScheme.brightness, Brightness.dark);
  });

  test('ThemeController persists and toggles the theme mode', () async {
    final storage = StorageService();
    await storage.init();
    final controller = ThemeController(
      storage,
      AppConfig(appName: 'Demo', packageId: 'com.demo'),
    );

    controller.setThemeMode(ThemeMode.dark);
    expect(controller.themeMode, ThemeMode.dark);
    expect(storage.read<String>('theme_mode'), 'dark');

    controller.toggle();
    expect(controller.themeMode, ThemeMode.light);
  });

  test('ThemeController exposes the configured accent color', () async {
    final storage = StorageService();
    await storage.init();
    await storage.clear();
    final controller = ThemeController(
      storage,
      AppConfig(appName: 'Demo', packageId: 'com.demo'),
    );

    expect(controller.accentColor, const Color(0xFF4F46E5));

    final branded = ThemeController(
      storage,
      AppConfig(
        appName: 'Demo',
        packageId: 'com.demo',
        accentColor: const Color(0xFF10B981),
      ),
    );
    expect(branded.accentColor, const Color(0xFF10B981));
  });

  test('theme keeps neutral surfaces and full-color accent', () {
    const accent = Color(0xFF0EA5E9);
    final config = AppConfig(
      appName: 'Demo',
      packageId: 'com.demo',
      accentColor: accent,
    );

    for (final theme in [config.lightTheme(), config.darkTheme()]) {
      final scheme = theme.colorScheme;
      expect(scheme.primary, accent);
      expect(scheme.onPrimary, Colors.white);
      expect(theme.scaffoldBackgroundColor, isNot(accent));
      expect(scheme.surfaceTint, Colors.transparent);
    }

    final light = config.lightTheme().colorScheme;
    final dark = config.darkTheme().colorScheme;
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(
      config.darkTheme().scaffoldBackgroundColor.computeLuminance(),
      lessThan(0.2),
    );
    expect(light.onSurface, Colors.black);
    expect(dark.onSurface, Colors.white);
    expect(light.surface, Colors.white);

    for (final scheme in [light, dark]) {
      expect(scheme.outline, isNot(Colors.white));
      expect(scheme.outlineVariant, isNot(Colors.white));
    }

    for (final role in [
      dark.surface,
      dark.surfaceDim,
      dark.surfaceBright,
      dark.surfaceContainerLowest,
      dark.surfaceContainerLow,
      dark.surfaceContainer,
      dark.surfaceContainerHigh,
      dark.surfaceContainerHighest,
    ]) {
      expect(role, isNot(Colors.white));
      expect(role.computeLuminance(), lessThan(0.3));
    }
  });

  test('ThemeController persists font size and font family', () async {
    final storage = StorageService();
    await storage.init();
    await storage.clear();
    final controller = ThemeController(
      storage,
      AppConfig(appName: 'Demo', packageId: 'com.demo'),
    );

    expect(controller.fontSize, AppFontSize.normal);
    expect(controller.textScale, 1.0);
    expect(controller.fontFamily, 'Poppins');

    controller.setFontSize(AppFontSize.large);
    expect(controller.textScale, AppFontSize.large.scale);
    expect(storage.read<String>('font_size'), 'large');

    final serif = defaultFonts.firstWhere((font) => font.name == 'Serif');
    controller.setFont(serif);
    expect(controller.fontFamily, 'serif');
    expect(storage.read<String>('font_family'), 'Serif');
  });

  test('LocaleController resolves a supported locale', () async {
    final storage = StorageService();
    await storage.init();
    final config = AppConfig(
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

  test('OnboardingController persists completion state', () async {
    final storage = StorageService();
    await storage.init();
    await storage.delete('onboarding_completed');
    final controller = OnboardingController(storage);

    expect(controller.isCompleted, isFalse);
    await controller.complete();
    expect(controller.isCompleted, isTrue);
    expect(storage.read<bool>('onboarding_completed'), isTrue);

    await controller.reset();
    expect(controller.isCompleted, isFalse);
  });

  testWidgets('OnboardingScreen advances pages and fires onFinish', (
    tester,
  ) async {
    var finished = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(
          pages: const [
            OnboardingPage(title: 'One', icon: Icons.looks_one),
            OnboardingPage(title: 'Two', icon: Icons.looks_two),
          ],
          onFinish: () => finished = true,
        ),
      ),
    );

    expect(find.text('One'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(finished, isTrue);
  });

  group('PermissionService', () {
    const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
    late List<MethodCall> calls;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    void mock(int status, {int requested = 1, bool settings = true}) {
      calls = [];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        switch (call.method) {
          case 'checkPermissionStatus':
            return status;
          case 'requestPermissions':
            return <int, int>{Permission.camera.value: requested};
          case 'openAppSettings':
            return settings;
          default:
            return null;
        }
      });
    }

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('reports granted status', () async {
      mock(1);
      const service = PermissionService();
      expect(await service.isGranted(Permission.camera), isTrue);
      expect(await service.ensure(Permission.camera), isTrue);
      expect(calls.any((call) => call.method == 'openAppSettings'), isFalse);
    });

    test('opens settings when permanently denied', () async {
      mock(0, requested: 4);
      const service = PermissionService();
      expect(await service.ensure(Permission.camera), isFalse);
      expect(calls.any((call) => call.method == 'openAppSettings'), isTrue);
    });

    test('requestAll maps statuses per permission', () async {
      mock(1);
      const service = PermissionService();
      final result = await service.requestAll([Permission.camera]);
      expect(result, {Permission.camera: PermissionStatus.granted});
    });
  });

  group('AppRouter.createShell', () {
    test('throws when a tab has no registered route', () {
      expect(
        () => AppRouter.createShell(
          navigation: const BottomNavConfig(
            tabs: [NavTab(label: 'Home', icon: Icons.home, path: '/home')],
          ),
        ),
        throwsArgumentError,
      );
    });

    testWidgets('switches between navigation branches', (tester) async {
      final router = AppRouter.createShell(
        navigation: const BottomNavConfig(
          tabs: [
            NavTab(label: 'Home', icon: Icons.home, path: '/home'),
            NavTab(label: 'Settings', icon: Icons.settings, path: '/settings'),
          ],
        ),
        routes: {
          '/home': (context) => const Scaffold(body: Text('HOME')),
          '/settings': (context) => const Scaffold(body: Text('SETTINGS')),
        },
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('SETTINGS'), findsOneWidget);
    });
  });

  group('About and Settings screens', () {
    late StorageService storage;

    setUp(() async {
      storage = StorageService();
      await storage.init();
      await storage.clear();
    });

    testWidgets('AboutScreen shows header, version and configured links', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          const AboutScreen(),
          storage: storage,
          config: AppConfig(
            appName: 'Demo App',
            packageId: 'com.demo',
            description: 'A demo application.',
            moreAppsUrl: 'https://example.com/more',
            websiteUrl: 'https://example.com',
            privacyPolicyUrl: 'https://example.com/privacy',
            termsUrl: 'https://example.com/terms',
          ),
        ),
      );

      expect(find.text('Demo App'), findsOneWidget);
      expect(find.text('A demo application.'), findsOneWidget);
      expect(find.text('v1.2.3 (45)'), findsOneWidget);
      expect(find.text('More apps'), findsOneWidget);
      expect(find.text('Website'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);
    });

    testWidgets('AboutScreen hides links that are not configured', (
      tester,
    ) async {
      await tester.pumpWidget(_pump(const AboutScreen(), storage: storage));
      expect(find.text('Website'), findsNothing);
      expect(find.text('More apps'), findsNothing);
    });

    testWidgets('SettingsScreen selects theme and renders extra items', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          const SettingsScreen(extra: [ListTile(title: Text('Custom item'))]),
          storage: storage,
          config: AppConfig(
            appName: 'Demo App',
            packageId: 'com.demo',
            supportedLocales: [Locale('en'), Locale('id')],
          ),
        ),
      );

      expect(find.byType(DropdownButton<Locale>), findsOneWidget);
      expect(find.byType(DropdownButton<ThemeMode>), findsOneWidget);
      expect(find.byType(DropdownButton<AppFontSize>), findsOneWidget);
      expect(find.byType(DropdownButton<AppFont>), findsOneWidget);
      expect(find.text('Custom item'), findsOneWidget);

      final mode = tester.widget<DropdownButton<ThemeMode>>(
        find.byType(DropdownButton<ThemeMode>),
      );
      expect(mode.value, ThemeMode.system);

      final size = tester.widget<DropdownButton<AppFontSize>>(
        find.byType(DropdownButton<AppFontSize>),
      );
      expect(size.value, AppFontSize.normal);

      final serif = defaultFonts.firstWhere((f) => f.name == 'Serif');

      await tester.runAsync(() async {
        mode.onChanged!(ThemeMode.dark);
        size.onChanged!(AppFontSize.large);
        tester
            .widget<DropdownButton<AppFont>>(
              find.byType(DropdownButton<AppFont>),
            )
            .onChanged!(serif);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(
        tester
            .widget<DropdownButton<ThemeMode>>(
              find.byType(DropdownButton<ThemeMode>),
            )
            .value,
        ThemeMode.dark,
      );
      expect(
        tester
            .widget<DropdownButton<AppFontSize>>(
              find.byType(DropdownButton<AppFontSize>),
            )
            .value,
        AppFontSize.large,
      );
      expect(
        tester
            .widget<DropdownButton<AppFont>>(
              find.byType(DropdownButton<AppFont>),
            )
            .value
            ?.name,
        'Serif',
      );
    });

    testWidgets('AppTitle and AppVersionText read package info', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          const Scaffold(
            body: Column(children: [AppTitle(), AppVersionText()]),
          ),
          storage: storage,
        ),
      );
      expect(find.text('Demo App 1.2.3'), findsOneWidget);
      expect(find.text('v1.2.3 (45)'), findsOneWidget);
    });

    testWidgets('share and rate icon buttons render as app bar actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        _pump(
          Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: const [ShareIconButton(), RateIconButton()],
            ),
          ),
          storage: storage,
        ),
      );

      expect(find.byType(ShareIconButton), findsOneWidget);
      expect(find.byType(RateIconButton), findsOneWidget);
      expect(find.byType(IconButton), findsNWidgets(2));
    });
  });
}
