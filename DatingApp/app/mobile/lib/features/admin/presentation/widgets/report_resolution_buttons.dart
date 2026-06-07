import 'package:dating_app/features/admin/domain/report_resolution.dart';
import 'package:flutter/material.dart';

class ReportResolutionButtons extends StatelessWidget {
  const ReportResolutionButtons({
    required this.onSelected,
    super.key,
    this.isBusy = false,
  });

  final ValueChanged<ReportResolution> onSelected;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ReportResolution.values.map((ReportResolution resolution) {
        return FilledButton.tonal(
          onPressed: isBusy ? null : () => onSelected(resolution),
          child: Text(resolution.label),
        );
      }).toList(),
    );
  }
}
