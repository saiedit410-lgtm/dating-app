import 'package:dating_app/features/profile/domain/profile_enums.dart';
import 'package:dating_app/features/profile/domain/user_profile.dart';

/// The signed-in user's discovery preferences.
///
/// Persisted at `users/{uid}/private/matchPrefs` (owner + admin only
/// via rules — see `backend/firestore/firestore.rules`). When the
/// document is missing, [defaults] returns a permissive baseline
/// derived from the existing profile.
class MatchPreferences {
  const MatchPreferences({
    required this.otherAgeMin,
    required this.otherAgeMax,
    required this.requiredGenders,
    required this.requireIntentMatch,
    required this.intentMatrixFloor,
  });

  /// Minimum age of the people I want to see.
  final int otherAgeMin;

  /// Maximum age of the people I want to see.
  final int otherAgeMax;

  /// If non-empty, the subject's gender MUST be in this list.
  /// Empty means "open to all".
  final List<Gender> requiredGenders;

  /// If true, [DatingIntent] compatibility is treated as a hard
  /// filter using [intentMatrixFloor] as the cell-value threshold.
  final bool requireIntentMatch;

  /// Cells in the intent compatibility matrix below this value are
  /// considered incompatible (default 0.4 = "longTerm × casual"
  /// is allowed, "longTerm × friendship" is not). Only consulted
  /// when [requireIntentMatch] is true.
  final double intentMatrixFloor;

  /// Permissive baseline. Uses [UserProfile.interestedIn] as the
  /// required-gender default when available; otherwise "open to
  /// all".
  factory MatchPreferences.defaults(UserProfile? profile) {
    return MatchPreferences(
      otherAgeMin: 18,
      otherAgeMax: 99,
      requiredGenders: profile?.interestedIn ?? const <Gender>[],
      requireIntentMatch: false,
      intentMatrixFloor: 0.4,
    );
  }

  factory MatchPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MatchPreferences.defaults(null);
    final List<Gender> required = ((map['requiredGenders'] as List<dynamic>?) ??
            const <dynamic>[])
        .map((Object? e) => Gender.fromName(e as String?))
        .whereType<Gender>()
        .toList();
    return MatchPreferences(
      otherAgeMin: (map['otherAgeMin'] as num?)?.toInt() ?? 18,
      otherAgeMax: (map['otherAgeMax'] as num?)?.toInt() ?? 99,
      requiredGenders: required,
      requireIntentMatch: map['requireIntentMatch'] as bool? ?? false,
      intentMatrixFloor: (map['intentMatrixFloor'] as num?)?.toDouble() ?? 0.4,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'otherAgeMin': otherAgeMin,
    'otherAgeMax': otherAgeMax,
    'requiredGenders': requiredGenders.map((Gender g) => g.name).toList(),
    'requireIntentMatch': requireIntentMatch,
    'intentMatrixFloor': intentMatrixFloor,
  };

  MatchPreferences copyWith({
    int? otherAgeMin,
    int? otherAgeMax,
    List<Gender>? requiredGenders,
    bool? requireIntentMatch,
    double? intentMatrixFloor,
  }) {
    return MatchPreferences(
      otherAgeMin: otherAgeMin ?? this.otherAgeMin,
      otherAgeMax: otherAgeMax ?? this.otherAgeMax,
      requiredGenders: requiredGenders ?? this.requiredGenders,
      requireIntentMatch: requireIntentMatch ?? this.requireIntentMatch,
      intentMatrixFloor: intentMatrixFloor ?? this.intentMatrixFloor,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MatchPreferences &&
      other.otherAgeMin == otherAgeMin &&
      other.otherAgeMax == otherAgeMax &&
      _listEq(other.requiredGenders, requiredGenders) &&
      other.requireIntentMatch == requireIntentMatch &&
      other.intentMatrixFloor == intentMatrixFloor;

  @override
  int get hashCode => Object.hash(
        otherAgeMin,
        otherAgeMax,
        Object.hashAll(requiredGenders),
        requireIntentMatch,
        intentMatrixFloor,
      );

  static bool _listEq(List<Gender> a, List<Gender> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
