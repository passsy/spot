library spot;

import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';

export 'package:spot/src/finder_interop.dart';
export 'package:spot/src/selectors.dart';
export 'package:spot/src/snapshot.dart';

export 'package:spot/src/widgets/text.dart';
export 'package:spot/src/widgets/wrap.dart';

const Spot _global = Spot();

WidgetSelector<Widget> get allWidgets => WidgetSelector.all;

SingleWidgetSelector<W> spotSingle<W extends Widget>({
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotSingle<W>(
    parents: parents,
    children: children,
  );
}

WidgetSelector<W> spot<W extends Widget>({
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spot<W>(
    parents: parents,
    children: children,
  );
}

SingleWidgetSelector<W> spotSingleWidget<W extends Widget>(
  W widget, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotSingleWidget<W>(
    widget,
    parents: parents,
    children: children,
  );
}

WidgetSelector<W> spotWidgets<W extends Widget>(
  W widget, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotWidgets<W>(
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
  return _global.spotSingleElement<W>(element);
}

SingleWidgetSelector<Text> spotSingleText(
  String text, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
  bool findRichText = false,
}) {
  return _global.spotSingleText(
    text,
    parents: parents,
    children: children,
    findRichText: findRichText,
  );
}

WidgetSelector<Text> spotTexts(
  String text, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
  bool findRichText = false,
}) {
  return _global.spotTexts(
    text,
    parents: parents,
    children: children,
    findRichText: findRichText,
  );
}

SingleWidgetSelector<Icon> spotSingleIcon(
  IconData icon, {
  bool skipOffstage = true,
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotSingleIcon(
    icon,
    parents: parents,
    children: children,
  );
}

WidgetSelector<Icon> spotIcons(
  IconData icon, {
  bool skipOffstage = true,
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotIcons(
    icon,
    parents: parents,
    children: children,
  );
}

SingleWidgetSelector<W> spotKey<W extends Widget>(
  Key key, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotKey<W>(
    key,
    parents: parents,
    children: children,
  );
}
