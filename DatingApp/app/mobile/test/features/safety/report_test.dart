import 'package:dating_app/features/safety/domain/report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReportCategory', () {
    test('exposes the required categories with labels', () {
      expect(ReportCategory.values.length, 5);
      expect(ReportCategory.spam.label, 'Spam');
      expect(ReportCategory.fakeProfile.label, 'Fake profile');
      expect(ReportCategory.harassment.label, 'Harassment');
      expect(ReportCategory.inappropriateContent.label, 'Inappropriate content');
      expect(ReportCategory.other.label, 'Other');
    });

    test('fromName round-trips and rejects unknown', () {
      expect(ReportCategory.fromName('harassment'), ReportCategory.harassment);
      expect(ReportCategory.fromName('nope'), isNull);
      expect(ReportCategory.fromName(null), isNull);
    });
  });

  group('ReportStatus.fromName', () {
    test('parses known names, null otherwise', () {
      expect(ReportStatus.fromName('open'), ReportStatus.open);
      expect(ReportStatus.fromName('dismissed'), ReportStatus.dismissed);
      expect(ReportStatus.fromName('bogus'), isNull);
    });
  });

  group('Report.fromMap', () {
    test('maps fields with safe fallbacks', () {
      final report = Report.fromMap('r1', <String, dynamic>{
        'reporterUid': 'a',
        'reportedUid': 'b',
        'category': 'spam',
        'description': 'bot account',
        'status': 'open',
      });
      expect(report.reporterUid, 'a');
      expect(report.reportedUid, 'b');
      expect(report.category, ReportCategory.spam);
      expect(report.status, ReportStatus.open);

      final fallback = Report.fromMap('r2', <String, dynamic>{});
      expect(fallback.category, ReportCategory.other);
      expect(fallback.status, ReportStatus.open);
    });
  });
}
