/// The four states `users/{uid}.accountStatus` can take. `active`,
/// `suspended`, and `banned` are the values the Cloud Function
/// `setUserStatus` writes; `unknown` covers any future / unrecognised
/// value surfaced by the client read path.
enum UserStatus {
  active,
  suspended,
  banned,
  unknown;

  static UserStatus fromName(String? name) {
    switch (name) {
      case 'active':
        return UserStatus.active;
      case 'suspended':
        return UserStatus.suspended;
      case 'banned':
        return UserStatus.banned;
    }
    return UserStatus.unknown;
  }

  /// User-facing copy for the user-detail screen.
  String get label {
    switch (this) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.banned:
        return 'Banned';
      case UserStatus.unknown:
        return 'Unknown';
    }
  }
}
