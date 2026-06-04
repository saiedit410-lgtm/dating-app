/// Gender options for a profile and for "interested in" preferences.
enum Gender {
  male,
  female,
  nonBinary,
  other;

  String get label => switch (this) {
    Gender.male => 'Man',
    Gender.female => 'Woman',
    Gender.nonBinary => 'Non-binary',
    Gender.other => 'Other',
  };

  static Gender? fromName(String? name) {
    for (final Gender g in Gender.values) {
      if (g.name == name) return g;
    }
    return null;
  }
}

/// What the user is looking for (Step 2 — Dating Intent).
enum DatingIntent {
  longTerm,
  casual,
  friendship,
  notSure;

  String get label => switch (this) {
    DatingIntent.longTerm => 'Long-term relationship',
    DatingIntent.casual => 'Something casual',
    DatingIntent.friendship => 'New friends',
    DatingIntent.notSure => 'Still figuring it out',
  };

  static DatingIntent? fromName(String? name) {
    for (final DatingIntent i in DatingIntent.values) {
      if (i.name == name) return i;
    }
    return null;
  }
}
