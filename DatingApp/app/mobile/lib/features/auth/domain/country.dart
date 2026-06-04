/// A selectable country dial code for the phone-login screen.
class Country {
  const Country({required this.name, required this.dialCode, required this.flag});

  final String name;
  final String dialCode;
  final String flag;

  @override
  bool operator ==(Object other) =>
      other is Country && other.name == name && other.dialCode == dialCode;

  @override
  int get hashCode => Object.hash(name, dialCode);
}

/// Curated list of supported dial codes (India-first). Expanded as we launch in
/// more markets. Distinct [Country] objects are used as dropdown values so
/// shared dial codes (e.g. US/Canada +1) remain selectable.
const List<Country> kSupportedCountries = <Country>[
  Country(name: 'India', dialCode: '+91', flag: '🇮🇳'),
  Country(name: 'United States', dialCode: '+1', flag: '🇺🇸'),
  Country(name: 'United Kingdom', dialCode: '+44', flag: '🇬🇧'),
  Country(name: 'United Arab Emirates', dialCode: '+971', flag: '🇦🇪'),
  Country(name: 'Singapore', dialCode: '+65', flag: '🇸🇬'),
  Country(name: 'Australia', dialCode: '+61', flag: '🇦🇺'),
  Country(name: 'Canada', dialCode: '+1', flag: '🇨🇦'),
];

/// Default selection (India). Mirrors the first entry of [kSupportedCountries].
const Country kDefaultCountry =
    Country(name: 'India', dialCode: '+91', flag: '🇮🇳');
