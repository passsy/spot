import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  test('top level spotters match chained spotters', () {
    spot<Center>().spot<Center>();
    spot<Center>().spot<Center>();
    spotAll<Center>().spotAll<Center>();
    spotText('hello').spotText('hello');
    spotAllText('hello').spotAllText('hello');
    spotIcon(Icons.add).spotIcon(Icons.add);
    spotAllIcon(Icons.add).spotAllIcon(Icons.add);
    spotWidget(_anyWidget).spotWidget(_anyWidget);
    spotAllWidgets(_anyWidget).spotAllWidgets(_anyWidget);
    spotElement(_anyElement).spotElement(_anyElement);
  });
}

final _anyElement = LeafRenderObjectElement(ErrorWidget('ex'));
const _anyWidget = Center();
