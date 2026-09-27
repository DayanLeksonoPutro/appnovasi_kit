import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'navigation_config.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.tabs,
    required this.navigationShell,
  });

  final List<NavTab> tabs;
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: tab.selectedIcon == null
                  ? null
                  : Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}
