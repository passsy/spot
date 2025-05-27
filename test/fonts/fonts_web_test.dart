import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('loadAppFonts prints warning when on web', (tester) async {
    final log = <String>[];
    await runZoned(
      () async {
        await loadAppFonts();
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, message) {
          log.add(message);
        },
      ),
    );
    final text = log.join('\n');
    final containsWarning =
        text.contains('⚠️ - loadAppFonts is not supported on the web!');
    expect(containsWarning, kIsWeb ? isTrue : isFalse);
  });

  testWidgets('loadFont prints warning when on web', skip: !kIsWeb,
      (tester) async {
    final log = <String>[];
    await runZoned(
      () async {
        await loadFont('Example', []);
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, message) {
          log.add(message);
        },
      ),
    );
    final text = log.join('\n');
    final containsWarning =
        text.contains('⚠️ - loadFont is not supported on the web!');
    expect(containsWarning, kIsWeb ? isTrue : isFalse);
  });
}
