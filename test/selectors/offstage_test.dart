import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('finder offstage', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            Text('a'),
            Text('b'),
            Offstage(child: Text('c')),
          ],
        ),
      ),
    );

    // ok, makes sense
    expect(find.byType(Text), findsNWidgets(2));
    expect(find.byType(Text, skipOffstage: false), findsNWidgets(3));

    final texts1 = find.descendant(
      of: find.byType(MaterialApp),
      matching: find.byType(Text, skipOffstage: false),
    );
    // why not 3? Maybe because MaterialApp already filters out offstage widgets?
    expect(texts1, findsNWidgets(2));

    final texts2 = find.descendant(
      of: find.byType(MaterialApp, skipOffstage: false),
      matching: find.byType(Text),
    );
    // Now MaterialApp should not filter out offstage widgets, but Text does
    expect(texts2, findsNWidgets(2));

    final texts3 = find.descendant(
      of: find.byType(MaterialApp, skipOffstage: false),
      matching: find.byType(Text, skipOffstage: false),
    );
    // Both allow offstage widgets, still only 2. Why? I don't understand.
    expect(texts3, findsNWidgets(2));
  });
}
