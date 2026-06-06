import 'package:dating_app/features/matching/domain/intent_compatibility.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('intentCompatibility', () {
    test('identical intents return 1.0', () {
      for (final DatingIntent i in DatingIntent.values) {
        expect(intentCompatibility(i, i), 1.0, reason: 'for $i');
      }
    });

    test('notSure is moderately compatible with anything other than notSure', () {
      // notSure vs notSure hits the `a == b` branch (1.0).
      expect(intentCompatibility(DatingIntent.notSure, DatingIntent.notSure),
          1.0);
      for (final DatingIntent i in DatingIntent.values) {
        if (i == DatingIntent.notSure) continue;
        expect(intentCompatibility(DatingIntent.notSure, i), 0.6,
            reason: 'viewer notSure vs $i');
        expect(intentCompatibility(i, DatingIntent.notSure), 0.6,
            reason: '$i vs subject notSure');
      }
    });

    test('longTerm vs casual is at the 0.4 floor', () {
      expect(
        intentCompatibility(DatingIntent.longTerm, DatingIntent.casual),
        0.4,
      );
      expect(
        intentCompatibility(DatingIntent.casual, DatingIntent.longTerm),
        0.4,
      );
    });

    test('longTerm vs friendship is the lowest pair (0.2)', () {
      expect(
        intentCompatibility(DatingIntent.longTerm, DatingIntent.friendship),
        0.2,
      );
      expect(
        intentCompatibility(DatingIntent.friendship, DatingIntent.longTerm),
        0.2,
      );
    });

    test('casual vs friendship is moderate (0.5)', () {
      expect(
        intentCompatibility(DatingIntent.casual, DatingIntent.friendship),
        0.5,
      );
      expect(
        intentCompatibility(DatingIntent.friendship, DatingIntent.casual),
        0.5,
      );
    });

    test('matrix is symmetric', () {
      for (final DatingIntent a in DatingIntent.values) {
        for (final DatingIntent b in DatingIntent.values) {
          expect(
            intentCompatibility(a, b),
            intentCompatibility(b, a),
            reason: 'asymmetry for $a vs $b',
          );
        }
      }
    });
  });
}
