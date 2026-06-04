/// A minimal, framework-agnostic representation of the signed-in user.
///
/// Maps from `firebase_auth`'s `User` in the data layer so the rest of the app
/// never depends on the Firebase type directly.
class AuthUser {
  const AuthUser({required this.uid, required this.phoneNumber});

  final String uid;
  final String? phoneNumber;

  @override
  bool operator ==(Object other) =>
      other is AuthUser &&
      other.uid == uid &&
      other.phoneNumber == phoneNumber;

  @override
  int get hashCode => Object.hash(uid, phoneNumber);
}
