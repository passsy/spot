// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/foundation.dart';
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

    testWidgets('builds the props of a widget only once', (tester) async {
      // Why the cache exists. All three entry points read through it, so a
      // widget fills its properties once no matter how often it is inspected.
      var fills = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: _CountingProps(value: 4, onFillProperties: () => fills++),
        ),
      );

      spot<_CountingProps>()
          .existsOnce()
          .hasDiagnosticProp<int>('value', (it) => it.equals(4));
      expect(fills, 1);

      spot<_CountingProps>().existsOnce().getDiagnosticProp<int>('value');
      spot<_CountingProps>()
          .withDiagnosticProp<int>('value', (it) => it.equals(4))
          .existsOnce();
      expect(fills, 1);

      // A rebuild creates a new widget instance, which has its own properties.
      await tester.pumpWidget(
        MaterialApp(
          home: _CountingProps(value: 7, onFillProperties: () => fills++),
        ),
      );
      expect(
        spot<_CountingProps>().existsOnce().getDiagnosticProp<int>('value'),
        7,
      );
      expect(fills, 2);
    });

    testWidgets('does not share props between elements of one widget',
        (tester) async {
      // One widget instance can be mounted in several elements, and a selector
      // deriving its widget from the element reports different props for each.
      const shared = _Marker();
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              DefaultTextStyle(
                style: TextStyle(fontSize: 10),
                child: shared,
              ),
              DefaultTextStyle(
                style: TextStyle(fontSize: 20),
                child: shared,
              ),
            ],
          ),
        ),
      );

      expect(
        _spotFontSizeOfContext()
            .atIndex(0)
            .existsOnce()
            .getDiagnosticProp<double>('contextValue'),
        10,
      );
      expect(
        _spotFontSizeOfContext()
            .atIndex(1)
            .existsOnce()
            .getDiagnosticProp<double>('contextValue'),
        20,
      );
      // Both directions: reading the first element's props for the second one
      // makes the filter match twice for 10 and never for 20.
      _spotFontSizeOfContext()
          .withDiagnosticProp<double>('contextValue', (it) => it.equals(10))
          .existsOnce();
      _spotFontSizeOfContext()
          .withDiagnosticProp<double>('contextValue', (it) => it.equals(20))
          .existsOnce();
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

/// Reports how often it was asked for its diagnostic properties.
class _CountingProps extends StatelessWidget {
  const _CountingProps({required this.value, required this.onFillProperties});

  final int value;
  final void Function() onFillProperties;

  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    onFillProperties();
    super.debugFillProperties(properties);
    properties.add(IntProperty('value', value));
  }
}

/// A widget without properties of its own, to be mounted more than once.
class _Marker extends StatelessWidget {
  const _Marker();

  @override
  Widget build(BuildContext context) => const SizedBox();
}

/// The properties of a [_Marker] element, taken from its context instead of
/// from its widget, which is what makes two elements of one [_Marker] instance
/// report different properties.
class _FontSizeOfContext extends StatelessWidget {
  const _FontSizeOfContext(this.contextValue);

  final double contextValue;

  @override
  Widget build(BuildContext context) => const SizedBox();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('contextValue', contextValue));
  }
}

WidgetSelector<_FontSizeOfContext> _spotFontSizeOfContext() {
  return WidgetSelector<_FontSizeOfContext>(
    stages: [WidgetTypeFilter<_Marker>()],
    mapElementToWidget: (element) =>
        _FontSizeOfContext(DefaultTextStyle.of(element).style.fontSize!),
  );
}
