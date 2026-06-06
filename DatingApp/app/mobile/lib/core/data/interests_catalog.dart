/// The closed list of interest values Spark recognises.
///
/// Keeping the list closed is deliberate (see design doc §6): an open
/// list lets users type whatever they want, which makes the Jaccard
/// overlap noisy and the index large. New values are added by editing
/// this file — the onboarding UI is auto-derived.
///
/// Display labels are kept here so the UI layer doesn't have to know
/// the canonical lowercase value.
class InterestsCatalog {
  const InterestsCatalog._();

  /// Canonical (lowercase) values accepted by the matcher.
  static const Set<String> values = <String>{
    'travel',
    'music',
    'movies',
    'reading',
    'cooking',
    'fitness',
    'yoga',
    'hiking',
    'running',
    'cycling',
    'sports',
    'gaming',
    'photography',
    'art',
    'dancing',
    'writing',
    'podcasts',
    'coffee',
    'foodie',
    'wine',
    'pets',
    'dogs',
    'cats',
    'plants',
    'outdoors',
    'camping',
    'beach',
    'mountains',
    'city',
    'fashion',
    'tech',
    'science',
    'history',
    'languages',
    'meditation',
    'spirituality',
    'volunteering',
    'entrepreneurship',
    'finance',
    'diy',
    'crafts',
    'board-games',
    'anime',
    'kpop',
    'cricket',
    'football',
    'yoga-meditation',
    'astrology',
    'lgbtq',
    'nightlife',
  };

  /// Friendly display label for a canonical value. Falls back to the
  /// raw value when unrecognised.
  static String labelOf(String value) {
    switch (value) {
      case 'travel':
        return 'Travel';
      case 'music':
        return 'Music';
      case 'movies':
        return 'Movies';
      case 'reading':
        return 'Reading';
      case 'cooking':
        return 'Cooking';
      case 'fitness':
        return 'Fitness';
      case 'yoga':
        return 'Yoga';
      case 'hiking':
        return 'Hiking';
      case 'running':
        return 'Running';
      case 'cycling':
        return 'Cycling';
      case 'sports':
        return 'Sports';
      case 'gaming':
        return 'Gaming';
      case 'photography':
        return 'Photography';
      case 'art':
        return 'Art';
      case 'dancing':
        return 'Dancing';
      case 'writing':
        return 'Writing';
      case 'podcasts':
        return 'Podcasts';
      case 'coffee':
        return 'Coffee';
      case 'foodie':
        return 'Foodie';
      case 'wine':
        return 'Wine';
      case 'pets':
        return 'Pets';
      case 'dogs':
        return 'Dogs';
      case 'cats':
        return 'Cats';
      case 'plants':
        return 'Plants';
      case 'outdoors':
        return 'Outdoors';
      case 'camping':
        return 'Camping';
      case 'beach':
        return 'Beach';
      case 'mountains':
        return 'Mountains';
      case 'city':
        return 'City life';
      case 'fashion':
        return 'Fashion';
      case 'tech':
        return 'Tech';
      case 'science':
        return 'Science';
      case 'history':
        return 'History';
      case 'languages':
        return 'Languages';
      case 'meditation':
        return 'Meditation';
      case 'spirituality':
        return 'Spirituality';
      case 'volunteering':
        return 'Volunteering';
      case 'entrepreneurship':
        return 'Entrepreneurship';
      case 'finance':
        return 'Finance';
      case 'diy':
        return 'DIY';
      case 'crafts':
        return 'Crafts';
      case 'board-games':
        return 'Board games';
      case 'anime':
        return 'Anime';
      case 'kpop':
        return 'K-pop';
      case 'cricket':
        return 'Cricket';
      case 'football':
        return 'Football';
      case 'yoga-meditation':
        return 'Yoga & meditation';
      case 'astrology':
        return 'Astrology';
      case 'lgbtq':
        return 'LGBTQ+';
      case 'nightlife':
        return 'Nightlife';
    }
    return value;
  }

  /// True when [value] is in the closed catalog.
  static bool contains(String value) => values.contains(value.toLowerCase());

  /// Returns [values] as a sorted list (for stable UI rendering).
  static List<String> get sorted => (values.toList()..sort());
}
