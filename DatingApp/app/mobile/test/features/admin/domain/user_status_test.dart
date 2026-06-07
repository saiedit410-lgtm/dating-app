import 'package:dating_app/features/admin/domain/user_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('UserStatus fromName resolves and defaults', () {
    expect(UserStatus.fromName('active'), UserStatus.active);
    expect(UserStatus.fromName('oops'), UserStatus.unknown);
  });
}
