import 'package:flutter/widgets.dart';

class NavTab {
  const NavTab({
    required this.label,
    required this.icon,
    required this.path,
    this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData? selectedIcon;
  final String path;
}

class BottomNavConfig {
  const BottomNavConfig({required this.tabs, this.initialIndex = 0});

  final List<NavTab> tabs;
  final int initialIndex;
}
