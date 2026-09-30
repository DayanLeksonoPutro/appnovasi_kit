import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/onboarding/onboarding_gate.dart';
import '../routing/app_routes.dart';
import '../routing/app_shell.dart';
import '../services/app_info_service.dart';
import '../services/link_service.dart';
import '../services/locale_controller.dart';
import '../services/permission_service.dart';
import '../services/purchase_service.dart';
import '../services/rate_service.dart';
import '../services/share_service.dart';
import '../services/storage_service.dart';
import '../services/theme_controller.dart';
import 'app_config.dart';
import 'app_kit.dart';

class AppKitApp extends StatelessWidget {
  const AppKitApp({
    super.key,
    this.config,
    this.routerConfig,
    this.home,
    this.routes = const <String, WidgetBuilder>{},
    this.builder,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.navigatorKey,
    this.initialLocation,
  }) : assert(
         routerConfig != null ||
             home != null ||
             routes.length > 0 ||
             onGenerateRoute != null,
         'Provide routerConfig, home, routes, or onGenerateRoute.',
       );

  final AppConfig? config;
  final RouterConfig<Object>? routerConfig;
  final Widget? home;
  final Map<String, WidgetBuilder> routes;
  final TransitionBuilder? builder;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? initialLocation;

  AppConfig get _config => config ?? AppKit.config;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: _config),
        Provider<StorageService>.value(value: AppKit.storage),
        Provider<AppInfoService>.value(
          value: AppKit.appInfo ?? const AppInfoService(),
        ),
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(AppKit.storage, _config),
        ),
        ChangeNotifierProvider<LocaleController>(
          create: (_) => LocaleController(AppKit.storage, _config),
        ),
        ChangeNotifierProvider<PurchaseService>(
          create: (_) => PurchaseService(_config)..init(),
        ),
        Provider<ShareService>(create: (_) => ShareService(_config)),
        Provider<RateService>(create: (_) => RateService(_config)),
        Provider<LinkService>(create: (_) => const LinkService()),
        Provider<PermissionService>(create: (_) => const PermissionService()),
        ChangeNotifierProvider<OnboardingController>(
          create: (_) => OnboardingController(AppKit.storage),
        ),
      ],
      child: Consumer2<ThemeController, LocaleController>(
        builder: (context, theme, locale, _) => _buildApp(theme, locale),
      ),
    );
  }

  Widget _buildApp(ThemeController theme, LocaleController locale) {
    final light = _config.lightTheme(
      seedColor: theme.seedColor,
      fontFamily: theme.fontFamily,
    );
    final dark = _config.darkTheme(
      seedColor: theme.seedColor,
      fontFamily: theme.fontFamily,
    );
    final homeWidget = home;
    final gatedHome = homeWidget == null || !_config.hasOnboarding
        ? homeWidget
        : OnboardingGate(config: _config.onboarding, child: homeWidget);
    final appBuilder = _scaleBuilder(theme);

    final effectiveRouter = routerConfig ?? _buildShellRouter();
    if (effectiveRouter != null) {
      return MaterialApp.router(
        title: _config.appName,
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        themeMode: theme.themeMode,
        locale: locale.locale,
        supportedLocales: _config.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: effectiveRouter,
        builder: appBuilder,
      );
    }

    return MaterialApp(
      title: _config.appName,
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: theme.themeMode,
      locale: locale.locale,
      supportedLocales: _config.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: gatedHome,
      routes: routes,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      navigatorKey: navigatorKey,
      builder: appBuilder,
    );
  }

  TransitionBuilder _scaleBuilder(ThemeController theme) {
    return (context, child) {
      final scaled = MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(theme.textScale)),
        child: child ?? const SizedBox.shrink(),
      );
      return builder == null ? scaled : builder!(context, scaled);
    };
  }

  RouterConfig<Object>? _buildShellRouter() {
    final navigation = _config.navigation;
    if (navigation == null || navigation.tabs.isEmpty) return null;

    return AppRouter.createShell(
      navigation: navigation,
      routes: routes,
      navigatorKey: navigatorKey,
      initialLocation: initialLocation,
      shellBuilder: (context, shell) {
        final appShell = AppShell(
          tabs: navigation.tabs,
          navigationShell: shell,
        );
        return _config.hasOnboarding
            ? OnboardingGate(config: _config.onboarding, child: appShell)
            : appShell;
      },
    );
  }
}
