import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/profile/application/profile_providers.dart';
import 'package:dating_app/features/profile/domain/onboarding_draft.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Immutable state of the multi-step onboarding flow.
class OnboardingState {
  const OnboardingState({
    required this.draft,
    this.step = 0,
    this.isSaving = false,
    this.error,
  });

  static const int totalSteps = 5;
  static const int lastStep = totalSteps - 1;

  final OnboardingDraft draft;
  final int step;
  final bool isSaving;
  final String? error;

  bool get isReviewStep => step == lastStep;

  OnboardingState copyWith({
    OnboardingDraft? draft,
    int? step,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return OnboardingState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Drives the onboarding wizard: seeds from any saved draft, validates each
/// step, persists drafts (resume support), and submits the final profile.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  OnboardingState build() {
    // One-time seed from the already-loaded profile (resume support). Read
    // (not watch) so later profile emissions don't clobber in-progress edits.
    final profile = ref.read(currentUserProfileProvider).value;
    return OnboardingState(draft: OnboardingDraft.fromProfile(profile));
  }

  /// Replaces the working draft (used by the screen as fields change).
  void updateDraft(OnboardingDraft draft) =>
      state = state.copyWith(draft: draft, clearError: true);

  void back() {
    if (state.step > 0) {
      state = state.copyWith(step: state.step - 1, clearError: true);
    }
  }

  /// Validates the current step, saves a draft, and advances.
  Future<void> next() async {
    final String? error = state.draft.validateStep(state.step);
    if (error != null) {
      state = state.copyWith(error: error);
      return;
    }
    await _saveDraft();
    if (state.step < OnboardingState.lastStep) {
      state = state.copyWith(step: state.step + 1, clearError: true);
    }
  }

  /// Validates all data steps and finalises the profile.
  Future<void> submit() async {
    for (int s = 0; s <= 3; s++) {
      final String? error = state.draft.validateStep(s);
      if (error != null) {
        state = state.copyWith(step: s, error: error);
        return;
      }
    }
    final String? uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref.read(profileRepositoryProvider).submitProfile(uid, state.draft);
      state = state.copyWith(isSaving: false);
      // The router guard routes to Home once onboardingComplete becomes true.
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        error: 'Could not save your profile. Please try again.',
      );
    }
  }

  Future<void> _saveDraft() async {
    final String? uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await ref.read(profileRepositoryProvider).saveDraft(uid, state.draft);
    } catch (_) {
      // Draft persistence is best-effort; never blocks forward progress.
    }
    state = state.copyWith(isSaving: false);
  }
}
