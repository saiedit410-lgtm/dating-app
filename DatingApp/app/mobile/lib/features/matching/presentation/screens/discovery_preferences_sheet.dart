import 'package:dating_app/features/matching/application/match_preferences_controller.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The "Discovery preferences" sheet. Lets the user tune age range,
/// required genders, and the intent-strict filter. Persisted on
/// [Save] via [MatchPreferencesController].
class DiscoveryPreferencesSheet extends ConsumerStatefulWidget {
  const DiscoveryPreferencesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const DiscoveryPreferencesSheet(),
    );
  }

  @override
  ConsumerState<DiscoveryPreferencesSheet> createState() =>
      _DiscoveryPreferencesSheetState();
}

class _DiscoveryPreferencesSheetState
    extends ConsumerState<DiscoveryPreferencesSheet> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(matchPreferencesControllerProvider.notifier).save();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MatchPreferences prefs =
        ref.watch(matchPreferencesControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Discovery preferences',
                style: context.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Tune who shows up in your feed.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              const _SectionLabel('Age range you\'re open to'),
              _AgeRangeRow(
                min: prefs.otherAgeMin,
                max: prefs.otherAgeMax,
                onChanged: (int min, int max) => ref
                    .read(matchPreferencesControllerProvider.notifier)
                    .patch(otherAgeMin: min, otherAgeMax: max),
              ),
              const SizedBox(height: 20),

              const _SectionLabel('Genders you want to see'),
              _GenderChips(
                selected: prefs.requiredGenders,
                onChanged: (List<Gender> g) => ref
                    .read(matchPreferencesControllerProvider.notifier)
                    .patch(requiredGenders: g),
              ),
              const SizedBox(height: 20),

              const _SectionLabel('Strictness'),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Require compatible intent'),
                subtitle: const Text(
                  'Only show people looking for the same thing as you.',
                ),
                value: prefs.requireIntentMatch,
                onChanged: (bool v) => ref
                    .read(matchPreferencesControllerProvider.notifier)
                    .patch(requireIntentMatch: v),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: context.textTheme.labelLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      );
}

class _AgeRangeRow extends StatefulWidget {
  const _AgeRangeRow({
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final int min;
  final int max;
  final void Function(int min, int max) onChanged;

  @override
  State<_AgeRangeRow> createState() => _AgeRangeRowState();
}

class _AgeRangeRowState extends State<_AgeRangeRow> {
  late RangeValues _values = RangeValues(
    widget.min.toDouble(),
    widget.max.toDouble(),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('${_values.start.round()} – ${_values.end.round()}'),
            Text(
              'Your age range',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        RangeSlider(
          values: _values,
          min: 18,
          max: 80,
          divisions: 62,
          labels: RangeLabels(
            '${_values.start.round()}',
            '${_values.end.round()}',
          ),
          onChanged: (RangeValues v) {
            setState(() => _values = v);
            widget.onChanged(v.start.round(), v.end.round());
          },
        ),
      ],
    );
  }
}

class _GenderChips extends StatelessWidget {
  const _GenderChips({
    required this.selected,
    required this.onChanged,
  });
  final List<Gender> selected;
  final void Function(List<Gender>) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final Gender g in Gender.values)
          FilterChip(
            label: Text(g.label),
            selected: selected.contains(g),
            onSelected: (bool on) {
              final List<Gender> next = List<Gender>.from(selected);
              if (on) {
                if (!next.contains(g)) next.add(g);
              } else {
                next.remove(g);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}
