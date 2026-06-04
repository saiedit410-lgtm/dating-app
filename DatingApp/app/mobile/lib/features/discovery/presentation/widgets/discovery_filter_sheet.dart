import 'package:dating_app/features/discovery/domain/discovery_filters.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for editing [DiscoveryFilters]. Pops the edited filters on
/// "Apply", or null if dismissed.
class DiscoveryFilterSheet extends StatefulWidget {
  const DiscoveryFilterSheet({super.key, required this.initial});

  final DiscoveryFilters initial;

  @override
  State<DiscoveryFilterSheet> createState() => _DiscoveryFilterSheetState();
}

class _DiscoveryFilterSheetState extends State<DiscoveryFilterSheet> {
  late Gender? _gender = widget.initial.gender;
  late final Set<Gender> _interestedIn = <Gender>{...widget.initial.interestedIn};
  late RangeValues _ageRange = RangeValues(
    widget.initial.minAge.toDouble(),
    widget.initial.maxAge.toDouble(),
  );
  late final TextEditingController _city = TextEditingController(
    text: widget.initial.city ?? '',
  );
  late final TextEditingController _state = TextEditingController(
    text: widget.initial.state ?? '',
  );

  @override
  void dispose() {
    _city.dispose();
    _state.dispose();
    super.dispose();
  }

  DiscoveryFilters _build() => DiscoveryFilters(
    gender: _gender,
    interestedIn: _interestedIn.toList(),
    minAge: _ageRange.start.round(),
    maxAge: _ageRange.end.round(),
    city: _city.text.trim().isEmpty ? null : _city.text.trim(),
    state: _state.text.trim().isEmpty ? null : _state.text.trim(),
  );

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
              Text('Filters', style: context.textTheme.headlineSmall),
              const SizedBox(height: 16),
              Text('Gender', style: context.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('Any'),
                    selected: _gender == null,
                    onSelected: (_) => setState(() => _gender = null),
                  ),
                  for (final Gender g in Gender.values)
                    ChoiceChip(
                      label: Text(g.label),
                      selected: _gender == g,
                      onSelected: (_) => setState(() => _gender = g),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Interested in', style: context.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  for (final Gender g in Gender.values)
                    FilterChip(
                      label: Text(g.label),
                      selected: _interestedIn.contains(g),
                      onSelected: (bool selected) => setState(() {
                        if (selected) {
                          _interestedIn.add(g);
                        } else {
                          _interestedIn.remove(g);
                        }
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Age: ${_ageRange.start.round()}–${_ageRange.end.round()}',
                style: context.textTheme.titleMedium,
              ),
              RangeSlider(
                values: _ageRange,
                min: DiscoveryFilters.minSupportedAge.toDouble(),
                max: DiscoveryFilters.maxSupportedAge.toDouble(),
                divisions:
                    DiscoveryFilters.maxSupportedAge -
                    DiscoveryFilters.minSupportedAge,
                labels: RangeLabels(
                  '${_ageRange.start.round()}',
                  '${_ageRange.end.round()}',
                ),
                onChanged: (RangeValues v) => setState(() => _ageRange = v),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _city,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _state,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'State / Province',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  OutlinedButton(
                    onPressed: () =>
                        Navigator.of(context).pop(const DiscoveryFilters()),
                    child: const Text('Reset'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(_build()),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
