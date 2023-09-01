/// Spot is a library for testing the Widget tree of Flutter apps.
library spot;

import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/selectors.dart' show Spot;

export 'package:checks/checks.dart'
    hide
        // it() is an odd API, spot sticks to normal lambdas
        FutureChecks,
        // async checks are not useful for spot
        StreamChecks,
        WithQueueExtension,
        it;
export 'package:checks/context.dart'
    show
        Condition,
        ConditionSubject,
        Context,
        ContextExtension,
        Extracted,
        Rejection,
        Subject;

export 'package:spot/src/act/act.dart';
export 'package:spot/src/screenshot/screenshot.dart';
export 'package:spot/src/spot/default_selectors.dart';
export 'package:spot/src/spot/effective/effective_text.dart';
export 'package:spot/src/spot/finder_interop.dart';
export 'package:spot/src/spot/selectors.dart'
    show
        CreateMatchers,
        ElementFilter,
        ExpectedQuantity,
        MatchProp,
        MultiWidgetSelector,
        MultiWidgetSnapshot,
        MutliMatchers,
        QuantityMatchers,
        SelectorQueries,
        SelectorToSnapshot,
        SingleWidgetSelector,
        SingleWidgetSnapshot,
        WidgetMatcher,
        WidgetMatcherExtensions,
        WidgetSelector;
export 'package:spot/src/spot/snapshot.dart'
    show MultiWidgetSelectorMatcher, SingleWidgetSelectorMatcher;
export 'package:spot/src/spot/text/any_text.dart' show AnyText;
export 'package:spot/src/spot/tree_snapshot.dart' show WidgetTreeNode;

export 'package:spot/src/widgets/align.g.dart';
export 'package:spot/src/widgets/anytext.g.dart';
export 'package:spot/src/widgets/circularprogressindicator.g.dart';
export 'package:spot/src/widgets/column.g.dart';
export 'package:spot/src/widgets/constrainedbox.g.dart';
export 'package:spot/src/widgets/container.g.dart';
export 'package:spot/src/widgets/editabletext.g.dart';
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
export 'package:spot/src/widgets/selectabletext.g.dart';
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

/// A WidgetSelector that matches all widgets in the widget tree.
///
/// ```
/// final globalKeyWidgets = allWidgets
///     .whereWidget(
///       (widget) => widget.key is GlobalKey,
///       description: 'with GlobalKey',
///     )
///     .snapshot();
/// print(globalKeyWidgets.discoveredWidgets);
/// // [View-[GlobalObjectKey TestFlutterView#81689],
/// // WidgetsApp-[GlobalObjectKey _MaterialAppState#5b870],
/// // ...
/// ```
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

/// Creates a chainable [WidgetSelector] that matches a single [Widget] by
/// identity
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

/// Creates a chainable [WidgetSelector] that finds all [widget] by identity
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

/// Creates a chainable [WidgetSelector] that finds the widget that is currently
/// associated to the given [element].
SingleWidgetSelector<W> spotElement<W extends Widget>(
  Element element, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotElement<W>(element);
}

/// Finds text on the screen
///
/// [spotText] compares text using 'contains'. For more control over the
/// comparison, use [spotTextWhere] or set [exact] to `true`.
///
/// This method combines finding of [Text], [EditableText] and [SelectableText]
/// widgets. Ultimately, all widgets show text as [RichText] widget.
///
/// For assertions against specific text widgets and their properties, use the
/// normal [spot] method and set the text widget type as generic type argument.
///
/// ```dart
/// final welcome = spot<Text>().whereText((it) => it.equals("Hello"));
/// welcome.first().snapshot().hasMaxLines(1).hasTextAlign(TextAlign.center);
/// ```
SingleWidgetSelector<AnyText> spotText(
  Pattern text, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
  bool exact = false,
}) {
  return _global.spotText(
    text,
    parents: parents,
    children: children,
    exact: exact,
  );
}

/// Finds text matching [match] on the screen
///
/// This methods gives more control how the text is matched compared to [spotText].
///
/// ``` dart
/// Text('Hello World');
///
/// // all match the Text widget above
/// spotTextWhere((it) => it.equals('Hello World'));
/// spotTextWhere((it) => it.startsWith('Hello'));
/// spotTextWhere((it) => it.endsWith('World!'));
/// spotTextWhere((it) => it.contains('Wo'));
/// spotText('Wo');
/// ```
SingleWidgetSelector<AnyText> spotTextWhere(
  void Function(Subject<String>) match, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotTextWhere(
    match,
    parents: parents,
    children: children,
  );
}

/// Either finds [Text] or [EditableText] Widgets.
///
/// Set [findRichText] to true to also find [RichText] Widgets.
///
/// To find [SelectableText] Widgets, use `spotSingle<SelectableText>(children: [spotTexts('foo')])`
/// which finds a [SelectableText] Widget that contains an [EditableText] with 'foo'.
@Deprecated(
  'Use spotText("Hello") or '
  'spot<Text>().whereText((it) => it.equals("Hello")).first() instead',
)
SingleWidgetSelector<W> spotSingleText<W extends Widget>(
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

/// Either finds [Text] or [EditableText] Widgets (set [W] accordingly).
///
/// Set [findRichText] to true to also find [RichText] Widgets.
///
/// To find [SelectableText] Widgets, use `spotSingle<SelectableText>(children: [spotTexts('foo')])`
/// which finds a [SelectableText] Widget that contains an [EditableText] with 'foo'.
@Deprecated(
  'Use spotText("Hello") or '
  'spot<Text>().whereText((it) => it.equals("Hello")) instead',
)
WidgetSelector<W> spotTexts<W extends Widget>(
  String text, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
  bool findRichText = false,
}) {
  return _global.spotTexts<W>(
    text,
    parents: parents,
    children: children,
    findRichText: findRichText,
  );
}

/// Creates a chainable [WidgetSelector] that finds a [Icon] based on [IconData]
/// [icon]
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

/// Creates a chainable [WidgetSelector] that finds all widgets of type [Icon]
/// that have [icon] as [IconData]
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

/// Creates a chainable [WidgetSelector] that finds a widget with the given [key].
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

/// Creates a chainable [WidgetSelector] that finds all widgets with the given
/// [key].
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
