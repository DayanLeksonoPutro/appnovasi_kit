import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/locale_controller.dart';
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

  AppConfig get _config => config ?? AppKit.config;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: _config),
        Provider<StorageService>.value(value: AppKit.storage),
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
        Provider<AdService>(create: (_) => AdService(_config)),
      ],
      child: Consumer2<ThemeController, LocaleController>(
        builder: (context, theme, locale, _) => _buildApp(theme, locale),
      ),
    );
  }

  Widget _buildApp(ThemeController theme, LocaleController locale) {
    final light = _config.lightTheme();
    final dark = _config.darkTheme();

    if (routerConfig != null) {
      return MaterialApp.router(
        title: _config.appName,
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        themeMode: theme.themeMode,
        locale: locale.locale,
        supportedLocales: _config.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        routerConfig: routerConfig!,
        builder: builder,
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
      home: home,
      routes: routes,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      navigatorKey: navigatorKey,
      builder: builder,
    );
  }
}
