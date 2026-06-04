import 'package:dating_app/features/auth/application/auth_providers.dart';
import 'package:dating_app/features/profile/application/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_startup.g.dart';

/// The coarse app-startup stage that the router guard reacts to.
///
/// Modelled as a single enum so the router only rebuilds when the *routing
/// decision* changes — not on every profile-field update during onboarding.
enum AppStartupStage { loading, loggedOut, onboarding, ready }

/// Derives the [AppStartupStage] from auth + profile state.
@Riverpod(keepAlive: true)
AppStartupStage appStartupStage(Ref ref) {
  final auth = ref.watch(authStateChangesProvider);
  if (auth.isLoading) return AppStartupStage.loading;

  final user = auth.value;
  if (user == null) return AppStartupStage.loggedOut;

  final profile = ref.watch(currentUserProfileProvider);
  if (profile.isLoading) return AppStartupStage.loading;

  final bool complete = profile.value?.onboardingComplete ?? false;
  return complete ? AppStartupStage.ready : AppStartupStage.onboarding;
}
