// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('Add event', (_) async {
    final id = timeline.addEvent(
      details: 'details',
      eventType: 'type 1',
      color: Colors.indigo,
    );
    final latestEvent = timeline.events.last;
    expect(latestEvent.details, 'details');
    expect(latestEvent.eventType.label, 'type 1');
    expect(latestEvent.eventType.color, Colors.indigo);
    expect(latestEvent.id, id);
  });

  testWidgets('Remove event', (_) async {
    final id = timeline.addEvent(
      details: 'details',
      eventType: 'type 1',
    );
    expect(timeline.events, hasLength(1));

    timeline.removeEvent(id);
    expect(timeline.events, isEmpty);
  });

  testWidgets('Remove unknown event', (_) async {
    expect(
      () => timeline.removeEvent(const TimelineEventId('a')),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains("Event with id 'a' not found"),
        ),
      ),
    );
  });

  testWidgets('Update event', (_) async {
    final id = timeline.addEvent(
      details: 'a',
      eventType: 'type 1',
      color: Colors.yellow,
    );
    final a = timeline.events.first;
    expect(a.id, id);
    expect(a.details, 'a');
    expect(a.eventType.label, 'type 1');
    expect(a.eventType.color, Colors.yellow);

    timeline.updateEvent(
      id: id,
      details: 'b',
      eventType: 'type 2',
      description: 'asc',
      color: Colors.red,
    );
    final b = timeline.events.first;
    expect(b.id, id);
    expect(b.details, 'b');
    expect(b.eventType.label, 'type 2');
    expect(b.eventType.color, Colors.red);
    expect(timeline.events, hasLength(1));
  });

  testWidgets('Update unknown event', (_) async {
    expect(
      () => timeline.updateEvent(id: const TimelineEventId('a')),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains("Event with id 'a' not found"),
        ),
      ),
    );
  });

  test('TimelineEventId.toString()', () {
    expect(TimelineEventId('a').toString(), 'a');
  });
  test('TimelineEventId.equals', () {
    expect(TimelineEventId('a'), TimelineEventId('a'));
    expect(TimelineEventId('a'), isNot(TimelineEventId('b')));
  });
}
