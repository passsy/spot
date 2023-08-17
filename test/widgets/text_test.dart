// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('spotTexts finds Text', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            Text('foo'),
          ],
        ),
      ),
    );

    spotTexts('foo').existsOnce();
    spotTexts<Text>('foo').existsOnce();
    spotTexts<Text>('foo').existsOnce().hasMaxLines(null);
  });

  testWidgets('spotTexts finds SelectableText', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Column(
          children: [
            SelectableText('foo'),
          ],
        ),
      ),
    );

    spotTexts('foo').existsOnce();
    spotSingle<SelectableText>(children: [spotTexts('foo')]).existsOnce();
    spotSingle<SelectableText>(children: [spotTexts('foo')])
        .existsOnce()
        .hasMaxLines(null);
  });

  testWidgets('spotTexts finds EditableText', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Column(
          // ignore: require_trailing_commas
          children: [
            EditableText(
              controller: TextEditingController(text: 'foo'),
              focusNode: FocusNode(),
              style: TextStyle(),
              cursorColor: Colors.black,
              backgroundCursorColor: Colors.black,
            ),
          ],
        ),
      ),
    );

    spotTexts('foo').existsOnce();
    spotTexts<EditableText>('foo').existsOnce();
    spotTexts<EditableText>('foo').existsOnce().hasMaxLines(1);
  });
}
