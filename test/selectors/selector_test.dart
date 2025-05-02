// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

import '../util/assert_error.dart';

void main() {
  testWidgets('.single keeps all information', (tester) async {
    final multiSelector = spot<Center>(
      parents: [spot<Column>()],
      children: [spot<SizedBox>()],
    ).withAlignment(Alignment.center);

    final singleSelector = multiSelector.single;

    expect(multiSelector.mapElementToWidget, singleSelector.mapElementToWidget);
    expect(singleSelector.expectedQuantity, ExpectedQuantity.single);
    expect(multiSelector.expectedQuantity, ExpectedQuantity.multi);
  });

  testWidgets('.multi keeps all information', (tester) async {
    final singleSelector = spotSingle<Center>(
      parents: [spot<Column>()],
      children: [spot<SizedBox>()],
    ).withAlignment(Alignment.center);

    final multiSelector = singleSelector.multi;

    expect(multiSelector.mapElementToWidget, singleSelector.mapElementToWidget);
    expect(multiSelector.quantityConstraint, QuantityConstraint.unconstrained);
    expect(singleSelector.quantityConstraint, QuantityConstraint.single);
    expect(multiSelector.expectedQuantity, ExpectedQuantity.multi);
    expect(singleSelector.expectedQuantity, ExpectedQuantity.single);

    await tester.pumpWidget(const Center());
    final centerElement = spotSingle<Center>().snapshot().element!;

    final multiMap = multiSelector.mapElementToWidget(centerElement);
    final singleMap = singleSelector.mapElementToWidget(centerElement);
    expect(multiMap.runtimeType, singleMap.runtimeType);
  });

  testWidgets('WidgetSelector API', (tester) async {
    await tester.pumpWidget(const Center());
    final WidgetSelector<Center> selector = spot<Center>();
    final Type type = selector.type;
    expect(type, isNotNull);
    final List<ElementFilter> stages = selector.stages;
    expect(stages, isNotNull);
    final ExpectedQuantity expectedQuantity = selector.expectedQuantity;
    expect(expectedQuantity, isNotNull);
    final MultiWidgetSnapshot<Center> snapshot = selector.snapshot();
    expect(snapshot, isNotNull);
    final Center Function(Element element) mapElementToWidget =
        selector.mapElementToWidget;
    expect(mapElementToWidget, isNotNull);
    final String stringBreadcrumb = selector.toStringBreadcrumb();
    expect(stringBreadcrumb, isNotNull);
    final WidgetSelector<Center> self = selector.self;
    expect(self, isNotNull);
    final WidgetSelector<Center> copyWith = selector.copyWith();
    expect(copyWith, isNotNull);
    final WidgetSelector<Center> withProp =
        selector.withProp(match: (it) => it, widgetSelector: (it) => it);
    expect(withProp, isNotNull);
    final WidgetSelector<Center> withDiagnosticProp =
        selector.withDiagnosticProp('a', (it) => it);
    expect(withDiagnosticProp, isNotNull);
  });

  testWidgets("don't lose mapElementToWidget", (tester) async {
    final singleSelector = spotText("home").single;
    final multiSelector = singleSelector.multi;

    await tester.pumpWidget(const MaterialApp(home: Text('home')));
    final centerElement = spotText('home').existsOnce().element;

    final AnyText multiMap = multiSelector.mapElementToWidget(centerElement);
    final AnyText singleMap = singleSelector.mapElementToWidget(centerElement);
    expect(multiMap.runtimeType, singleMap.runtimeType);
  });

  testWidgets('snapshotWidget() zero widgets', (tester) async {
    expect(
      () => spotText('unknown').snapshotWidget(),
      throwsSpotErrorContaining([
        'Could not find Widget with text contains text "unknown" in widget tree'
      ]),
    );
  });

  testWidgets('snapshotWidget() one widget', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Text('home')));
    final widget = spotText('home').snapshotWidget();
    expect(widget.text, 'home');
  });

  testWidgets('snapshotWidget() multiple widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            Text('home'),
            Text('home'),
          ],
        ),
      ),
    );
    expect(
      () => spotText('home').snapshotWidget(),
      throwsSpotErrorContaining([
        'Found 2 elements matching Widget with text contains text "home" in widget tree, expected at most 1'
      ]),
    );
  });

  testWidgets('snapshotState() zero widgets', (tester) async {
    expect(
      () => spot<_MyContainer>().snapshotState(),
      throwsSpotErrorContaining(['Could not find _MyContainer in widget tree']),
    );
  });

  testWidgets('snapshotState() one widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: _MyContainer(color: Colors.red)),
    );
    final state = spot<_MyContainer>().snapshotState<_MyContainerState>();
    expect(state.innerValue, 'stateValue');

    // Test for non-stateful widget
    await tester.pumpWidget(const MaterialApp(home: Text('test')));
    expect(
      () => spot<DefaultTextStyle>().snapshotState(),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          'DefaultTextStyle is not a StatefulWidget and does not have a State',
        ),
      ),
    );
  });

  testWidgets('snapshotState() multiple widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            _MyContainer(color: Colors.red),
            _MyContainer(color: Colors.blue),
          ],
        ),
      ),
    );
    expect(
      () => spot<_MyContainer>().snapshotState(),
      throwsSpotErrorContaining([
        'Found 2 elements matching _MyContainer in widget tree, expected at most 1'
      ]),
    );
  });

  testWidgets('snapshotElement() zero widgets', (tester) async {
    expect(
      () => spotText('unknown').snapshotElement(),
      throwsSpotErrorContaining([
        'Could not find Widget with text contains text "unknown" in widget tree'
      ]),
    );
  });

  testWidgets('snapshotElement() one widget', (tester) async {
    await tester.pumpWidget(
      WidgetsApp(
        builder: (_, __) => const Center(child: Text('home')),
        color: Colors.red,
      ),
    );
    final element = spotText('home').snapshotElement();
    expect(element.widget, isA<RichText>());
    expect(element.size?.height, 14);
  });

  testWidgets('snapshotElement() multiple widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            Text('home'),
            Text('home'),
          ],
        ),
      ),
    );
    expect(
      () => spotText('home').snapshotElement(),
      throwsSpotErrorContaining([
        'Found 2 elements matching Widget with text contains text "home" in widget tree, expected at most 1'
      ]),
    );
  });

  testWidgets('snapshotRenderObject() zero widgets', (tester) async {
    expect(
      () => spotText('unknown').snapshotRenderObject(),
      throwsSpotErrorContaining([
        'Could not find Widget with text contains text "unknown" in widget tree'
      ]),
    );
  });

  testWidgets('snapshotRenderObject() one widget', (tester) async {
    await tester.pumpWidget(
      WidgetsApp(
        builder: (_, __) => const Center(child: Text('home')),
        color: Colors.red,
      ),
    );
    final renderObject = spotText('home').snapshotRenderObject();
    expect(renderObject, isNotNull);
    expect(renderObject.isRepaintBoundary, isFalse);
  });

  testWidgets('snapshotRenderObject() multiple widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            Text('home'),
            Text('home'),
          ],
        ),
      ),
    );
    expect(
      () => spotText('home').snapshotRenderObject(),
      throwsSpotErrorContaining([
        'Found 2 elements matching Widget with text contains text "home" in widget tree, expected at most 1'
      ]),
    );
  });

  testWidgets('snapshotRenderBox() zero widgets', (tester) async {
    expect(
      () => spotText('unknown').snapshotRenderBox(),
      throwsSpotErrorContaining([
        'Could not find Widget with text contains text "unknown" in widget tree'
      ]),
    );
  });

  testWidgets('snapshotRenderBox() one widget', (tester) async {
    await tester.pumpWidget(
      WidgetsApp(
        builder: (_, __) => const Center(child: Text('home')),
        color: Colors.red,
      ),
    );
    final renderBox = spotText('home').snapshotRenderBox();
    expect(renderBox, isA<RenderBox>());
    expect(renderBox.localToGlobal(Offset.zero), const Offset(372.0, 293.0));
  });

  testWidgets('snapshotRenderBox() multiple widgets', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            Text('home'),
            Text('home'),
          ],
        ),
      ),
    );
    expect(
      () => spotText('home').snapshotRenderBox(),
      throwsSpotErrorContaining([
        'Found 2 elements matching Widget with text contains text "home" in widget tree, expected at most 1'
      ]),
    );
  });
}

class _MyContainer extends StatefulWidget {
  const _MyContainer({required this.color});

  final Color color;

  @override
  State<_MyContainer> createState() => _MyContainerState();
}

class _MyContainerState extends State<_MyContainer> {
  final innerValue = 'stateValue';
  @override
  Widget build(BuildContext context) {
    return Placeholder(color: widget.color);
  }
}
