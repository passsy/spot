library spot;

import 'package:flutter/widgets.dart';
import 'package:spot/src/selectors.dart';

export 'package:spot/src/checks/checks.dart' hide it;

export 'package:spot/src/default_selectors.dart';
export 'package:spot/src/effective_text.dart';
export 'package:spot/src/finder_interop.dart';
export 'package:spot/src/selectors.dart'
    show
        WidgetSelector,
        SingleWidgetSelector,
        MultiWidgetSelector,
        SelectorQueries,
        SelectorToSnapshot,
        SingleWidgetSnapshot,
        MultiWidgetSnapshot,
        WidgetMatcher,
        WidgetMatcherExtensions,
        MutliMatchers,
        ElementFilter,
        MatchProp,
        ExpectedQuantity,
        CreateMatchers;
export 'package:spot/src/snapshot.dart'
    show SingleWidgetSelectorMatcher, MultiWidgetSelectorMatcher;

export 'package:spot/src/widgets/align.g.dart';
export 'package:spot/src/widgets/circularprogressindicator.g.dart';
export 'package:spot/src/widgets/column.g.dart';
export 'package:spot/src/widgets/constrainedbox.g.dart';
export 'package:spot/src/widgets/container.g.dart';
export 'package:spot/src/widgets/elevatedbutton.g.dart';
export 'package:spot/src/widgets/floatingactionbutton.g.dart';
export 'package:spot/src/widgets/gridview.g.dart';
export 'package:spot/src/widgets/icon.g.dart';
export 'package:spot/src/widgets/iconbutton.g.dart';
export 'package:spot/src/widgets/image.g.dart';
export 'package:spot/src/widgets/linearprogressindicator.g.dart';
export 'package:spot/src/widgets/listtile.g.dart';
export 'package:spot/src/widgets/opacity.g.dart';
export 'package:spot/src/widgets/outlinedbutton.g.dart';
export 'package:spot/src/widgets/row.g.dart';
export 'package:spot/src/widgets/safearea.g.dart';
export 'package:spot/src/widgets/semantics.g.dart';
export 'package:spot/src/widgets/sizedbox.g.dart';
export 'package:spot/src/widgets/slider.g.dart';
export 'package:spot/src/widgets/switch.g.dart';
export 'package:spot/src/widgets/text.g.dart';
export 'package:spot/src/widgets/textbutton.g.dart';
export 'package:spot/src/widgets/textfield.g.dart';
export 'package:spot/src/widgets/tooltip.g.dart';
export 'package:spot/src/widgets/wrap.g.dart';

const Spot _global = Spot();

WidgetSelector<Widget> get allWidgets => WidgetSelector.all;

/// Creates a chainable [WidgetSelector] that matches a single [Widget] of
/// type [W].
///
/// When executed this [WidgetSelector] will fail when it finds multiple
/// [Widget]s of type [W] in widget tree.
///
/// This selector compares the Widgets by runtimeType rather than by super
/// type (see [WidgetTypeFilter]). This makes sure that e.g. `spotSingle<Align>()`
/// does not accidentally match a [Center] Widget, that extends [Align].
///
/// If multiple Widgets of type [W] are expected, use [spot] instead.
SingleWidgetSelector<W> spotSingle<W extends Widget>({
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotSingle<W>(
    parents: parents,
    children: children,
  );
}

/// Creates a chainable [WidgetSelector] that matches a all Widgets of
/// type [W] in widget tree.
///
/// `spot<SomeWidget>()` is the most common way to chain of selectors. For
/// performance reasons and better error messages, it can be useful to use
/// [spotSingle]. Use [spotSingle] in cases where only ever one Widget is
/// expected. This allows the framework to stop when 100 instead of a
/// 1 widget is found.
///
/// This selector compares the Widgets by runtimeType rather than by super
/// type (see [WidgetTypeFilter]). This makes sure that e.g. `spot<Align>()`
/// does not accidentally match a [Center] Widget, that extends [Align].
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
  return _global.spotElement<W>(element);
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

SingleWidgetSelector<W> spotSingleKey<W extends Widget>(
  Key key, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotSingleKey<W>(
    key,
    parents: parents,
    children: children,
  );
}

MultiWidgetSelector<W> spotKeys<W extends Widget>(
  Key key, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotKeys<W>(
    key,
    parents: parents,
    children: children,
  );
}
