// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../spot/existence_comparison_test.dart';

void main() {
  final treeText = _stage(children: [Text('foo')]);

  final treeSelectableText = _stage(children: [SelectableText('foo')]);

  final treeEditableText = _stage(
    children: [
      EditableText(
        controller: TextEditingController(text: 'foo'),
        focusNode: FocusNode(),
        maxLines: null,
        style: TextStyle(),
        cursorColor: Colors.black,
        backgroundCursorColor: Colors.black,
      ),
    ],
  );

  final treeRichText = _stage(
    children: [RichText(text: TextSpan(text: 'foo'))],
  );

  group('spotText', () {
    final trees = {
      'Text': treeText,
      'SelectableText': treeSelectableText,
      'EditableText': treeEditableText,
      'RichText': treeRichText,
    };

    for (final tree in trees.entries) {
      final widgetType = tree.key;

      testWidgets('$widgetType finds', (tester) async {
        await tester.pumpWidget(tree.value);

        spotText('foo').existsOnce();
        spotText('foo').existsOnce().hasMaxLines(null);
      });

      testWidgets('$widgetType contains', (tester) async {
        await tester.pumpWidget(tree.value);

        spotText('oo').existsOnce();
        spotText('oo').existsOnce().hasMaxLines(null);
      });

      testWidgets('$widgetType whereWidget', (tester) async {
        await tester.pumpWidget(tree.value);
        final checked = [];
        spotText('foo').whereWidget(
          (AnyText widget) {
            checked.add(widget);
            return widget.maxLines == 3;
          },
          description: 'maxlines 3',
        ).doesNotExist();
        // found one item, but nothing matched maxlines 3
        expect(checked, hasLength(1));
      });

      testWidgets('$widgetType RegEx', (tester) async {
        await tester.pumpWidget(tree.value);

        spotText(RegExp('f.*o')).existsOnce();
        spotText(RegExp('f.*o')).existsOnce().hasMaxLines(null);
      });
    }

    group('RichText', () {
      testWidgets('concatenates text spans', (tester) async {
        await tester.pumpWidget(
          _stage(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: 'foo'),
                    TextSpan(text: 'bar'),
                  ],
                ),
              ),
            ],
          ),
        );

        spotText('foo').existsOnce();
        spotText('foobar').existsOnce();
      });

      testWidgets('widget spans are replaced with u65532', (tester) async {
        await tester.pumpWidget(
          _stage(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: 'foo'),
                    WidgetSpan(child: Icon(Icons.ac_unit)),
                    TextSpan(text: 'bar'),
                  ],
                ),
              ),
            ],
          ),
        );

        spotText('foo').existsOnce();
        spotText('bar').existsOnce();

        spotText('foobar').doesNotExist();

        // https://www.codetable.net/decimal/65532
        final obj = String.fromCharCode(0xfffc);
        spotText('foo${obj}bar').existsOnce(); // WidgetSpan becomes whitespace
      });
    });
  });

  group('deprecated', () {
    group('Text', () {
      testWidgets('spotTexts finds Text', (tester) async {
        await tester.pumpWidget(treeText);

        spotTexts('foo').existsOnce();
        spotTexts<Text>('foo').existsOnce();
        spotTexts<Text>('foo').existsOnce().hasMaxLines(null);
      });

      testWidgets('spotSingleText finds Text', (tester) async {
        await tester.pumpWidget(treeText);

        spotSingleText('foo').existsOnce();
        spotSingleText('foo').existsOnce();
        spotSingleText<Text>('foo').existsOnce().hasMaxLines(null);
      });

      testWidgets('spotText finds Text', (tester) async {
        await tester.pumpWidget(treeText);

        spotText('foo').existsOnce();
        spotText('foo').existsOnce().hasMaxLines(null);
      });
    });
    group('SelectableText', () {
      testWidgets('spotTexts finds SelectableText', (tester) async {
        await tester.pumpWidget(treeSelectableText);

        spotTexts<SelectableText>('foo').existsOnce();

        // Does not work because SelectableText wraps Text and it always finds 2 Widgets
        expect(
          () => spotTexts('foo').existsOnce(),
          throwsTestFailure,
        );
      });

      testWidgets('spotSingleText finds SelectableText', (tester) async {
        await tester.pumpWidget(treeSelectableText);

        spotSingleText<SelectableText>('foo').existsOnce();

        // Does not work because SelectableText wraps Text and it always finds 2 Widgets
        expect(
          () => spotSingleText('foo').existsOnce(),
          throwsTestFailure,
        );
      });

      testWidgets('spotText finds SelectableText', (tester) async {
        await tester.pumpWidget(treeSelectableText);

        spotText('foo').existsOnce();
        spotText('foo').existsOnce().hasMaxLines(null);
      });
    });

    group('EditableText', () {
      testWidgets('spotTexts finds EditableText', (tester) async {
        await tester.pumpWidget(treeEditableText);

        spotTexts('foo').existsOnce();
        spotTexts<EditableText>('foo').existsOnce();
        spotTexts<EditableText>('foo').existsOnce().hasMaxLines(null);
      });

      testWidgets('spotSingleText finds EditableText', (tester) async {
        await tester.pumpWidget(treeEditableText);

        spotSingleText('foo').existsOnce();
        spotSingleText<EditableText>('foo').existsOnce();
        spotSingleText<EditableText>('foo').existsOnce().hasMaxLines(null);
      });

      testWidgets('spotText finds EditableText', (tester) async {
        await tester.pumpWidget(treeEditableText);

        spotText('foo').existsOnce();
        spotText('foo').existsOnce().hasMaxLines(null);
      });
    });
  });
}

Widget _stage({required List<Widget> children}) {
  return MaterialApp(
    home: Scaffold(
      body: Column(
        children: children,
      ),
    ),
  );
}
