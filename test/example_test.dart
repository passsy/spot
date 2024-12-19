// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('narrow down search down the tree', (tester) async {
    await loadAppFonts();
    await tester.pumpWidget(
      MaterialApp(
        home: Container(
          child: Scaffold(
            appBar: AppBar(
              title: DefaultTextStyle.merge(
                maxLines: 2,
                child: Text('Pepe'),
              ),
              actions: [
                Wrap(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: const Icon(Icons.home),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
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

    spot<Text>().first().existsOnce().hasText('Pepe');

    final WidgetSelector<Scaffold> scaffold =
        spot<MaterialApp>().spot<Scaffold>();
    final appBar = scaffold.spot<AppBar>();

    final container = scaffold.spot<Container>()..existsOnce();

    appBar.spotIcon(
      Icons.home,
      parents: [spot<IconButton>(), container],
    ).existsOnce();

    appBar.spot<IconButton>(
      children: [spotIcon(Icons.settings)],
    ).doesNotExist();

    appBar.spotIcon(
      Icons.settings,
      parents: [spot<IconButton>()],
    ).doesNotExist();

    appBar.spotIcon(
      Icons.home,
      parents: [spot<IconButton>()],
    ).existsExactlyNTimes(2);

    // finder alternative
    // expect(find.byIcon(Icons.settings), findsOneWidget);
  });
}
