import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('(effective) max lines matcher/selector', (widgetTester) async {
    await widgetTester.pumpWidget(
      const MaterialApp(
        home: DefaultTextStyle(
          style: TextStyle(),
          maxLines: 2,
          child: Text('x'),
        ),
      ),
    );

    spot<Text>().withEffectiveMaxLines(2).existsOnce().hasEffectiveMaxLines(2);
    spot<Text>()
        .withEffectiveMaxLinesMatching((it) => it.isNotNull().isGreaterThan(1))
        .existsOnce()
        .hasEffectiveMaxLinesWhere((it) => it.isNotNull().isGreaterThan(1));
    spot<Text>().withMaxLines(null).existsOnce().hasMaxLines(null);
    spot<Text>()
        .withMaxLinesMatching((it) => it.isNull())
        .existsOnce()
        .hasMaxLinesWhere((it) => it.isNull());
  });
}
