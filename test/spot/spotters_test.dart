// ignore_for_file: deprecated_member_use_from_same_package, unused_result

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  test('top level spotters match chained spotters', () {
    spot<Center>().spot<Center>();
    spotSingle<Center>().spotSingle<Center>();
    spot<Center>().spot<Center>();
    spotSingleText('hello').spotSingleText('hello');
    spotTexts('hello').spotTexts('hello');
    spotText('hello').spotText('hello');
    spotSingleIcon(Icons.add).spotSingleIcon(Icons.add);
    spotIcons(Icons.add).spotIcons(Icons.add);
    spotSingleWidget(_anyWidget).spotSingleWidget(_anyWidget);
    spotWidgets(_anyWidget).spotWidgets(_anyWidget);
    spotElement(_anyElement).spotElement(_anyElement);
    spotSingleKey(_key).spotSingleKey(_key);
  });
}

final _anyElement = LeafRenderObjectElement(ErrorWidget('ex'));
const _anyWidget = Center();
const _key = ValueKey('key');
