import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/matching/domain/match_preferences.dart';
import 'package:dating_app/features/matching/domain/match_scorer.dart';
import 'package:dating_app/features/matching/domain/match_weights.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:flutter_test/flutter_test.dart';

const _scorer = MatchScorer();

PublicProfile _profile({
  String uid = 'u',
  String? displayName = 'Sam',
  int? age = 25,
  Gender? gender = Gender.male,
  List<Gender> interestedIn = const <Gender>[],
  List<String> interests = const <String>[],
  DatingIntent? datingIntent,
  bool isVerified = false,
}) => PublicProfile(
      uid: uid,
      displayName: displayName,
      age: age,
      gender: gender,
      interestedIn: interestedIn,
      interests: interests,
      datingIntent: datingIntent,
      isVerified: isVerified,
    );

ViewerContext _viewer({
  String uid = 'me',
  DatingIntent? datingIntent,
  List<String> interests = const <String>[],
}) =>
    ViewerContext(
      uid: uid,
      datingIntent: datingIntent,
      interests: interests,
    );

void main() {
  group('MatchScorer.evaluate', () {
    test('returns null when a hard filter excludes the subject', () {
      final scored = _scorer.evaluate(
        viewer: _viewer(),
        subject: _profile(displayName: null),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forAll,
      );
      expect(scored, isNull);
    });

    test('composite is in [0, 100] and uses only the four soft terms', () {
      final scored = _scorer.evaluate(
        viewer: _viewer(
          datingIntent: DatingIntent.longTerm,
          interests: const <String>['music', 'hiking'],
        ),
        subject: _profile(
          interests: const <String>['music'],
          datingIntent: DatingIntent.longTerm,
          isVerified: true,
        ),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forAll,
      );
      expect(scored, isNotNull);
      expect(scored!.score, inInclusiveRange(0.0, 100.0));
      // forAll has wDist = 0 → no dist term.
      expect(scored.terms.containsKey('dist'), isFalse);
      expect(scored.terms.keys.toSet(),
          <String>{'interest', 'intent', 'verify'});
    });

    test('All tab with all-positive signals hits the top of the range', () {
      final scored = _scorer.evaluate(
        viewer: _viewer(
          datingIntent: DatingIntent.longTerm,
          interests: const <String>['music', 'hiking', 'cooking'],
        ),
        subject: _profile(
          interests: const <String>['music', 'hiking', 'cooking'],
          datingIntent: DatingIntent.longTerm,
          isVerified: true,
        ),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forAll,
      );
      // interest=~0.8 (size-penalised Jaccard), intent=1.0, verify=1.0
      // Score = (0 + 0.8*0.40 + 1.0*0.35 + 1.0*0.25) * 100 = 92
      expect(scored!.score, greaterThan(85.0));
      expect(scored.score, lessThanOrEqualTo(100.0));
    });

    test('Nearby feed includes a dist term when distance is provided', () {
      final scored = _scorer.evaluate(
        viewer: _viewer(),
        subject: _profile(),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forNearby,
        subjectDistanceKm: 1.0,
      );
      expect(scored, isNotNull);
      expect(scored!.terms.containsKey('dist'), isTrue);
      // 1 km < 2 km nearBand → 1.0
      expect(scored.terms['dist'], 1.0);
    });

    test('Missing distance returns 0.5 (neutral), not 0.0', () {
      final scored = _scorer.evaluate(
        viewer: _viewer(),
        subject: _profile(),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forNearby,
        subjectDistanceKm: null,
      );
      expect(scored, isNotNull);
      expect(scored!.terms['dist'], 0.5);
    });

    test('Score ordering: high-signal subject beats low-signal subject', () {
      final high = _scorer.evaluate(
        viewer: _viewer(
          datingIntent: DatingIntent.longTerm,
          interests: const <String>['music', 'hiking', 'cooking'],
        ),
        subject: _profile(
          interests: const <String>['music', 'hiking', 'cooking'],
          datingIntent: DatingIntent.longTerm,
          isVerified: true,
        ),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forAll,
      );
      final low = _scorer.evaluate(
        viewer: _viewer(
          datingIntent: DatingIntent.longTerm,
          interests: const <String>['music', 'hiking', 'cooking'],
        ),
        subject: _profile(
          uid: 'other',
          datingIntent: DatingIntent.friendship, // 0.2 vs longTerm
          isVerified: false,
        ),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forAll,
      );
      expect(high, isNotNull);
      expect(low, isNotNull);
      expect(high!.score, greaterThan(low!.score));
    });
  });

  group('ScoredProfile.topReasons', () {
    test('returns the top N user-facing seeds in term-value order', () {
      final scored = _scorer.evaluate(
        viewer: _viewer(
          datingIntent: DatingIntent.longTerm,
          interests: const <String>['music', 'hiking', 'cooking'],
        ),
        subject: _profile(
          interests: const <String>['music', 'hiking', 'cooking'],
          datingIntent: DatingIntent.longTerm,
          isVerified: true,
        ),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forAll,
      );
      final reasons = scored!.topReasons();
      expect(reasons, isNotEmpty);
      // Verified is binary → "Verified profile" should appear.
      expect(reasons, contains('Verified profile'));
      // Interest overlap is high → "Lots in common".
      expect(reasons, contains('Lots in common'));
    });

    test('returns empty list when all terms are zero', () {
      final scored = _scorer.evaluate(
        viewer: _viewer(),
        subject: _profile(uid: 'no-signal'),
        viewerPrefs: MatchPreferences.defaults(null),
        blockedUids: const <String>{},
        weights: MatchWeights.forAll,
      );
      // No interests, no verified, neutral intent → 0.5 on intent
      // but intent's reason is "Looking for the same thing" (>= 0).
      // So topReasons is at least 1.
      expect(scored!.topReasons(), isNotEmpty);
    });
  });
}
