import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../services/share_service.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    this.label,
    this.style,
    this.icon,
    this.shareText,
  });

  final String? label;
  final ButtonStyle? style;
  final Widget? icon;
  final String? shareText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FilledButton.icon(
      style: style,
      onPressed: () {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size;
        context.read<ShareService>().shareApp(text: shareText, origin: origin);
      },
      icon: icon ?? const Icon(Icons.share_outlined),
      label: Text(label ?? l10n.share),
    );
  }
}

class ShareIconButton extends StatelessWidget {
  const ShareIconButton({super.key, this.tooltip, this.icon, this.shareText});

  final String? tooltip;
  final Widget? icon;
  final String? shareText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: tooltip ?? l10n.share,
      onPressed: () {
        final box = context.findRenderObject() as RenderBox?;
        final origin = box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size;
        context.read<ShareService>().shareApp(text: shareText, origin: origin);
      },
      icon: icon ?? const Icon(Icons.share_outlined),
    );
  }
}
