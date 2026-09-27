import 'package:flutter/material.dart';

class OnboardingPage {
  const OnboardingPage({
    this.title,
    this.description,
    this.icon,
    this.imageAsset,
  });

  final String? title;
  final String? description;
  final IconData? icon;
  final String? imageAsset;
}

class OnboardingConfig {
  const OnboardingConfig({
    required this.pages,
    this.showSkip = true,
    this.showIndicator = true,
    this.allowBack = true,
  });

  final List<OnboardingPage> pages;
  final bool showSkip;
  final bool showIndicator;
  final bool allowBack;

  bool get isEmpty => pages.isEmpty;
}
