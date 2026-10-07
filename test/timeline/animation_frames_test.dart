import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

/// How long the panel takes to open.
///
/// The tests derive what they expect from this, so it can be changed without
/// rewriting numbers by hand.
const animationDuration = Duration(milliseconds: 3000);

/// The frames a `pumpAndSettle` of [step] draws to get through the animation.
///
/// One per step, plus a little room for the frame that starts the animation
/// and the one that settles it.
Matcher framesForStep(Duration step) {
  final steps = animationDuration.inMicroseconds / step.inMicroseconds;
  return inInclusiveRange(steps.floor(), steps.ceil() + 3);
}

/// A panel that fades in over [animationDuration].
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
    controller = AnimationController(vsync: this, duration: animationDuration);
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
    // The default step is 100ms, far coarser than the 16ms a device draws at,
    // so the animation is walked in a fraction of the frames it really has.
    await tester.pumpAndSettle();

    spotText('expanded').existsOnce();

    expect(
      timeline.renderedFrameCount,
      framesForStep(const Duration(milliseconds: 100)),
    );
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
    expect(
      timeline.renderedFrameCount,
      framesForStep(const Duration(milliseconds: 16)),
    );
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
    await tester.pump(animationDuration);

    spotText('expanded').existsOnce();

    expect(timeline.renderedFrameCount, lessThan(6));
  });
}
