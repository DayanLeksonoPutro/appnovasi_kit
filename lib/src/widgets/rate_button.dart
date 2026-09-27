import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../services/rate_service.dart';

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

  Future<void> _onPressed(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FilledButton.icon(
      style: style,
      onPressed: () => _onPressed(context),
      icon: icon ?? const Icon(Icons.star_outline),
      label: Text(label ?? l10n.rate),
    );
  }
}
