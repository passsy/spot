import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('narrow down search down the tree', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Container(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Test'),
              actions: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () {},
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final WidgetSelector<Scaffold> scaffold =
        spotSingle<MaterialApp>().spotSingle<Scaffold>();
    final appBar = scaffold.spotSingle<AppBar>();

    final container = scaffold.spotSingle<Container>()..existsOnce();

    final icon = appBar.spotSingleIcon(
      Icons.home,
      parents: [spot<IconButton>(), container],
    )..existsOnce();

    appBar.spotSingle<IconButton>(
      children: [spotSingleIcon(Icons.settings)],
    ).doesNotExist();

    appBar.spotSingleIcon(Icons.settings,
        parents: [spot<IconButton>()]).doesNotExist();

    // finder alternative
    // expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
