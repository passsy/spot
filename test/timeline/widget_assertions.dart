import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/timeline/html/components/timeline_app.dart';

void main() {
  testWidgets('multiple assertions in the same frame share one capture', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: Text('same frame')));

    spot<Text>().existsOnce();
    spot<Text>().existsOnce();

    expect(timeline.events, hasLength(2));
    expect(timeline.events.map((event) => event.frameNumber), [1, 1]);
  });

  testWidgets('existsOnce adds to timeline', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(appBar: AppBar())));
    spot<AppBar>().existsOnce();
    final existsOnceEvent = timeline.events.single;
    expect(existsOnceEvent.details, contains('AppBar exists once.'));
    expect(existsOnceEvent.widgetTree, contains('AppBar'));
    expect(existsOnceEvent.structuredWidgetTree.toString(), contains('AppBar'));
    expect(
      existsOnceEvent.structuredWidgetTree.toString(),
      contains('bounds: {'),
    );
    final appBar = _findStructuredNode(
      existsOnceEvent.structuredWidgetTree['root'] as Map<String, dynamic>,
      'AppBar',
    );
    final root =
        existsOnceEvent.structuredWidgetTree['root'] as Map<String, dynamic>;
    final appBarNode = appBar!;
    expect(appBarNode['isUserCode'], isTrue);
    final searchResult = searchStructuredWidgetTree(root, 'appbar');
    expect(searchResult.matches, contains(appBarNode['id']));
    expect(searchResult.visible, contains(root['id']));
    expect(collectStructuredWidgetNodeIds(root).length, greaterThan(100));
    final bounds = appBarNode['bounds'] as Map<String, dynamic>;
    expect(
      bounds['width'] as num,
      lessThanOrEqualTo(
        existsOnceEvent.structuredWidgetTree['captureWidth'] as num,
      ),
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
          home: Column(children: [Text('Text 1'), Text('Text 2')]),
        ),
      );

      spot<Text>().existsAtLeastOnce();

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains('Text exists at least once, found 2.'),
      );
    });

    testWidgets('existsAtLeastOnce adds to timeline - error', (tester) async {
      // No Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(home: Center(child: SizedBox())),
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
      await tester.pumpWidget(const MaterialApp(home: Text('Hello')));

      spot<Text>().existsAtMostOnce();

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains('Text exists at most once, found 1.'),
      );
    });

    testWidgets('existsAtMostOnce adds to timeline - error', (tester) async {
      // Multiple Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(children: [Text('Text 1'), Text('Text 2')]),
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
          'Found 2 elements matching Text in widget tree, expected at most 1',
        ),
      );
    });

    testWidgets('doesNotExist adds to timeline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Center(child: SizedBox())),
      );

      spot<Text>().doesNotExist();

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(timelineEvent.details, contains('Text does not exist.'));
    });

    testWidgets('doesNotExist adds to timeline - error', (tester) async {
      // Text widget exists when it shouldn't
      await tester.pumpWidget(const MaterialApp(home: Text('Hello')));

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
          home: Column(children: [Text('Text 1'), Text('Text 2')]),
        ),
      );

      spot<Text>().existsExactlyNTimes(2);

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains('Text exists exactly 2 times, found 2.'),
      );
    });

    testWidgets('existsExactlyNTimes adds to timeline - error', (tester) async {
      // Wrong number of Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(children: [Text('Text 1'), Text('Text 2')]),
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
            children: [Text('Text 1'), Text('Text 2'), Text('Text 3')],
          ),
        ),
      );

      spot<Text>().existsAtLeastNTimes(2);

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains('Text exists at least 2 times, found 3.'),
      );
    });

    testWidgets('existsAtLeastNTimes adds to timeline - error', (tester) async {
      // Too few Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(home: Column(children: [Text('Text 1')])),
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
        const MaterialApp(home: Column(children: [Text('Text 1')])),
      );

      spot<Text>().existsAtMostNTimes(2);

      final timelineEvent = timeline.events.single;
      expect(timelineEvent.eventType.label, 'Assertion');
      expect(
        timelineEvent.details,
        contains('Text exists at most 2 times, found 1.'),
      );
    });

    testWidgets('existsAtMostNTimes adds to timeline - error', (tester) async {
      // Too many Text widgets in the tree
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [Text('Text 1'), Text('Text 2'), Text('Text 3')],
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
        const MaterialApp(home: Center(child: SizedBox())),
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
        contains('Could not find Text in widget tree, expected exactly 1.'),
      );
    });
  });
}

Map<String, dynamic>? _findStructuredNode(
  Map<String, dynamic> node,
  String name,
) {
  if (node['name'] == name) {
    return node;
  }
  for (final child in node['children'] as List<dynamic>) {
    final match = _findStructuredNode(child as Map<String, dynamic>, name);
    if (match != null) {
      return match;
    }
  }
  return null;
}
