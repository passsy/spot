// ignore_for_file: deprecated_member_use_from_same_package, unused_result

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';

void main() {
  test('top level spotters match chained spotters', () {
    spot<Center>().spot<Center>();
    spotSingle<Center>().spotSingle<Center>(); // deprecated

    spotText('hello').spotText('hello');
    spotTexts('hello').spotTexts('hello'); // deprecated
    spotSingleText('hello').spotSingleText('hello'); // deprecated

    spotIcon(Icons.add).spotIcon(Icons.add);
    spotIcons(Icons.add).spotIcons(Icons.add); // deprecated
    spotSingleIcon(Icons.add).spotSingleIcon(Icons.add); // deprecated

    spotWidget(_anyWidget).spotWidget(_anyWidget);
    spotWidgets(_anyWidget).spotWidgets(_anyWidget); // deprecated
    spotSingleWidget(_anyWidget).spotSingleWidget(_anyWidget); // deprecated

    spotElement(_anyElement).spotElement(_anyElement);

    spotKey(_key).spotKey(_key);
    spotKeys(_key).spotKeys(_key); // deprecated
    spotSingleKey(_key).spotSingleKey(_key); // deprecated
  });
}

final _anyElement = LeafRenderObjectElement(ErrorWidget('ex'));
const _anyWidget = Center();
const _key = ValueKey('key');
