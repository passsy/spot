import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/timeline.dart';

import '../spot/screenshot_test.dart';

void main() {
  testWidgets('Live timeline with added screenshot event', (tester) async {
    final Timeline timeLine = liveTimeline();
    tester.view.physicalSize = const Size(210, 210);
    tester.view.devicePixelRatio = 1.0;
    int i = 0;
    await tester.pumpWidget(
      _TimelineTestWidget(
        onTap: () {
          i++;
        },
      ),
    );

    final button = spotIcon(Icons.home)..existsOnce();
    await act.tap(button);
    expect(i, 1);
    final shot = timeLine.events.first.screenshot!;
    expect(shot.file.existsSync(), isTrue);

    final cyanPixelCoverage =
        await percentageOfPixelsWithColor(shot.file, const Color(0xFF00FFFF));
    expect(cyanPixelCoverage, greaterThan(0.0));
  });

  testWidgets('Cease recording live timeline after first tap', (tester) async {
    final Timeline timeline = liveTimeline();
    tester.view.physicalSize = const Size(210, 210);
    tester.view.devicePixelRatio = 1.0;
    int i = 0;
    await tester.pumpWidget(
      _TimelineTestWidget(
        onTap: () {
          i++;
        },
      ),
    );

    final button = spotIcon(Icons.home)..existsOnce();
    await act.tap(button);
    expect(i, 1);
    expect(timeline.events.length, 1);
    await act.tap(button);
    expect(i, 2);
    expect(timeline.events.length, 2);
    timeline.stopTimeLine();
    await act.tap(button);
    expect(i, 3);
    expect(timeline.events.length, 2);
  });
}

class _TimelineTestWidget extends StatelessWidget {
  const _TimelineTestWidget({
    required this.onTap,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: onTap,
              ),
            ],
          ),
          body: Center(
            child: Container(
              height: 200,
              width: 200,
              color: Colors.red,
            ),
          ),
        );
      },
    );
  }
}
