import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('narrow down search down the tree', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Test'),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final result = spot.byType<MaterialApp>().snapshot();
    expect(result.matchingElements.length, 1);

    final homePage = spot.byType<MaterialApp>().childByType(Scaffold).single;
    final appBar = homePage.childByType(AppBar).single;

    appBar
        .childByIcon(
          Icons.settings,
          parents: [spot.byType<IconButton>()],
        )
        .single()
        .doesNotExist();

    // finder alternative
    // expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
