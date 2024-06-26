import 'package:flutter_test/flutter_test.dart';
import '../timeline_tap_test_bodies.dart' as body;

void main() {
  group('Override global timeline', () {
    testWidgets('Local: live, without error', (tester) async {
      await body.liveWithoutError(tester: tester);
    });
    testWidgets('Local: off, without error', (tester) async {
      await body.offWithoutError(tester: tester);
    });
    testWidgets('Local: live, turn off during test', (tester) async {
      await body.liveTurnOffDuringTest(tester: tester);
    });
  });

  group('Print on teardown', () {
    testWidgets('Local: record, without error', (tester) async {
      await body.recordWithoutError(tester: tester);
    });

    test('Local: record, with error', () async {
      await body.recordWithError();
    });
    test('Local: live - without error, prints HTML', () async {
      await body.liveWithoutErrorPrintsHtml();
    });
    test('Local: live - with error, no duplicates, prints HTML', () async {
      await body.liveWithErrorNoDuplicatesPrintsHtml();
    });
  });
}
