import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot_annotator.dart';

void main() {
  // Timeline report rendering is skipped on web.
  testWidgets('report font update completes without settling a leaked ticker',
      skip: kIsWeb, (tester) async {
    var fontChanges = 0;
    void onFontsChanged() => fontChanges++;
    tester.binding.systemFonts.addListener(onFontsChanged);
    final ticker = Ticker((_) {});

    // Registered before the timeline so these assertions run after its report
    // has rendered, but before Flutter's postTest invariant checks.
    addTearDown(() {
      try {
        expect(fontChanges, 1);
        expect(ticker.isActive, isTrue);
        // Only the deliberate ticker remains; the font callback is finished.
        expect(tester.binding.transientCallbackCount, 1);
      } finally {
        ticker.dispose();
        tester.binding.systemFonts.removeListener(onFontsChanged);
      }
    });

    timeline.mode = TimelineMode.always;
    // Start after Flutter's final test pump, before the timeline is rendered.
    addTearDown(() {
      ticker.start();
    });
    await tester.pumpWidget(const MaterialApp(home: Text('First report')));
    spot<Text>().existsOnce();
  });

  testWidgets('later reports reuse the font across widget test zones',
      skip: kIsWeb, (tester) async {
    var fontChanges = 0;
    void onFontsChanged() => fontChanges++;
    tester.binding.systemFonts.addListener(onFontsChanged);
    addTearDown(() {
      try {
        expect(fontChanges, 0);
        expect(tester.binding.transientCallbackCount, 0);
      } finally {
        tester.binding.systemFonts.removeListener(onFontsChanged);
      }
    });

    timeline.mode = TimelineMode.always;
    await tester.pumpWidget(const MaterialApp(home: Text('Second report')));
    // Warm the font in this test too, so this case also works when run alone.
    await takeScreenshot(
      annotators: [
        HighlightAnnotator.rects(
          [const Rect.fromLTWH(0, 0, 100, 20)],
          labels: ['warm font'],
        ),
      ],
    );
    await tester.pump();
    fontChanges = 0;
    spot<Text>().existsOnce();
  });
}
