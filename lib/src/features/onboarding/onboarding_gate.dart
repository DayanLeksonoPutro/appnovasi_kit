import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_config.dart';
import 'onboarding_config.dart';
import 'onboarding_controller.dart';
import 'onboarding_screen.dart';

class OnboardingGate extends StatelessWidget {
  const OnboardingGate({super.key, required this.child, this.config});

  final Widget child;
  final OnboardingConfig? config;

  @override
  Widget build(BuildContext context) {
    final onboarding = config ?? context.read<AppConfig>().onboarding;
    if (onboarding == null || onboarding.isEmpty) return child;

    return Consumer<OnboardingController>(
      builder: (context, controller, _) {
        if (controller.isCompleted) return child;
        return OnboardingScreen(
          pages: onboarding.pages,
          showSkip: onboarding.showSkip,
          showIndicator: onboarding.showIndicator,
          allowBack: onboarding.allowBack,
          onFinish: controller.complete,
        );
      },
    );
  }
}
