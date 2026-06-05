import 'package:dating_app/features/safety/domain/report.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';

/// Bottom sheet collecting a report category + description. Pops a
/// `(ReportCategory, String description)` record on submit, or null if dismissed.
class ReportSheet extends StatefulWidget {
  const ReportSheet({super.key});

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  static const int _maxDescription = 500;
  ReportCategory? _category;
  final TextEditingController _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Report user', style: context.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Tell us what\'s wrong. Reports are confidential.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<ReportCategory>(
                groupValue: _category,
                onChanged: (ReportCategory? value) =>
                    setState(() => _category = value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    for (final ReportCategory c in ReportCategory.values)
                      RadioListTile<ReportCategory>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(c.label),
                        value: c,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _description,
                maxLength: _maxDescription,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Details (optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _category == null
                    ? null
                    : () => Navigator.of(context).pop(
                        (_category!, _description.text.trim()),
                      ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Submit report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
