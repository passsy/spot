// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  testWidgets('.all', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: const [
              IconButton(
                onPressed: null,
                icon: Icon(Icons.home),
              ),
              IconButton(
                onPressed: null,
                icon: Icon(Icons.settings),
              ),
            ],
          ),
          body: Placeholder(),
        ),
      ),
    );

    final scaffold = spot<MaterialApp>().spot<Scaffold>();
    final appBar = scaffold.spot<AppBar>();
    spot<AppBar>().spotIcon(Icons.settings).existsOnce();

    spot<Icon>(parents: [appBar, spot<IconButton>()])
        .existsExactlyNTimes(2)
        .all((icon) => icon.hasColorWhere((color) => color.isNull()));
  });

  testWidgets('.any', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: const [
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.home,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: null,
                icon: Icon(Icons.settings),
              ),
            ],
          ),
          body: Placeholder(),
        ),
      ),
    );

    final scaffold = spot<MaterialApp>().spot<Scaffold>();
    final appBar = scaffold.spot<AppBar>();
    spot<AppBar>().spotIcon(Icons.settings).existsOnce();

    spot<Icon>(parents: [appBar, spot<IconButton>()])
        .existsExactlyNTimes(2)
        .any((icon) => icon.hasColor(Colors.red));
  });

  testWidgets('.all throws readable error message', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: const [
              IconButton(
                onPressed: null,
                icon: Icon(Icons.home),
              ),
              IconButton(
                onPressed: null,
                icon: Icon(Icons.settings),
              ),
            ],
          ),
          body: Placeholder(),
        ),
      ),
    );

    final scaffold = spot<MaterialApp>().spot<Scaffold>();
    final appBar = scaffold.spot<AppBar>();
    spot<AppBar>().spotIcon(Icons.settings).existsOnce();

    expect(
      () => spot<Icon>(parents: [appBar, spot<IconButton>()])
          .existsExactlyNTimes(2)
          .all((icon) {
        icon.hasColorWhere((color) => color.equals(Colors.black));
      }),
      throwsSpotErrorContaining([
        "Expected that all candidates fulfill matcher 'property color",
        "equals <Color(0xff000000)>', but only 0 of 2 did.",
      ]),
    );
  });

  testWidgets('.any throws readable error message', (widgetTester) async {
    await widgetTester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: const [
              IconButton(
                onPressed: null,
                icon: Icon(Icons.home),
              ),
              IconButton(
                onPressed: null,
                icon: Icon(Icons.settings),
              ),
            ],
          ),
          body: Placeholder(),
        ),
      ),
    );

    final scaffold = spot<MaterialApp>().spot<Scaffold>();
    final appBar = scaffold.spot<AppBar>();
    spot<AppBar>().spotIcon(Icons.settings).existsOnce();

    expect(
      () => spot<Icon>(parents: [appBar, spot<IconButton>()])
          .existsExactlyNTimes(2)
          .any((icon) {
        icon.hasColorWhere((color) => color.equals(Colors.black));
      }),
      throwsSpotErrorContaining([
        "Expected that at least one candidate fulfills matcher 'property color",
        "equals <Color(0xff000000)>', but none did.",
      ]),
    );
  });
}
