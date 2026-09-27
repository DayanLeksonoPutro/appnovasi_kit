import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../services/rate_service.dart';

Future<void> _rate(BuildContext context, {required bool confirm}) async {
  final service = context.read<RateService>();
  if (!confirm) {
    await service.openStore();
    return;
  }
  final l10n = AppLocalizations.of(context);
  final shouldRate = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.rateTitle),
      content: Text(l10n.rateMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.rate),
        ),
      ],
    ),
  );
  if (shouldRate ?? false) {
    await service.openStore();
  }
}

class RateButton extends StatelessWidget {
  const RateButton({
    super.key,
    this.label,
    this.style,
    this.icon,
    this.confirm = true,
  });

  final String? label;
  final ButtonStyle? style;
  final Widget? icon;
  final bool confirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FilledButton.icon(
      style: style,
      onPressed: () => _rate(context, confirm: confirm),
      icon: icon ?? const Icon(Icons.star_outline),
      label: Text(label ?? l10n.rate),
    );
  }
}

class RateIconButton extends StatelessWidget {
  const RateIconButton({
    super.key,
    this.tooltip,
    this.icon,
    this.confirm = true,
  });

  final String? tooltip;
  final Widget? icon;
  final bool confirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: tooltip ?? l10n.rate,
      onPressed: () => _rate(context, confirm: confirm),
      icon: icon ?? const Icon(Icons.star_outline),
    );
  }
}
