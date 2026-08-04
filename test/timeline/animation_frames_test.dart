import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

/// A panel that takes 900ms to open, which is 54 frames at 60fps.
class Expander extends StatefulWidget {
  const Expander({super.key});

  @override
  State<Expander> createState() => ExpanderState();
}

class ExpanderState extends State<Expander>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void expand() => controller.forward();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Opacity(
                opacity: controller.value,
                child: Text(controller.value == 1 ? 'expanded' : 'collapsed'),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('pumpAndSettle renders a frame per step of the animation', (
    tester,
  ) async {
    timeline.mode = TimelineMode.always;
    final key = GlobalKey<ExpanderState>();

    await tester.pumpWidget(Expander(key: key));
    spotText('collapsed').existsOnce();

    key.currentState!.expand();
    // The default step is 100ms, so a 900ms animation is walked in 9 steps
    // rather than the 54 frames it would take on a device.
    await tester.pumpAndSettle();

    spotText('expanded').existsOnce();

    expect(timeline.renderedFrameCount, inInclusiveRange(10, 14));
  });

  testWidgets('a 16ms step renders every frame the animation would show', (
    tester,
  ) async {
    timeline.mode = TimelineMode.always;
    final key = GlobalKey<ExpanderState>();

    await tester.pumpWidget(Expander(key: key));
    spotText('collapsed').existsOnce();

    key.currentState!.expand();
    await tester.pumpAndSettle(const Duration(milliseconds: 16));

    spotText('expanded').existsOnce();

    // Every one of them laid out and painted, and only the last looked at.
    expect(timeline.renderedFrameCount, greaterThan(50));
  });

  testWidgets('jumping to the end of the animation renders a few frames', (
    tester,
  ) async {
    timeline.mode = TimelineMode.always;
    final key = GlobalKey<ExpanderState>();

    await tester.pumpWidget(Expander(key: key));
    spotText('collapsed').existsOnce();

    key.currentState!.expand();
    // The same end state, without drawing what happens on the way there. The
    // first pump starts the ticker, the second jumps it to the end.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    spotText('expanded').existsOnce();

    expect(timeline.renderedFrameCount, lessThan(6));
  });
}
