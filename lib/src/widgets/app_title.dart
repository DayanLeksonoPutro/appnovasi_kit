import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_config.dart';
import '../services/app_info_service.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final info = context.watch<AppInfoService>();
    final text = info.hasVersion
        ? '${config.appName} ${info.version}'
        : config.appName;

    return Text(text, style: style, overflow: TextOverflow.ellipsis);
  }
}

class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final info = context.watch<AppInfoService>();
    if (!info.hasVersion) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Text(
      info.versionLabel,
      style:
          style ??
          theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
    );
  }
}
