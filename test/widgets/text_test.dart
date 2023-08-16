// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  group('Text', () {
    final tree = MaterialApp(
      home: Column(
        children: [
          Text('foo'),
        ],
      ),
    );

    testWidgets('spotTexts finds Text', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotTexts('foo').existsOnce();
      spotTexts<Text>('foo').existsOnce();
      spotTexts<Text>('foo').existsOnce().hasMaxLines(null);
    });

    testWidgets('spotSingleText finds Text', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotSingleText('foo').existsOnce();
      spotSingleText('foo').existsOnce();
      spotSingleText<Text>('foo').existsOnce().hasMaxLines(null);
    });

    testWidgets('spotText finds Text', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(null);
    });
  });
  group('SelectableText', () {
    final tree = MaterialApp(
      home: Column(
        children: [
          SelectableText('foo'),
        ],
      ),
    );
    testWidgets('spotTexts finds SelectableText', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotTexts('foo').existsOnce();
      spotTexts<SelectableText>('foo').existsOnce();
      spotTexts<SelectableText>('foo').existsOnce().hasMaxLines(null);
    });

    testWidgets('spotSingleText finds SelectableText', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotSingleText('foo').existsOnce();
      spotSingleText<SelectableText>('foo').existsOnce();
      spotSingleText<SelectableText>('foo').existsOnce().hasMaxLines(null);
    });

    testWidgets('spotText finds SelectableText', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(null);
    });
  });

  group('EditableText', () {
    final tree = MaterialApp(
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

    testWidgets('spotTexts finds EditableText', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotTexts('foo').existsOnce();
      spotTexts<EditableText>('foo').existsOnce();
      spotTexts<EditableText>('foo').existsOnce().hasMaxLines(1);
    });

    testWidgets('spotSingleText finds EditableText', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotSingleText('foo').existsOnce();
      spotSingleText<EditableText>('foo').existsOnce();
      spotSingleText<EditableText>('foo').existsOnce().hasMaxLines(1);
    });

    testWidgets('spotText finds EditableText', (widgetTester) async {
      await widgetTester.pumpWidget(tree);

      spotText('foo').existsOnce();
      spotText('foo').existsOnce().hasMaxLines(1);
    });
  });
}
