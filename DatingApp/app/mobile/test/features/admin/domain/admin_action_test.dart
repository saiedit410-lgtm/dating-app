import 'package:dating_app/features/admin/domain/admin_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AdminAction wire maps known values', () {
    expect(AdminActionType.verificationApprove.wire, 'verification.approve');
    expect(AdminActionType.reportResolve.wire, 'report.resolve');
  });
}
