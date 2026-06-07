import 'package:dating_app/features/admin/application/admin_queue_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AdminQueueState copyWith updates state', () {
    const state = AdminQueueState();
    final next = state.copyWith(isBusy: true, message: 'ok');
    expect(next.isBusy, isTrue);
    expect(next.message, 'ok');
  });
}
