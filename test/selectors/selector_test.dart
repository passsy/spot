import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  testWidgets('.single keeps all information', (tester) async {
    final multiSelector = spot<Center>(
      parents: [spot<Column>()],
      children: [spot<SizedBox>()],
    ).withAlignment(Alignment.center);

    final singleSelector = multiSelector.single;

    expect(multiSelector.parents, singleSelector.parents);
    expect(multiSelector.children, singleSelector.children);
    expect(multiSelector.props, singleSelector.props);
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

    expect(multiSelector.parents, singleSelector.parents);
    expect(multiSelector.children, singleSelector.children);
    expect(multiSelector.props, singleSelector.props);
    expect(multiSelector.mapElementToWidget, singleSelector.mapElementToWidget);
    expect(multiSelector.expectedQuantity, ExpectedQuantity.multi);
    expect(singleSelector.expectedQuantity, ExpectedQuantity.single);

    await tester.pumpWidget(const Center());
    final centerElement = spotSingle<Center>().snapshot().element;

    final multiMap = multiSelector.mapElementToWidget(centerElement);
    final singleMap = singleSelector.mapElementToWidget(centerElement);
    expect(multiMap.runtimeType, singleMap.runtimeType);
  });

  testWidgets('dont lose mapElementToWidget', (tester) async {
    TestWidgetsFlutterBinding.instance!.clock;
    final singleSelector = spotText('home');
    final multiSelector = singleSelector.multi;

    await tester.pumpWidget(const MaterialApp(home: Text('home')));
    final centerElement = spotText('home').snapshot().element;

    final AnyText multiMap = multiSelector.mapElementToWidget(centerElement);
    final AnyText singleMap = singleSelector.mapElementToWidget(centerElement);
    expect(multiMap.runtimeType, singleMap.runtimeType);
  });
}
