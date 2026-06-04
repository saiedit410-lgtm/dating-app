import 'package:dating_app/features/discovery/domain/discovery_filters.dart';
import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:flutter_test/flutter_test.dart';

PublicProfile _profile({
  Gender? gender = Gender.female,
  List<Gender> interestedIn = const <Gender>[Gender.male],
  int? age = 25,
  String? city = 'Pune',
  String? state = 'Maharashtra',
}) => PublicProfile(
  uid: 'u',
  gender: gender,
  interestedIn: interestedIn,
  age: age,
  city: city,
  state: state,
);

void main() {
  group('DiscoveryFilters.isDefault / serialization', () {
    test('default filters report isDefault', () {
      expect(const DiscoveryFilters().isDefault, isTrue);
    });

    test('round-trips through toMap/fromMap', () {
      const filters = DiscoveryFilters(
        gender: Gender.female,
        interestedIn: <Gender>[Gender.male, Gender.nonBinary],
        minAge: 21,
        maxAge: 40,
        city: 'Pune',
        state: 'MH',
      );
      final restored = DiscoveryFilters.fromMap(filters.toMap());
      expect(restored.gender, Gender.female);
      expect(restored.interestedIn, <Gender>[Gender.male, Gender.nonBinary]);
      expect(restored.minAge, 21);
      expect(restored.maxAge, 40);
      expect(restored.city, 'Pune');
      expect(restored.isDefault, isFalse);
    });
  });

  group('DiscoveryFilters.matches', () {
    test('default filters match everyone', () {
      expect(const DiscoveryFilters().matches(_profile()), isTrue);
    });

    test('gender filter excludes other genders', () {
      const f = DiscoveryFilters(gender: Gender.male);
      expect(f.matches(_profile(gender: Gender.female)), isFalse);
      expect(f.matches(_profile(gender: Gender.male)), isTrue);
    });

    test('interestedIn requires an overlap', () {
      const f = DiscoveryFilters(interestedIn: <Gender>[Gender.female]);
      expect(
        f.matches(_profile(interestedIn: const <Gender>[Gender.male])),
        isFalse,
      );
      expect(
        f.matches(
          _profile(interestedIn: const <Gender>[Gender.male, Gender.female]),
        ),
        isTrue,
      );
    });

    test('age range excludes out-of-range profiles', () {
      const f = DiscoveryFilters(minAge: 30, maxAge: 40);
      expect(f.matches(_profile(age: 25)), isFalse);
      expect(f.matches(_profile(age: 35)), isTrue);
    });

    test('city filter is case-insensitive', () {
      const f = DiscoveryFilters(city: 'pune');
      expect(f.matches(_profile(city: 'Pune')), isTrue);
      expect(f.matches(_profile(city: 'Mumbai')), isFalse);
    });
  });
}
