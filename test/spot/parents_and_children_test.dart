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

  testWidgets('children scope checks quantity only in subtree', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Wrap(),
            Container(),
            Container(),
            Container(child: Wrap()),
          ],
        ),
      ),
    );
    final containers = spot<Container>();
    containers.existsExactlyNTimes(3);
    final wraps = spot<Wrap>();
    wraps.existsExactlyNTimes(2);

    // spotSingle can be used matching only a single Wrap despite multiple Wraps being in the widget tree.
    // There is only a single Wrap in the subtree of the last Container, so this test passes.
    containers.withChild(spotSingle<Wrap>()).existsOnce();

    // The child matcher can reach outside of the subtree. MaterialApp (parent) is defined outside.
    // Still both Wraps match, but only the one in the subtree is counted
    containers.withChild(spot<MaterialApp>().spotSingle<Wrap>()).existsOnce();
  });

  testWidgets('children scope does not throw when quantity does not match',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Wrap(),
            Container(),
            Container(),
            Container(
              child: Wrap(
                children: const [Wrap()],
              ),
            ),
          ],
        ),
      ),
    );
    final containers = spot<Container>();
    containers.existsExactlyNTimes(3);
    final wraps = spot<Wrap>();
    wraps.existsExactlyNTimes(3);

    // child query expects one or more Wraps, which can be found
    containers.withChild(spot<Wrap>()).existsOnce();
    // Enforcing a single Wrap fails because the subtree of Container has two Wraps
    containers.withChild(spotSingle<Wrap>()).doesNotExist();
    containers.withChild(spot<Wrap>().amount(1)).doesNotExist();
    containers.withChild(spot<Wrap>().atLeast(1)).existsOnce();
    containers.withChild(spot<Wrap>().atMost(1)).doesNotExist();
    // It does not throw though! The child constraints are filter and do not enforce that every Container must have a single Wrap
  });

  testWidgets('withChild', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Container(),
            Container(),
            Container(child: Wrap()),
          ],
        ),
      ),
    );
    final containers = spot<Container>();
    containers.existsExactlyNTimes(3);
    containers.withChild(spot<Wrap>()).existsOnce();
    containers.withChildren([spot<Wrap>()]).existsOnce();
  });

  testWidgets('withChild(a).withChild(b) == withChildren(a,b)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Container(),
            Container(),
            Container(child: Wrap(children: const [Center()])),
          ],
        ),
      ),
    );
    final withChildTwice = spot<Container>()
        .withChild(spot<Center>())
        .withChild(spot<Wrap>())
      ..existsOnce();
    final withChildren = spot<Container>()
        .withChildren([spot<Center>(), spot<Wrap>()])
      ..existsOnce();

    expect(withChildTwice.children.length, 2);
    expect(withChildren.children.length, 2);
  });

  testWidgets('withParent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Row(
          children: [
            Container(),
            Container(),
            Wrap(children: [Container()]),
          ],
        ),
      ),
    );
    final containers = spot<Container>();
    containers.existsExactlyNTimes(3);
    containers.withParent(spot<Wrap>()).existsOnce();
    containers.withParents([spot<Wrap>()]).existsOnce();
  });

  testWidgets('withParent(a).withParent(b) == withParents(a,b)',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Test'),
            actions: [
              Wrap(
                children: [
                  Center(
                    child: Container(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    final withParentTwice = spot<Container>()
        .withParent(spot<Center>())
        .withParent(spot<Wrap>())
      ..existsOnce();
    final withParents = spot<Container>()
        .withParents([spot<Center>(), spot<Wrap>()])
      ..existsOnce();

    expect(withParentTwice.parents.length, 2);
    expect(withParents.parents.length, 2);
  });
}
