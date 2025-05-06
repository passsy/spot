import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('existsOnce adds to timeline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
        ),
      ),
    );
    spot<AppBar>().existsOnce();
    final existsOnceEvent = timeline.events.single;
    expect(
      existsOnceEvent.details,
      contains('Found 1 widgets matching AppBar expected only one'),
    );
  });

  testWidgets('existsOnce adds to timeline - error', (tester) async {
    try {
      spot<AppBar>().existsOnce();
    } catch (e) {
      // ignore error
    }
    final existsOnceEvent = timeline.events.single;
    expect(
      existsOnceEvent.details,
      contains('Could not find AppBar in widget tree'),
    );
  });

  group('QuantityMatchers timeline events', () {
    testWidgets('existsAtLeastOnce adds to timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('Text 1'),
              Text('Text 2'),
            ],
          ),
        ),
      );

      spot<Text>().existsAtLeastOnce();

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains(
          'Found 2 widgets matching Text expected at least one',
        ),
      );
    });

    testWidgets('existsAtLeastOnce adds to timeline - error', (tester) async {
      // No Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(child: SizedBox()),
        ),
      );

      try {
        spot<Text>().existsAtLeastOnce();
      } catch (e) {
        // ignore error
      }

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion Failed');
      expect(
        timelineEvent.details,
        contains('Could not find Text in widget tree, expected at least 1'),
      );
    });

    testWidgets('existsAtMostOnce adds to timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Text('Hello'),
        ),
      );

      spot<Text>().existsAtMostOnce();

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains(
          'Found 1 widgets matching Text expected at most one',
        ),
      );
    });

    testWidgets('existsAtMostOnce adds to timeline - error', (tester) async {
      // Multiple Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('Text 1'),
              Text('Text 2'),
            ],
          ),
        ),
      );

      try {
        spot<Text>().existsAtMostOnce();
      } catch (e) {
        // ignore error
      }

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion Failed');
      expect(
          timelineEvent.details,
          contains(
              'Found 2 elements matching Text in widget tree, expected at most 1'));
    });

    testWidgets('doesNotExist adds to timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(child: SizedBox()),
        ),
      );

      spot<Text>().doesNotExist();

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains('Found 0 widgets matching Text expected none.'),
      );
    });

    testWidgets('doesNotExist adds to timeline - error', (tester) async {
      // Text widget exists when it shouldn't
      await tester.pumpWidget(
        const MaterialApp(
          home: Text('Hello'),
        ),
      );

      try {
        spot<Text>().doesNotExist();
      } catch (e) {
        // ignore error
      }

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion Failed');
      expect(
        timelineEvent.details,
        contains(
          'Found 1 elements matching Text in widget tree, expected at most 0.',
        ),
      );
    });

    testWidgets('existsExactlyNTimes adds to timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('Text 1'),
              Text('Text 2'),
            ],
          ),
        ),
      );

      spot<Text>().existsExactlyNTimes(2);

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains('Found 2 widgets matching Text expected exactly 2.'),
      );
    });

    testWidgets('existsExactlyNTimes adds to timeline - error', (tester) async {
      // Wrong number of Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('Text 1'),
              Text('Text 2'),
            ],
          ),
        ),
      );

      try {
        spot<Text>().existsExactlyNTimes(3);
      } catch (e) {
        // ignore error
      }

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion Failed');
      expect(
        timelineEvent.details,
        contains(
          'Found 2 elements matching Text in widget tree, expected exactly 3.',
        ),
      );
    });

    testWidgets('existsAtLeastNTimes adds to timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('Text 1'),
              Text('Text 2'),
              Text('Text 3'),
            ],
          ),
        ),
      );

      spot<Text>().existsAtLeastNTimes(2);

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains(
          'Found 3 widgets matching Text expected at least 2.',
        ),
      );
    });

    testWidgets('existsAtLeastNTimes adds to timeline - error', (tester) async {
      // Too few Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('Text 1'),
            ],
          ),
        ),
      );

      try {
        spot<Text>().existsAtLeastNTimes(2);
      } catch (e) {
        // ignore error
      }

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion Failed');
      expect(
        timelineEvent.details,
        contains(
          'Found 1 elements matching Text in widget tree, expected at least 2.',
        ),
      );
    });

    testWidgets('existsAtMostNTimes adds to timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('Text 1'),
            ],
          ),
        ),
      );

      spot<Text>().existsAtMostNTimes(2);

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains(
          'Found 1 widgets matching Text expected at most 2.',
        ),
      );
    });

    testWidgets('existsAtMostNTimes adds to timeline - error', (tester) async {
      // Too many Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              Text('Text 1'),
              Text('Text 2'),
              Text('Text 3'),
            ],
          ),
        ),
      );

      try {
        spot<Text>().existsAtMostNTimes(2);
      } catch (e) {
        // ignore error
      }

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion Failed');
      expect(
        timelineEvent.details,
        contains(
          'Found 3 elements matching Text in widget tree, expected at most 2.',
        ),
      );
    });

    testWidgets('failure cases add error events to timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(child: SizedBox()),
        ),
      );

      try {
        spot<Text>().existsOnce();
      } catch (e) {
        // ignore error
      }

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion Failed');
      expect(
        timelineEvent.details,
        contains(
          'Could not find Text in widget tree, expected exactly 1.',
        ),
      );
    });
  });
}
