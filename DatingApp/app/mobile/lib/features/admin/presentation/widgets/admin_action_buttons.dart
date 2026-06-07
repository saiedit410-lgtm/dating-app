import 'package:flutter/material.dart';

class AdminActionButtons extends StatelessWidget {
  const AdminActionButtons({
    required this.primaryLabel,
    required this.onPrimary,
    super.key,
    this.secondaryLabel,
    this.onSecondary,
    this.isBusy = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        FilledButton(
          onPressed: isBusy ? null : onPrimary,
          child: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(primaryLabel),
        ),
        if (secondaryLabel != null)
          OutlinedButton(
            onPressed: isBusy ? null : onSecondary,
            child: Text(secondaryLabel!),
          ),
      ],
    );
  }
}
