import 'package:checks/checks.dart';
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
        spot<MaterialApp>().spot<Scaffold>();
    final appBar = scaffold.spot<AppBar>();

    final container = scaffold.spot<Container>();

    final icon = appBar.spotIcon(
      Icons.home,
      parents: [spot<IconButton>(), container],
    ).existsOnce();

    appBar.spot<IconButton>(
      children: [spotIcon(Icons.settings)],
    ).existsOnce();

    appBar
        .spotIcon(Icons.settings, parents: [spot<IconButton>()]).doesNotExist();

    // finder alternative
    // expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
