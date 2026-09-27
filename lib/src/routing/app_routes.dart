import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'navigation_config.dart';

typedef AppRedirect =
    FutureOr<String?> Function(BuildContext context, GoRouterState state);

typedef AppShellBuilder =
    Widget Function(
      BuildContext context,
      StatefulNavigationShell navigationShell,
    );

class AppRouter {
  const AppRouter._();

  static GoRouter create({
    required List<RouteBase> routes,
    String initialLocation = '/',
    AppRedirect? redirect,
    GlobalKey<NavigatorState>? navigatorKey,
    List<NavigatorObserver> observers = const [],
  }) {
    return GoRouter(
      initialLocation: initialLocation,
      navigatorKey: navigatorKey,
      observers: observers,
      routes: routes,
      redirect: redirect == null
          ? null
          : (context, state) => redirect(context, state),
    );
  }

  static GoRouter createShell({
    required BottomNavConfig navigation,
    Map<String, WidgetBuilder> routes = const <String, WidgetBuilder>{},
    String? initialLocation,
    AppRedirect? redirect,
    GlobalKey<NavigatorState>? navigatorKey,
    List<NavigatorObserver> observers = const [],
    AppShellBuilder? shellBuilder,
  }) {
    final tabs = navigation.tabs;
    if (tabs.isEmpty) {
      throw ArgumentError.value(
        navigation,
        'navigation',
        'At least one tab is required',
      );
    }

    final branches = <StatefulShellBranch>[
      for (final tab in tabs) _branchFor(tab, tabs, routes),
    ];

    final topLevel = routes.entries.where(
      (entry) => _ownerOf(entry.key, tabs) == null,
    );

    final defaultIndex = navigation.initialIndex.clamp(0, tabs.length - 1);

    return GoRouter(
      initialLocation: initialLocation ?? tabs[defaultIndex].path,
      navigatorKey: navigatorKey,
      observers: observers,
      redirect: redirect == null
          ? null
          : (context, state) => redirect(context, state),
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              (shellBuilder ??
              (context, shell) => AppShell(tabs: tabs, navigationShell: shell))(
                context,
                navigationShell,
              ),
          branches: branches,
        ),
        for (final entry in topLevel)
          GoRoute(
            path: entry.key,
            builder: (context, state) => entry.value(context),
          ),
      ],
    );
  }

  static StatefulShellBranch _branchFor(
    NavTab tab,
    List<NavTab> tabs,
    Map<String, WidgetBuilder> routes,
  ) {
    final rootBuilder = routes[tab.path];
    if (rootBuilder == null) {
      throw ArgumentError('No route registered for tab path "${tab.path}".');
    }

    final children =
        routes.entries
            .where(
              (entry) =>
                  entry.key != tab.path &&
                  _ownerOf(entry.key, tabs) == tab.path,
            )
            .toList()
          ..sort((a, b) => a.key.length.compareTo(b.key.length));

    return StatefulShellBranch(
      routes: [
        GoRoute(
          path: tab.path,
          builder: (context, state) => rootBuilder(context),
          routes: [
            for (final child in children)
              GoRoute(
                path: _relativePath(child.key, tab.path),
                builder: (context, state) => child.value(context),
              ),
          ],
        ),
      ],
    );
  }

  static String? _ownerOf(String route, List<NavTab> tabs) {
    NavTab? owner;
    for (final tab in tabs) {
      if (_belongsTo(route, tab.path) &&
          (owner == null || tab.path.length > owner.path.length)) {
        owner = tab;
      }
    }
    return owner?.path;
  }

  static bool _belongsTo(String route, String tabPath) {
    if (route == tabPath) return true;
    if (tabPath == '/') return route.startsWith('/');
    return route.startsWith('$tabPath/');
  }

  static String _relativePath(String route, String tabPath) {
    return tabPath == '/'
        ? route.substring(1)
        : route.substring(tabPath.length + 1);
  }
}
