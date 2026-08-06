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
          home: Icon(Icons.add, semanticLabel: 'add'),
        ),
      );

      final label =
          spot<Icon>().existsOnce().getDiagnosticProp<String>('semanticLabel');
      expect(label, 'add');
    });

    testWidgets('generated getDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Icon(Icons.add, semanticLabel: 'add'),
        ),
      );

      final label = spot<Icon>().existsOnce().getSemanticLabel();
      expect(label, 'add');
    });

    testWidgets('hasDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Icon(Icons.add, semanticLabel: 'add'),
        ),
      );

      spot<Icon>()
          .existsOnce()
          .hasDiagnosticProp<String>('semanticLabel', (it) => it.equals('add'));

      expect(
        () => spot<Icon>().existsOnce().hasDiagnosticProp<String>(
              'semanticLabel',
              (it) => it.equals('remove'),
            ),
        throwsSpotErrorContaining([
          'Icon with property semanticLabel',
          "equals 'remove', actual: 'add'",
        ]),
      );
    });

    testWidgets('generated hasDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Icon(Icons.add, semanticLabel: 'add'),
        ),
      );

      spot<Icon>()
          .existsOnce()
          .hasSemanticLabel('add')
          .hasSemanticLabelWhere((it) => it.equals('add'));

      expect(
        () => spot<Icon>().existsOnce().hasSemanticLabel('remove'),
        throwsSpotErrorContaining([
          'Icon with property semanticLabel',
          "equals 'remove', actual: 'add'",
        ]),
      );
    });

    testWidgets('withDiagnosticProp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Icon(Icons.add, semanticLabel: 'add'),
        ),
      );

      spot<Icon>()
          .withDiagnosticProp<String>('semanticLabel', (it) => it.equals('add'))
          .existsOnce();

      expect(
        () => spot<Icon>()
            .withDiagnosticProp<String>(
              'semanticLabel',
              (it) => it.equals('remove'),
            )
            .existsOnce(),
        throwsSpotErrorContaining([
          notFoundMessage,
          'A less specific search (Icon) discovered 1 matches!',
          'Icon(IconData(U+0E047), semanticLabel: "add"',
        ]),
      );
    });

    testWidgets('reads fresh props after a rebuild', (tester) async {
      // Props are cached per widget instance. A rebuild creates a new instance,
      // which must not read the previous instance's props.
      await tester.pumpWidget(
        MaterialApp(
          home: Icon(Icons.add, size: 4),
        ),
      );
      spot<Icon>().existsOnce().hasSize(4);
      spot<Icon>().withSize(4).existsOnce();

      await tester.pumpWidget(
        MaterialApp(
          home: Icon(Icons.add, size: 7),
        ),
      );
      spot<Icon>().existsOnce().hasSize(7);
      spot<Icon>().withSize(7).existsOnce();
      spot<Icon>().withSize(4).doesNotExist();
      expect(spot<Icon>().existsOnce().getDiagnosticProp<double>('size'), 7);
    });

    testWidgets('a matcher keeps reporting the widget it matched',
        (tester) async {
      // A matcher describes the moment it was created, like the snapshot it
      // came from. Reading a prop off it later must not answer for a widget
      // it never matched.
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

      final matcher = spotTextWhere((it) => it.isNotEmpty()).existsOnce();
      // The other matcher implementation, built from an element instead of
      // holding a snapshot.
      final discovered = spotTextWhere((it) => it.isNotEmpty())
          .existsExactlyNTimes(1)
          .discovered
          .single;

      controller.text = 'after';
      await tester.pump();

      expect(matcher.widget.text, 'before');
      expect(matcher.getDiagnosticProp<String>('text'), 'before');
      matcher.hasDiagnosticProp<String>('text', (it) => it.equals('before'));

      expect(discovered.widget.text, 'before');
      expect(discovered.getDiagnosticProp<String>('text'), 'before');

      // Only the matcher is frozen. A new query sees the current tree.
      expect(
        spotTextWhere((it) => it.isNotEmpty())
            .existsOnce()
            .getDiagnosticProp<String>('text'),
        'after',
      );
    });

    testWidgets('reads fresh text after a controller change', (tester) async {
      // AnyText reads the text off the live controller, and a bare
      // EditableText keeps its widget instance while its text changes. A
      // matcher taken after the change must see it.
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
          home: Icon(Icons.add, semanticLabel: 'add'),
        ),
      );

      spot<Icon>().withSemanticLabel('add').existsOnce();
      spot<Icon>().whereSemanticLabel((it) => it.equals('add')).existsOnce();

      spot<Icon>().withSemanticLabel('edit').doesNotExist();
      spot<Icon>().whereSemanticLabel((it) => it.equals('edit')).doesNotExist();

      expect(
        () => spot<Icon>().withSemanticLabel('remove').existsOnce(),
        throwsSpotErrorContaining([
          notFoundMessage,
          'A less specific search (Icon) discovered 1 matches!',
          'Icon(IconData(U+0E047), semanticLabel: "add"',
        ]),
      );
    });
  });
}

/// The first line of the failure when no `Icon` has `semanticLabel: remove`.
///
/// A local so the two tests that assert it cannot drift apart, and because
/// adjacent strings inside a list literal read as a forgotten comma.
const notFoundMessage =
    'Could not find Icon with prop "semanticLabel" equals \'remove\' '
    'in widget tree';

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
