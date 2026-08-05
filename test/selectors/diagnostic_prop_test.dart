// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  group('diagnostic prop', () {
    testWidgets('getDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      final maxLines =
          spot<Text>().existsOnce().getDiagnosticProp<int>('maxLines');
      expect(maxLines, 4);
    });

    testWidgets('generated getDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      final maxLines2 = spot<Text>().existsOnce().getMaxLines();
      expect(maxLines2, 4);
    });

    testWidgets('hasDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      spot<Text>()
          .existsOnce()
          .hasDiagnosticProp<int>('maxLines', (it) => it.equals(4));

      expect(
        () => spot<Text>()
            .existsOnce()
            .hasDiagnosticProp<int>('maxLines', (it) => it.equals(2)),
        throwsSpotErrorContaining([
          'Text with property maxLines',
          'equals <2>, actual: <4>',
        ]),
      );
    });

    testWidgets('generated hasDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      spot<Text>()
          .existsOnce()
          .hasMaxLines(4)
          .hasMaxLinesWhere((it) => it.equals(4));

      expect(
        () => spot<Text>().existsOnce().hasMaxLines(2),
        throwsSpotErrorContaining([
          'Text with property maxLines',
          'equals <2>, actual: <4>',
        ]),
      );
    });

    testWidgets('withDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      spot<Text>()
          .withDiagnosticProp<int>('maxLines', (it) => it.equals(4))
          .existsOnce();

      expect(
        () => spot<Text>()
            .withDiagnosticProp<int>('maxLines', (it) => it.equals(2))
            .existsOnce(),
        throwsSpotErrorContaining([
          'Could not find Text with prop "maxLines" equals <2> in widget tree',
          'A less specific search (Text) discovered 1 matches!',
          'Text("a", maxLines: 4,',
        ]),
      );
    });

    testWidgets('reads fresh props after a rebuild', (tester) async {
      // Props are cached per widget instance. A rebuild creates a new instance,
      // which must not read the previous instance's props.
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );
      spot<Text>().existsOnce().hasMaxLines(4);
      spot<Text>().withMaxLines(4).existsOnce();

      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 7),
        ),
      );
      spot<Text>().existsOnce().hasMaxLines(7);
      spot<Text>().withMaxLines(7).existsOnce();
      spot<Text>().withMaxLines(4).doesNotExist();
      expect(spot<Text>().existsOnce().getDiagnosticProp<int>('maxLines'), 7);
    });

    testWidgets('reads fresh text after a controller change', (tester) async {
      // AnyText reads the text off the live controller, and a bare
      // EditableText keeps its widget instance while its text changes. The
      // props of one frame must not be served in the next.
      final controller = TextEditingController(text: 'before');
      final focusNode = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableText(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(fontSize: 12),
              cursorColor: Colors.red,
              backgroundCursorColor: Colors.grey,
            ),
          ),
        ),
      );
      // Read the prop, not the text filter, so this goes through the cache.
      expect(
        spotTextWhere((it) => it.isNotEmpty())
            .existsOnce()
            .getDiagnosticProp<String>('text'),
        'before',
      );

      final widgetBefore = find.byType(EditableText).evaluate().first.widget;
      controller.text = 'after';
      await tester.pump();
      final widgetAfter = find.byType(EditableText).evaluate().first.widget;
      // The premise of the test: the same instance now reports a new text.
      expect(identical(widgetBefore, widgetAfter), isTrue);

      expect(
        spotTextWhere((it) => it.isNotEmpty())
            .existsOnce()
            .getDiagnosticProp<String>('text'),
        'after',
      );
    });

    testWidgets('selectors deriving different widgets do not collide',
        (tester) async {
      // spot<RichText>() and spotText() resolve to the same element but derive
      // different widgets from it, so they must not read each other's props.
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4, style: TextStyle(fontSize: 12)),
        ),
      );

      // Each has props the other lacks: AnyText flattens the TextStyle into
      // font_*, RichText reports a textWidthBasis. Reading the other one's
      // props finds neither.
      expect(
        spot<RichText>()
            .existsOnce()
            .getDiagnosticProp<TextWidthBasis>('textWidthBasis'),
        TextWidthBasis.parent,
      );
      expect(
        spotText('a').existsOnce().getDiagnosticProp<double>('font_size'),
        12,
      );
    });

    testWidgets('generated withDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Text('a', maxLines: 4),
        ),
      );

      spot<Text>().withMaxLines(4).existsOnce();
      spot<Text>().whereMaxLines((it) => it.equals(4)).existsOnce();

      spot<Text>().withMaxLines(3).doesNotExist();
      spot<Text>().whereMaxLines((it) => it.equals(3)).doesNotExist();

      expect(
        () => spot<Text>().withMaxLines(2).existsOnce(),
        throwsSpotErrorContaining([
          'Could not find Text with prop "maxLines" equals <2> in widget tree',
          'A less specific search (Text) discovered 1 matches!',
          'Text("a", maxLines: 4,',
        ]),
      );
    });
  });
}
