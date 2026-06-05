import 'package:dating_app/features/verification/domain/verification_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VerificationStatus.fromName', () {
    test('parses known statuses, null otherwise', () {
      expect(VerificationStatus.fromName('pending'), VerificationStatus.pending);
      expect(
        VerificationStatus.fromName('approved'),
        VerificationStatus.approved,
      );
      expect(
        VerificationStatus.fromName('rejected'),
        VerificationStatus.rejected,
      );
      expect(VerificationStatus.fromName('bogus'), isNull);
      expect(VerificationStatus.fromName(null), isNull);
    });
  });

  group('VerificationRequest', () {
    test('fromMap maps fields with a pending fallback', () {
      final request = VerificationRequest.fromMap('uid-1', <String, dynamic>{
        'uid': 'uid-1',
        'status': 'rejected',
        'selfiePhotoUrl': 'http://x/s.jpg',
        'rejectionReason': 'Photo too blurry',
      });
      expect(request.uid, 'uid-1');
      expect(request.status, VerificationStatus.rejected);
      expect(request.selfiePhotoUrl, 'http://x/s.jpg');
      expect(request.rejectionReason, 'Photo too blurry');

      final fallback = VerificationRequest.fromMap('u', <String, dynamic>{});
      expect(fallback.status, VerificationStatus.pending);
      expect(fallback.uid, 'u');
    });

    test('status helpers and canSubmit are correct', () {
      const pending = VerificationRequest(
        uid: 'u',
        status: VerificationStatus.pending,
      );
      expect(pending.isPending, isTrue);
      expect(pending.canSubmit, isFalse);

      const approved = VerificationRequest(
        uid: 'u',
        status: VerificationStatus.approved,
      );
      expect(approved.isApproved, isTrue);
      expect(approved.canSubmit, isFalse);

      const rejected = VerificationRequest(
        uid: 'u',
        status: VerificationStatus.rejected,
      );
      expect(rejected.isRejected, isTrue);
      expect(rejected.canSubmit, isTrue);
    });
  });
}
