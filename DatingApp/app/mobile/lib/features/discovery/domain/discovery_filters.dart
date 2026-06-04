import 'package:dating_app/features/discovery/domain/public_profile.dart';
import 'package:dating_app/features/profile/domain/profile_enums.dart';

/// User-controlled discovery filters. Age range is applied server-side; the
/// rest are applied client-side over each fetched page (see DiscoveryController).
class DiscoveryFilters {
  const DiscoveryFilters({
    this.gender,
    this.interestedIn = const <Gender>[],
    this.minAge = minSupportedAge,
    this.maxAge = maxSupportedAge,
    this.city,
    this.state,
  });

  factory DiscoveryFilters.fromMap(Map<String, dynamic> map) {
    return DiscoveryFilters(
      gender: Gender.fromName(map['gender'] as String?),
      interestedIn: ((map['interestedIn'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => Gender.fromName(e as String?))
          .whereType<Gender>()
          .toList(),
      minAge: (map['minAge'] as num?)?.toInt() ?? minSupportedAge,
      maxAge: (map['maxAge'] as num?)?.toInt() ?? maxSupportedAge,
      city: map['city'] as String?,
      state: map['state'] as String?,
    );
  }

  static const int minSupportedAge = 18;
  static const int maxSupportedAge = 100;

  final Gender? gender;
  final List<Gender> interestedIn;
  final int minAge;
  final int maxAge;
  final String? city;
  final String? state;

  bool get isDefault =>
      gender == null &&
      interestedIn.isEmpty &&
      minAge == minSupportedAge &&
      maxAge == maxSupportedAge &&
      (city == null || city!.trim().isEmpty) &&
      (state == null || state!.trim().isEmpty);

  DiscoveryFilters copyWith({
    Gender? gender,
    List<Gender>? interestedIn,
    int? minAge,
    int? maxAge,
    String? city,
    String? state,
    bool clearGender = false,
    bool clearCity = false,
    bool clearState = false,
  }) {
    return DiscoveryFilters(
      gender: clearGender ? null : (gender ?? this.gender),
      interestedIn: interestedIn ?? this.interestedIn,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      city: clearCity ? null : (city ?? this.city),
      state: clearState ? null : (state ?? this.state),
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'gender': gender?.name,
    'interestedIn': interestedIn.map((Gender g) => g.name).toList(),
    'minAge': minAge,
    'maxAge': maxAge,
    'city': city,
    'state': state,
  };

  /// Client-side predicate for the filters not applied by the Firestore query.
  bool matches(PublicProfile profile) {
    if (gender != null && profile.gender != gender) return false;
    if (interestedIn.isNotEmpty &&
        !profile.interestedIn.any(interestedIn.contains)) {
      return false;
    }
    final int? age = profile.age;
    if (age != null && (age < minAge || age > maxAge)) return false;
    if (_isSet(city) && !_eq(profile.city, city)) return false;
    if (_isSet(state) && !_eq(profile.state, state)) return false;
    return true;
  }

  static bool _isSet(String? value) => value != null && value.trim().isNotEmpty;

  static bool _eq(String? a, String? b) =>
      (a ?? '').trim().toLowerCase() == (b ?? '').trim().toLowerCase();
}
