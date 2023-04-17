library spot;

import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

export 'package:spot/src/finder_interop.dart';
export 'package:spot/src/snapshot.dart';
export 'package:spot/src/spotters.dart';

export 'package:spot/src/widgets/text.dart';
export 'package:spot/src/widgets/wrap.dart';

const Spot _global = Spot();

WidgetSelector<Widget> get allWidgets => WidgetSelector.all;

SingleWidgetSelector<W> spot<W extends Widget>({
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spot<W>(
    parents: parents,
    children: children,
  );
}

WidgetSelector<W> spotAll<W extends Widget>({
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotAll<W>(
    parents: parents,
    children: children,
  );
}

SingleWidgetSelector<W> spotWidget<W extends Widget>(
  W widget, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotWidget<W>(
    widget,
    parents: parents,
    children: children,
  );
}

WidgetSelector<W> spotAllWidgets<W extends Widget>(
  W widget, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotAllWidgets<W>(
    widget,
    parents: parents,
    children: children,
  );
}

SingleWidgetSelector<W> spotElement<W extends Widget>(
  Element element, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotElement<W>(element);
}

SingleWidgetSelector spotText(
  String text, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
  bool findRichText = false,
}) {
  return _global.spotText(
    text,
    parents: parents,
    children: children,
    findRichText: findRichText,
  );
}

WidgetSelector spotAllText(
  String text, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
  bool findRichText = false,
}) {
  return _global.spotAllText(
    text,
    parents: parents,
    children: children,
    findRichText: findRichText,
  );
}

SingleWidgetSelector spotIcon(
  IconData icon, {
  bool skipOffstage = true,
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotIcon(
    icon,
    parents: parents,
    children: children,
  );
}

WidgetSelector spotAllIcon(
  IconData icon, {
  bool skipOffstage = true,
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotAllIcon(
    icon,
    parents: parents,
    children: children,
  );
}
