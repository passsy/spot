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

    final homePage = spot<MaterialApp>().spot<Scaffold>();
    final appBar = homePage.spot<AppBar>();

    appBar
        .spotIcon(Icons.settings, parents: [spot<IconButton>()]).doesNotExist();

    // finder alternative
    // expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
