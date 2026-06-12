// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/snapshot.dart';

void main() {
  testWidgets('MultiWidgetSnapshot keeps reference to old Widget',
      (tester) async {
    await tester.pumpWidget(Center(child: SizedBox(height: 200)));
    final WidgetSnapshot<SizedBox> oldTree = snapshot(spot<SizedBox>());
    await tester.pumpWidget(Center(child: SizedBox(height: 100)));
    final WidgetSnapshot<SizedBox> newTree = snapshot(spot<SizedBox>());
    expect(oldTree.discoveredWidgets.first.height, 200);
    expect(newTree.discoveredWidgets.first.height, 100);
  });

  testWidgets('WidgetSnapshot keeps reference to old Widget', (tester) async {
    await tester.pumpWidget(Center(child: SizedBox(height: 200)));
    final WidgetSnapshot<SizedBox> oldTree = snapshot(spot<SizedBox>());
    await tester.pumpWidget(Center(child: SizedBox(height: 100)));
    final WidgetSnapshot<SizedBox> newTree = snapshot(spot<SizedBox>());
    expect(oldTree.discoveredWidget!.height, 200);
    expect(newTree.discoveredWidget!.height, 100);
  });

  testWidgets('cacheable selector stages are reused across equivalent chains',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            children: [
              Row(children: [Text('a')]),
              Row(children: [Text('b')]),
            ],
          ),
        ),
      ),
    );

    final first = spot<Text>()
        .withParent(spot<Row>().withParent(spot<Column>()))
        .snapshot();
    final second = spot<Text>()
        .withParent(spot<Row>().withParent(spot<Column>()))
        .snapshot();

    expect(first.queryStats.totalChecks, greaterThan(0));
    expect(second.queryStats.totalChecks, 0);
    expect(second.queryStats.cacheHits, greaterThan(0));
    expect(second.queryStats.cacheHitChecks, greaterThan(0));
    expect(second.queryStats.cacheRatio, 1);
    expect(second.discoveredWidgets.map((it) => it.data), ['a', 'b']);
  });

  testWidgets('uncacheable whereElement suffix reruns in the same frame',
      (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            children: const [
              Text('a'),
              Text('b'),
            ],
          ),
        ),
      ),
    );

    var selectedText = 'a';
    var predicateCalls = 0;
    final selector = spot<Text>().whereElement(
      (element) {
        predicateCalls++;
        final widget = element.widget;
        return widget is Text && widget.data == selectedText;
      },
      description: 'matches selected text',
    );

    final first = selector.snapshot();
    final firstPredicateCalls = predicateCalls;
    selectedText = 'b';
    final second = selector.snapshot();
    final secondPredicateCalls = predicateCalls - firstPredicateCalls;
    final expectedSecondCacheRatio =
        second.queryStats.cacheHitChecks / first.queryStats.candidateChecks;

    expect(first.discoveredWidgets.map((it) => it.data), ['a']);
    expect(second.discoveredWidgets.map((it) => it.data), ['b']);
    expect(firstPredicateCalls, 2);
    expect(secondPredicateCalls, 2);
    expect(first.queryStats.cacheHits, 0);
    expect(first.queryStats.cacheHitChecks, 0);
    expect(first.queryStats.cacheRatio, 0);
    expect(
      first.queryStats.candidateChecks,
      second.queryStats.cacheHitChecks + firstPredicateCalls,
    );
    expect(second.queryStats.candidateChecks, secondPredicateCalls);
    expect(second.queryStats.totalChecks, secondPredicateCalls);
    expect(second.queryStats.cacheHits, 2);
    expect(
      second.queryStats.cacheRatio,
      closeTo(expectedSecondCacheRatio, 0.0000001),
    );
  });

  testWidgets('spotText reuses equivalent text selector cache', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            children: const [
              Text('hello'),
              Text('world'),
            ],
          ),
        ),
      ),
    );

    final first = spotText('hello').snapshot();
    final second = spotText('hello').snapshot();

    expect(first.queryStats.totalChecks, greaterThan(0));
    expect(second.queryStats.totalChecks, 0);
    expect(second.queryStats.cacheHits, greaterThan(0));
    expect(second.queryStats.cacheRatio, 1);
    expect(second.discoveredWidget!.text, 'hello');
  });

  testWidgets('spotTextWhere reruns in the same frame', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            children: const [
              Text('a'),
              Text('b'),
            ],
          ),
        ),
      ),
    );

    var selectedText = 'a';
    final selector = spot().spotTextWhere(
      (it) {
        it.equals(selectedText);
      },
      description: 'matches selected text',
    );

    final first = selector.snapshot();
    selectedText = 'b';
    final second = selector.snapshot();

    expect(first.discoveredWidget!.text, 'a');
    expect(second.discoveredWidget!.text, 'b');
    expect(second.queryStats.totalChecks, greaterThan(0));
    expect(second.queryStats.cacheHits, greaterThan(0));
  });

  testWidgets('PredicateFilter can opt into cacheKey reuse', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            children: const [
              Text('a'),
              Text('b'),
            ],
          ),
        ),
      ),
    );

    WidgetSelector<Text> selector() {
      return WidgetSelector<Text>(
        stages: [
          PredicateFilter(
            predicate: (element) {
              final widget = element.widget;
              return widget is Text && widget.data == 'a';
            },
            description: 'Text data is a',
            cacheKey: SpotCacheKey(
              PredicateFilter,
              ['Text data is a'],
            ),
          ),
        ],
      );
    }

    final first = selector().snapshot();
    final second = selector().snapshot();

    expect(first.queryStats.totalChecks, greaterThan(0));
    expect(second.queryStats.totalChecks, 0);
    expect(second.queryStats.cacheHits, greaterThan(0));
    expect(second.queryStats.cacheRatio, 1);
    expect(second.discoveredWidget!.data, 'a');
  });

  testWidgets('PredicateFilter defaults to live evaluation', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            children: const [
              Text('a'),
              Text('b'),
            ],
          ),
        ),
      ),
    );

    var selectedText = 'a';
    final selector = WidgetSelector<Text>(
      stages: [
        PredicateFilter(
          predicate: (element) {
            final widget = element.widget;
            return widget is Text && widget.data == selectedText;
          },
          description: 'Text data is selectedText',
        ),
      ],
    );

    final first = selector.snapshot();
    selectedText = 'b';
    final second = selector.snapshot();

    expect(first.discoveredWidget!.data, 'a');
    expect(second.discoveredWidget!.data, 'b');
    expect(second.queryStats.totalChecks, greaterThan(0));
  });

  testWidgets('cache keys reject collection values', (tester) async {
    await tester.pumpWidget(Center());

    void expectInvalidCacheKey(Object key) {
      final selector = WidgetSelector<Widget>(
        stages: [_CollectionCacheKeyFilter(key)],
      );

      expect(
        () => snapshot(selector),
        throwsA(isA<StateError>()),
      );
    }

    expectInvalidCacheKey(<Object>[]);
    expectInvalidCacheKey(<Object>{});
    expectInvalidCacheKey(<Object, Object>{});
  });
}

class _CollectionCacheKeyFilter extends ElementFilter {
  _CollectionCacheKeyFilter(this.key);

  final Object key;

  @override
  Object get cacheKey => key;

  @override
  String get description => 'invalid cache key';

  @override
  Iterable<WidgetTreeNode> filter(Iterable<WidgetTreeNode> candidates) {
    return candidates;
  }
}
