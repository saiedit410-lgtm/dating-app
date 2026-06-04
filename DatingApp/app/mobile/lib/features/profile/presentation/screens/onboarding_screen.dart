import 'package:dating_app/features/profile/application/onboarding_controller.dart';
import 'package:dating_app/features/profile/domain/onboarding_draft.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';
import 'package:dating_app/shared/extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Five-step onboarding wizard: Basics → Preferences → Location → Bio → Review.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();
  final TextEditingController _country = TextEditingController();

  DateTime? _dob;
  Gender? _gender;
  final Set<Gender> _interestedIn = <Gender>{};
  DatingIntent? _intent;

  @override
  void initState() {
    super.initState();
    final OnboardingDraft draft = ref.read(onboardingControllerProvider).draft;
    _name.text = draft.displayName ?? '';
    _bio.text = draft.bio ?? '';
    _city.text = draft.city ?? '';
    _state.text = draft.state ?? '';
    _country.text = draft.country ?? '';
    _dob = draft.dateOfBirth;
    _gender = draft.gender;
    _interestedIn.addAll(draft.interestedIn);
    _intent = draft.datingIntent;
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    super.dispose();
  }

  OnboardingDraft get _draft => OnboardingDraft(
    displayName: _name.text,
    dateOfBirth: _dob,
    gender: _gender,
    interestedIn: _interestedIn.toList(),
    datingIntent: _intent,
    bio: _bio.text,
    city: _city.text,
    state: _state.text,
    country: _country.text,
  );

  void _sync() =>
      ref.read(onboardingControllerProvider.notifier).updateDraft(_draft);

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    _sync();
    await ref.read(onboardingControllerProvider.notifier).next();
  }

  void _back() => ref.read(onboardingControllerProvider.notifier).back();

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    _sync();
    await ref.read(onboardingControllerProvider.notifier).submit();
  }

  Future<void> _pickDob() async {
    final DateTime now = DateTime.now();
    final DateTime latest = DateTime(now.year - OnboardingDraft.minAge, now.month, now.day);
    final DateTime picked =
        _dob ?? DateTime(now.year - 25, now.month, now.day);
    final DateTime? result = await showDatePicker(
      context: context,
      initialDate: picked.isAfter(latest) ? latest : picked,
      firstDate: DateTime(1900),
      lastDate: latest,
      helpText: 'Select your date of birth',
    );
    if (result != null) setState(() => _dob = result);
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingState state = ref.watch(onboardingControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create your profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            LinearProgressIndicator(
              value: (state.step + 1) / OnboardingState.totalSteps,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStep(state.step),
              ),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  state.error!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              ),
            _buildNavBar(state),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int step) => switch (step) {
    0 => _basicsStep(),
    1 => _preferencesStep(),
    2 => _locationStep(),
    3 => _bioStep(),
    _ => _reviewStep(),
  };

  Widget _stepTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: context.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _basicsStep() {
    final String dobLabel = _dob == null
        ? 'Select date of birth'
        : '${_dob!.day}/${_dob!.month}/${_dob!.year} '
              '(age ${UserProfile.calculateAge(_dob!)})';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _stepTitle('About you', 'Step 1 of 5 · Basic information'),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          maxLength: 30,
          decoration: const InputDecoration(
            labelText: 'Display name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _pickDob,
          icon: const Icon(Icons.cake_outlined),
          label: Text(dobLabel),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            alignment: Alignment.centerLeft,
          ),
        ),
        const SizedBox(height: 20),
        Text('Gender', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Gender.values.map((Gender g) {
            return ChoiceChip(
              label: Text(g.label),
              selected: _gender == g,
              onSelected: (_) => setState(() => _gender = g),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _preferencesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _stepTitle('Preferences', 'Step 2 of 5 · Who and what you want'),
        Text('Interested in', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Gender.values.map((Gender g) {
            return FilterChip(
              label: Text(g.label),
              selected: _interestedIn.contains(g),
              onSelected: (bool selected) => setState(() {
                if (selected) {
                  _interestedIn.add(g);
                } else {
                  _interestedIn.remove(g);
                }
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Text('Looking for', style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: DatingIntent.values.map((DatingIntent i) {
            return ChoiceChip(
              label: Text(i.label),
              selected: _intent == i,
              onSelected: (_) => setState(() => _intent = i),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _locationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _stepTitle('Location', 'Step 3 of 5 · Where you are'),
        TextField(
          controller: _city,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _state,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'State / Province',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _country,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Country',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _bioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _stepTitle('Your bio', 'Step 4 of 5 · Say something about yourself'),
        TextField(
          controller: _bio,
          maxLength: OnboardingDraft.maxBioLength,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Bio',
            hintText: 'What makes you, you?',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _reviewStep() {
    final OnboardingDraft d = _draft;
    final String age =
        d.dateOfBirth == null ? '—' : '${UserProfile.calculateAge(d.dateOfBirth!)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _stepTitle('Review', 'Step 5 of 5 · Confirm and submit'),
        _reviewRow('Name', d.displayName ?? '—'),
        _reviewRow('Age', age),
        _reviewRow('Gender', d.gender?.label ?? '—'),
        _reviewRow(
          'Interested in',
          d.interestedIn.isEmpty
              ? '—'
              : d.interestedIn.map((Gender g) => g.label).join(', '),
        ),
        _reviewRow('Looking for', d.datingIntent?.label ?? '—'),
        _reviewRow(
          'Location',
          <String?>[d.city, d.state, d.country]
              .where((String? s) => s != null && s.trim().isNotEmpty)
              .join(', '),
        ),
        _reviewRow('Bio', (d.bio?.trim().isNotEmpty ?? false) ? d.bio!.trim() : '—'),
      ],
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: context.textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar(OnboardingState state) {
    final bool isReview = state.isReviewStep;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: <Widget>[
          if (state.step > 0)
            OutlinedButton(
              onPressed: state.isSaving ? null : _back,
              child: const Text('Back'),
            ),
          const Spacer(),
          FilledButton(
            onPressed: state.isSaving ? null : (isReview ? _submit : _next),
            style: FilledButton.styleFrom(minimumSize: const Size(140, 48)),
            child: state.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(isReview ? 'Submit' : 'Next'),
          ),
        ],
      ),
    );
  }
}
