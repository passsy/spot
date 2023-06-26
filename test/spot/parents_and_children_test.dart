// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('parents can have parents too', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Container(
          child: Scaffold(
            appBar: AppBar(
              title: DefaultTextStyle(
                style: TextStyle(),
                maxLines: 2,
                child: Text('Pepe'),
              ),
              actions: [
                Wrap(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),

                        /// find this IconButton
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

    final materialApp = spotSingle<MaterialApp>();
    final scaffold = materialApp.spotSingle<Scaffold>();
    final wrap = scaffold.spotSingle<Wrap>();

    // IconButton has parents with a different scope
    // and search is not limited to scope of IconButton
    scaffold.spot<IconButton>(parents: [wrap]).existsOnce();
  });

  testWidgets('children can have parents too', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Container(
          child: Scaffold(
            appBar: AppBar(
              title: DefaultTextStyle(
                style: TextStyle(),
                maxLines: 2,
                child: Text('Pepe'),
              ),
              actions: [
                Wrap(
                  children: [
                    /// find this Container
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

    final materialApp = spotSingle<MaterialApp>();
    final scaffold = materialApp.spotSingle<Scaffold>();
    final wrap = scaffold.spotSingle<Wrap>();

    final iconButton = wrap.spotSingle<IconButton>();

    scaffold.spot<Container>(children: [iconButton]).existsOnce();
  });
}
