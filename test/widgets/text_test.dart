// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../spot/existence_comparison_test.dart';

void main() {
  final treeText = MaterialApp(
    home: Column(
      children: [
        Text('foo'),
      ],
    ),
  );
  group('Text', () {
    testWidgets('spotTexts finds Text', (widgetTester) async {
      await widgetTester.pumpWidget(treeText);

      spotTexts('foo').existsOnce();
      spotTexts<Text>('foo').existsOnce();
      spotTexts<Text>('foo').existsOnce().hasMaxLines(null);
    });

    testWidgets('spotSingleText finds Text', (widgetTester) async {
      await widgetTester.pumpWidget(treeText);

      spotSingleText('foo').existsOnce();
      spotSingleText('foo').existsOnce();
      spotSingleText<Text>('foo').existsOnce().hasMaxLines(null);
    });

    testWidgets('spotText finds Text', (widgetTester) async {
      await widgetTester.pumpWidget(treeText);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(null);
    });
  });

  final treeSelectableText = MaterialApp(
    home: Column(
      children: [
        SelectableText('foo'),
      ],
    ),
  );

  group('SelectableText', () {
    testWidgets('spotTexts finds SelectableText', (widgetTester) async {
      await widgetTester.pumpWidget(treeSelectableText);

      spotTexts<SelectableText>('foo').existsOnce();

      // Does not work because SelectableText wraps Text and it always finds 2 Widgets
      expect(
        () => spotTexts('foo').existsOnce(),
        throwsTestFailure,
      );
    });

    testWidgets('spotSingleText finds SelectableText', (widgetTester) async {
      await widgetTester.pumpWidget(treeSelectableText);

      spotSingleText<SelectableText>('foo').existsOnce();

      // Does not work because SelectableText wraps Text and it always finds 2 Widgets
      expect(
        () => spotSingleText('foo').existsOnce(),
        throwsTestFailure,
      );
    });

    testWidgets('spotText finds SelectableText', (widgetTester) async {
      await widgetTester.pumpWidget(treeSelectableText);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(null);
    });
  });

  final treeEditableText = MaterialApp(
    home: Column(
      children: [
        EditableText(
          controller: TextEditingController(text: 'foo'),
          focusNode: FocusNode(),
          style: TextStyle(),
          cursorColor: Colors.black,
          backgroundCursorColor: Colors.black,
        )
      ],
    ),
  );

  group('EditableText', () {
    testWidgets('spotTexts finds EditableText', (widgetTester) async {
      await widgetTester.pumpWidget(treeEditableText);

      spotTexts('foo').existsOnce();
      spotTexts<EditableText>('foo').existsOnce();
      spotTexts<EditableText>('foo').existsOnce().hasMaxLines(1);
    });

    testWidgets('spotSingleText finds EditableText', (widgetTester) async {
      await widgetTester.pumpWidget(treeEditableText);

      spotSingleText('foo').existsOnce();
      spotSingleText<EditableText>('foo').existsOnce();
      spotSingleText<EditableText>('foo').existsOnce().hasMaxLines(1);
    });

    testWidgets('spotText finds EditableText', (widgetTester) async {
      await widgetTester.pumpWidget(treeEditableText);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(1);
    });
  });

  group('spotText', () {
    testWidgets('finds EditableText', (widgetTester) async {
      await widgetTester.pumpWidget(treeEditableText);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(1);
    });

    testWidgets('finds SelectableText', (widgetTester) async {
      await widgetTester.pumpWidget(treeSelectableText);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(null);
    });

    testWidgets('finds Text', (widgetTester) async {
      await widgetTester.pumpWidget(treeText);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(null);
    });

    group('contains', () {
      testWidgets('finds EditableText', (widgetTester) async {
        await widgetTester.pumpWidget(treeEditableText);

        spotText('oo').existsOnce();
        spotText('oo').existsOnce().hasMaxLines(1);
      });

      testWidgets('finds SelectableText', (widgetTester) async {
        await widgetTester.pumpWidget(treeSelectableText);

        spotText('oo').existsOnce();
        spotText('oo').existsOnce().hasMaxLines(null);
      });

      testWidgets('finds Text', (widgetTester) async {
        await widgetTester.pumpWidget(treeText);

        spotText('oo').existsOnce();
        spotText('oo').existsOnce().hasMaxLines(null);
      });

      testWidgets('finds Text', (widgetTester) async {
        await widgetTester.pumpWidget(treeText);

        spotText('oo').existsOnce();
        spotText('oo').existsOnce().hasMaxLines(null);

        spotText('').whereWidget(
          (AnyText widget) => widget.maxLines == 3,
          description: 'maxlines 3',
        );
      });
    });
  });
}
