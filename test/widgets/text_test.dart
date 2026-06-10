// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../spot/existence_comparison_test.dart';

const testTextStyle = TextStyle(color: Colors.red);
const zeroWidthSpace = '\u200B';
const nonBreakingSpace = '\u00A0';

void main() {
  // does inherit TextStyle
  final treeText = _stage(children: [Text('foo')]);
  final treeSelectableText = _stage(children: [SelectableText('foo')]);

  final treeEditableText = _stage(
    children: [
      EditableText(
        controller: TextEditingController(text: 'foo'),
        focusNode: FocusNode(),
        maxLines: null,
        // not inherited from DefaultTextStyle
        style: testTextStyle,
        cursorColor: Colors.black,
        backgroundCursorColor: Colors.black,
      ),
    ],
  );

  final treeRichText = _stage(
    children: [
      RichText(
        text: TextSpan(
          text: 'foo',
          // not inherited from DefaultTextStyle
          style: testTextStyle,
        ),
      ),
    ],
  );

  final trees = {
    'Text': treeText,
    'SelectableText': treeSelectableText,
    'EditableText': treeEditableText,
    'RichText': treeRichText,
  };
  group('spotText', () {
    for (final tree in trees.entries) {
      final widgetType = tree.key;

      group(widgetType, () {
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

        testWidgets('$widgetType with filter', (tester) async {
          await tester.pumpWidget(tree.value);
          spotText('foo')
              .whereMaxLines((it) => it.isNull())
              .whereText((it) => it.equals('foo'))
              .whereFontColor((it) => it.isNotNull())
              .existsOnce();
        });

        testWidgets('$widgetType matches', (tester) async {
          await tester.pumpWidget(tree.value);
          spotText('foo')
              .existsOnce()
              .hasTextWhere((it) => it.equals('foo'))
              .hasMaxLinesWhere((it) => it.isNull())
              .hasFontColor(Colors.red)
              .hasFontSize(14)
              .hasFontStyleWhere((it) => it.isNull());
        });

        testWidgets('$widgetType exact', (tester) async {
          await tester.pumpWidget(tree.value);
          spotText('foo', whole: true).existsOnce();
          spotText('oo', whole: true).doesNotExist();
        });

        testWidgets('$widgetType RegEx', (tester) async {
          await tester.pumpWidget(tree.value);

          spotText(RegExp('f.*o')).existsOnce();
          spotText(RegExp('f.*o')).existsOnce().hasMaxLines(null);
        });

        testWidgets('snapshot', (tester) async {
          await tester.pumpWidget(tree.value);
          final foundSnapshot = spotText('foo').snapshot();
          check(foundSnapshot.discovered).isA<List<WidgetTreeNode>>();
          check(foundSnapshot.discovered).length.equals(1);
          check(foundSnapshot.element).isA<Element>();
          check(foundSnapshot.widget).isA<AnyText>();
          check(foundSnapshot.discoveredElement).isA<Element>();

          final notFound = spotText('bar').snapshot();
          check(notFound.discovered).length.equals(0);
          check(notFound.discovered).isEmpty();
          check(notFound.widget).isNull();
          check(notFound.element).isNull();
          check(notFound.discoveredElement).isNull();
        });
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

    testWidgets('chain with parents', (tester) async {
      await tester.pumpWidget(
        _stage(
          children: [
            _MyWidget(
              child: Text('a'),
            ),
            RotatedBox(
              quarterTurns: 2,
              child: Text('b'),
            ),
            Text('a'),
            Text('b'),
          ],
        ),
      );

      spot<_MyWidget>().spotText('a').existsOnce();
      spot<RotatedBox>().spotText('b').existsOnce();

      spot<_MyWidget>().spotText('b').doesNotExist();
      spot<RotatedBox>().spotText('a').doesNotExist();
    });
  });

  testWidgets('spotText finds multiple text', (tester) async {
    await tester.pumpWidget(
      _stage(
        children: [
          Text('a'),
          Text('b'),
          Text('a'),
        ],
      ),
    );

    spotText('a').existsExactlyNTimes(2);
  });

  group('spotTextWhere', () {
    for (final tree in trees.entries) {
      final widgetType = tree.key;

      testWidgets('$widgetType equals', (tester) async {
        await tester.pumpWidget(tree.value);

        spotTextWhere((it) => it.equals('foo')).existsOnce();
        spotTextWhere((it) => it.equals('oo')).doesNotExist();
      });

      testWidgets('$widgetType startsWith', (tester) async {
        await tester.pumpWidget(tree.value);

        spotTextWhere((it) => it.startsWith('fo')).existsOnce();
        spotTextWhere((it) => it.startsWith('oo')).doesNotExist();
      });
    }
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
        spotTexts<EditableText>('foo').existsOnce().hasMaxLines(1);
      });

      testWidgets('spotSingleText finds EditableText', (tester) async {
        await tester.pumpWidget(treeEditableText);

        spotSingleText('foo').existsOnce();
        spotSingleText<EditableText>('foo').existsOnce();
        spotSingleText<EditableText>('foo').existsOnce().hasMaxLines(1);
      });

      testWidgets('spotText finds EditableText', (tester) async {
        await tester.pumpWidget(treeEditableText);

        spotText('foo').existsOnce();
        spotText('foo').existsOnce().hasMaxLines(null);
      });
    });
  });
  group('AnyText', () {
    testWidgets('toString TextSpan', (tester) async {
      await tester.pumpWidget(treeRichText);
      final text = spotText('foo').snapshotWidget();

      expect(text.toStringShort(), 'RichText');
      expect(
        text.toString(),
        stringContainsInOrder([
          'RichText(',
          'text: "foo",',
          'softWrap: wrapping at box width,',
          'maxLines: unlimited,',
          'font_color: ${Colors.red},',
        ]),
      );
      expect(
        text.toStringShallow(),
        stringContainsInOrder([
          'RichText(',
          'softWrap: wrapping at box width,',
          'maxLines: unlimited,',
          'text: "foo"',
          'font_color: ${Colors.red},',
        ]),
      );
      expect(
        text.toStringDeep(),
        stringContainsInOrder([
          'RichText(text: "foo"',
          'softWrap: wrapping at box width,',
          'maxLines: unlimited',
          'font_color: ${Colors.red}',
          'font_size: null',
        ]),
      );
    });

    testWidgets('toString EditableText', (tester) async {
      await tester.pumpWidget(treeEditableText);
      final text = spotText('foo').snapshotWidget();

      expect(text.toStringShort(), 'EditableText');
      expect(
        text.toString(),
        stringContainsInOrder([
          'EditableText(',
          'text: "foo",',
          'color: ${Colors.red},',
        ]),
      );
      expect(
        text.toStringShallow(),
        stringContainsInOrder([
          'EditableText(',
          'text: "foo",',
          'font_color: ${Colors.red},',
        ]),
      );
      expect(
        text.toStringDeep().trim(),
        stringContainsInOrder([
          'EditableText(text: "foo"',
          'maxLines: unlimited',
          'font_color: ${Colors.red}',
          'font_size: null',
        ]),
      );
    });
  });

  group('visible text normalization', () {
    test('normalizeVisibleText removes invisible characters', () {
      expect(AnyText.normalizeVisibleText('f\u200Bo\u200Bo'), 'foo'); // ZWSP
      expect(AnyText.normalizeVisibleText('soft\u00ADhyphen'),
          'softhyphen'); // SHY
      expect(
          AnyText.normalizeVisibleText('word\u2060joiner'), 'wordjoiner'); // WJ
      expect(AnyText.normalizeVisibleText('\uFEFFbom'), 'bom'); // ZWNBSP / BOM
    });

    test('normalizeVisibleText folds space separators to a regular space', () {
      expect(AnyText.normalizeVisibleText('foo\u00A0bar'), 'foo bar'); // NBSP
      expect(
          AnyText.normalizeVisibleText('1\u202F234'), '1 234'); // NARROW NBSP
      expect(AnyText.normalizeVisibleText('thin\u2009space'), 'thin space');
      expect(AnyText.normalizeVisibleText('em\u2003space'), 'em space');
      expect(AnyText.normalizeVisibleText('ogham\u1680mark'), 'ogham mark');
      expect(AnyText.normalizeVisibleText('math\u205Fspace'), 'math space');
      expect(AnyText.normalizeVisibleText('full\u3000width'), 'full width');
    });

    test('normalizeVisibleText keeps meaningful and structural characters', () {
      // Zero Width Joiner builds emoji sequences and must be preserved.
      expect(AnyText.normalizeVisibleText('a\u200Db'), 'a\u200Db');
      // Object Replacement Character represents an embedded WidgetSpan.
      expect(AnyText.normalizeVisibleText('a\uFFFCb'), 'a\uFFFCb');
      // Tabs and line breaks are structure, not spaces.
      expect(AnyText.normalizeVisibleText('a\tb\nc'), 'a\tb\nc');
      expect(AnyText.normalizeVisibleText('unchanged'), 'unchanged');
    });

    test('TextContent exposes both raw and normalized text', () {
      final content = AnyTextContent('foo${nonBreakingSpace}bar');
      expect(content.raw, 'foo${nonBreakingSpace}bar');
      expect(content.normalized, 'foo bar');
    });

    testWidgets('extractTextContent reads raw and normalized from a widget',
        (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('foo${nonBreakingSpace}bar')]),
      );
      final content =
          AnyText.extractText(tester.element(find.byType(RichText).first));
      expect(content, isNotNull);
      expect(content!.raw, 'foo${nonBreakingSpace}bar');
      expect(content.normalized, 'foo bar');
    });

    testWidgets('extractTextContent returns null for non-text widgets',
        (tester) async {
      await tester.pumpWidget(_stage(children: [Icon(Icons.add)]));
      expect(
        AnyText.extractText(tester.element(find.byIcon(Icons.add))),
        isNull,
      );
    });

    testWidgets('spotText ignores ZWSP', (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('f${zeroWidthSpace}o${zeroWidthSpace}o')]),
      );
      spotText('foo').existsOnce();
      spot<Column>().spotText('foo').existsOnce();
      // The needle is normalized too, so the raw spelling matches as well.
      spotText('f${zeroWidthSpace}o${zeroWidthSpace}o').existsOnce();
    });

    testWidgets('spotText treats NBSP as a regular space', (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('foo${nonBreakingSpace}bar baz')]),
      );
      spotText('foo bar baz').existsOnce();
      spotText('foo${nonBreakingSpace}bar baz').existsOnce();
      spotText('foo bar${nonBreakingSpace}baz').existsOnce();
    });

    testWidgets('spotText with whole matches the entire text', (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('a${nonBreakingSpace}b')]),
      );
      spotText('a b', whole: true).existsOnce();
      spotText('a${nonBreakingSpace}b', whole: true).existsOnce();
      // whole requires the entire text, so a substring does not match.
      spotText('a', whole: true).doesNotExist();
      spotText('a').existsOnce();
    });

    testWidgets('deprecated exact still behaves like whole', (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('a${nonBreakingSpace}b')]),
      );
      spotText('a b', exact: true).existsOnce();
      spotText('a', exact: true).doesNotExist();
    });

    testWidgets('spotText handles narrow NBSP and soft hyphen', (tester) async {
      // '12<NNBSP>345' price formatting and a soft hyphen inside 'invisible'.
      await tester.pumpWidget(
        _stage(children: [Text('12\u202F345 \u20AC in\u00ADvisible')]),
      );
      spotText('12 345 \u20AC invisible').existsOnce();
    });

    testWidgets('spotText normalizes ZWSP inside Text.rich', (tester) async {
      await tester.pumpWidget(
        _stage(
          children: [Text.rich(TextSpan(text: 'He${zeroWidthSpace}llo'))],
        ),
      );
      spotText('Hello').existsOnce();
    });

    testWidgets('whereText/withText/hasText match the normalized text',
        (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('foo${nonBreakingSpace}bar')]),
      );
      spotText('foo').whereText((it) => it.equals('foo bar')).existsOnce();
      spotText('foo').withText('foo bar').existsOnce();
      spotText('foo').existsOnce().hasText('foo bar');
    });

    testWidgets('whereRawText/withRawText/hasRawText match exact characters',
        (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('foo${nonBreakingSpace}bar')]),
      );
      // The raw text keeps the NBSP, so a regular space does not match.
      spotText('foo').withRawText('foo bar').doesNotExist();
      spotText('foo').withRawText('foo${nonBreakingSpace}bar').existsOnce();
      spotText('foo')
          .whereRawText((it) => it.equals('foo${nonBreakingSpace}bar'))
          .existsOnce();
      spotText('foo').existsOnce().hasRawText('foo${nonBreakingSpace}bar');
    });

    testWidgets('spotTextWhere operates on the normalized text',
        (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('foo${nonBreakingSpace}bar')]),
      );
      spotTextWhere((it) => it.contains('foo bar')).existsOnce();
      spotTextWhere((it) => it.startsWith('foo b')).existsOnce();
    });

    testWidgets('spotText with raw matches the exact characters',
        (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('foo${nonBreakingSpace}bar')]),
      );
      // The NBSP is matched literally; a regular space does not match.
      spotText('foo${nonBreakingSpace}bar', raw: true).existsOnce();
      spotText('foo bar', raw: true).doesNotExist();
      // contains by default, whole requires the entire text
      spotText('foo$nonBreakingSpace', raw: true).existsOnce();
      spotText('foo$nonBreakingSpace', raw: true, whole: true).doesNotExist();
      spotText('foo${nonBreakingSpace}bar', raw: true, whole: true)
          .existsOnce();
    });

    testWidgets('spotTextWhere with raw operates on the raw text',
        (tester) async {
      await tester.pumpWidget(
        _stage(children: [Text('foo${nonBreakingSpace}bar')]),
      );
      spotTextWhere((it) => it.equals('foo${nonBreakingSpace}bar'), raw: true)
          .existsOnce();
      spotTextWhere((it) => it.equals('foo bar'), raw: true).doesNotExist();
      spotTextWhere((it) => it.startsWith('foo$nonBreakingSpace'), raw: true)
          .existsOnce();
    });
  });
}

Widget _stage({required List<Widget> children}) {
  return MaterialApp(
    home: Scaffold(
      body: DefaultTextStyle(
        style: testTextStyle,
        child: Column(
          children: children,
        ),
      ),
    ),
  );
}

class _MyWidget extends StatelessWidget {
  const _MyWidget({required this.child});

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return child;
  }
}
