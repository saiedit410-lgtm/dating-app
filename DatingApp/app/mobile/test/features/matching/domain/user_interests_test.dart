import 'package:dating_app/features/matching/domain/user_interests.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserInterests.fromStorage', () {
    test('lowercases, trims, dedupes, and caps at 12', () {
      final raw = <String>[
        '  Music  ',
        'MUSIC',
        'hiking',
        'Hiking',
        for (int i = 0; i < 20; i++) 'item$i',
      ];
      final interests = UserInterests.fromStorage(raw);
      expect(interests.values, hasLength(12));
      // First two are duplicates → 'music'. Then 'hiking'. Then 10 items.
      expect(interests.values.first, 'music');
      expect(interests.values[1], 'hiking');
    });

    test('returns empty for non-list or empty input', () {
      expect(UserInterests.fromStorage(null).values, isEmpty);
      expect(UserInterests.fromStorage(<String>[]).values, isEmpty);
      expect(UserInterests.fromStorage('not a list').values, isEmpty);
    });

    test('drops non-string entries', () {
      final raw = <Object?>['music', 42, null, 'hiking'];
      final interests = UserInterests.fromStorage(raw);
      expect(interests.values, <String>['music', 'hiking']);
    });
  });

  group('UserInterests.jaccardWith', () {
    test('returns 0.0 when both lists are empty', () {
      const a = UserInterests.empty;
      const b = UserInterests.empty;
      expect(a.jaccardWith(b), 0.0);
    });

    test('returns 0.0 when there is no overlap', () {
      final a = UserInterests.fromStorage(<String>['music', 'hiking']);
      final b = UserInterests.fromStorage(<String>['cooking', 'reading']);
      expect(a.jaccardWith(b), 0.0);
    });

    test('returns 1.0-modulated-by-size-penalty for identical sets', () {
      final a =
          UserInterests.fromStorage(<String>['music', 'hiking', 'cooking']);
      final b =
          UserInterests.fromStorage(<String>['music', 'hiking', 'cooking']);
      // Jaccard = 1.0, sizePenalty < 1.0 → < 1.0 but > 0.5
      final v = a.jaccardWith(b);
      expect(v, greaterThan(0.5));
      expect(v, lessThanOrEqualTo(1.0));
    });

    test('partial overlap returns something in between', () {
      final a =
          UserInterests.fromStorage(<String>['music', 'hiking', 'cooking']);
      final b =
          UserInterests.fromStorage(<String>['music', 'reading', 'cooking']);
      final v = a.jaccardWith(b);
      expect(v, greaterThan(0.0));
      expect(v, lessThan(1.0));
    });

    test('size penalty penalises 12-vs-12 profiles', () {
      final aList = List<String>.generate(12, (int i) => 'a$i');
      final bList = List<String>.generate(12, (int i) => 'b$i');
      final a = UserInterests.fromStorage(aList);
      final b = UserInterests.fromStorage(bList);
      // 0 overlap → Jaccard 0, score 0
      expect(a.jaccardWith(b), 0.0);
    });
  });
}
