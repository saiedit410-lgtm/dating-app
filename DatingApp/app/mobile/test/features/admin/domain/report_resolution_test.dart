import 'package:dating_app/features/admin/domain/report_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReportResolution fromName resolves values', () {
    expect(ReportResolution.fromName('warn'), ReportResolution.warn);
    expect(ReportResolution.fromName('missing'), isNull);
  });
}
