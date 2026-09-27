import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

typedef AppRedirect =
    FutureOr<String?> Function(BuildContext context, GoRouterState state);

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
}
