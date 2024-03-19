/// Spot is a library for testing the Widget tree of Flutter apps.
library spot;

import 'package:flutter/material.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/spot/selectors.dart' show Spot;
import 'package:spot/src/spot/widget_selector.dart';

export 'package:checks/checks.dart'
    hide
        // it() is an odd API, spot sticks to normal lambdas
        FutureChecks,
        // async checks are not useful for spot
        StreamChecks,
        WithQueueExtension;
export 'package:checks/context.dart'
    show Condition, Context, ContextExtension, Extracted, Rejection, Subject;
export 'package:meta/meta.dart' show useResult;
export 'package:spot/src/act/act.dart' show Act, act;
export 'package:spot/src/screenshot/screenshot.dart'
    show
        ElementScreenshotExtension,
        Screenshot,
        SelectorScreenshotExtension,
        SnapshotScreenshotExtension,
        takeScreenshot;
export 'package:spot/src/spot/default_selectors.dart'
    show DefaultWidgetMatchers, DefaultWidgetSelectors;
export 'package:spot/src/spot/diagnostic_props.dart'
    show DiagnosticPropWidgetMatcher, DiagnosticPropWidgetSelector;
export 'package:spot/src/spot/effective/effective_text.dart'
    show EffectiveTextMatcher, EffectiveTextSelector, TextStyleSubject;
export 'package:spot/src/spot/filters/child_filter.dart' show ChildFilter;
export 'package:spot/src/spot/filters/parent_filter.dart' show ParentFilter;
export 'package:spot/src/spot/filters/predicate_filter.dart'
    show PredicateFilter;
export 'package:spot/src/spot/filters/widget_type_filter.dart'
    show WidgetTypeFilter;
export 'package:spot/src/spot/finder_interop.dart'
    show FinderFilter, FinderToSpot, SpotToFinder;
export 'package:spot/src/spot/matcher_generator.dart' show CreateMatchers;
export 'package:spot/src/spot/props.dart'
    show
        MatchProp,
        MatchPropNonNullable,
        MatchPropNullable,
        NamedElementProp,
        NamedRenderObjectProp,
        NamedWidgetProp,
        PropSelectorQueries,
        WidgetSelectorProp,
        elementProp,
        renderObjectProp,
        widgetProp;
export 'package:spot/src/spot/selectors.dart'
    show
        QuantityMatchers,
        QuantitySelectors,
        ReadSingleSnapshot,
        RelativeSelectors,
        SelectorQueries,
        SelectorToSnapshot;
export 'package:spot/src/spot/snapshot.dart'
    show
        MultiWidgetSelectorMatcher,
        // ignore: deprecated_member_use_from_same_package
        MultiWidgetSnapshot,
        // ignore: deprecated_member_use_from_same_package
        SingleWidgetSnapshot,
        ToWidgetMatcher,
        WidgetSnapshot,
        WidgetSnapshotShorthands;
export 'package:spot/src/spot/text/any_text.dart' show AnyText;
export 'package:spot/src/spot/tree_snapshot.dart'
    show ScopedWidgetTreeSnapshot, WidgetTreeNode;
export 'package:spot/src/spot/widget_matcher.dart'
    show
        MultiWidgetMatcher,
        MultiWidgetMatcherExtensions,
        PropertyCheckFailure,
        WidgetMatcher,
        WidgetMatcherExtensions;
export 'package:spot/src/spot/widget_selector.dart'
    show
        ElementFilter,
        // ignore: deprecated_member_use_from_same_package
        ExpectedQuantity,
        // ignore: deprecated_member_use_from_same_package
        MultiWidgetSelector,
        MutateStages,
        QuantityConstraint,
        // ignore: deprecated_member_use_from_same_package
        SingleWidgetSelector,
        WidgetSelector;
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
@Deprecated('Use spotAllWidgets()')
WidgetSelector<Widget> get allWidgets => WidgetSelector.all;

/// A WidgetSelector that matches all widgets in the widget tree.
///
/// ```
/// final globalKeyWidgets = spotAllWidgets()
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
WidgetSelector<Widget> spotAllWidgets() => WidgetSelector.all;

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
@useResult
@Deprecated('Use spot<W>().atMost(1)')
WidgetSelector<W> spotSingle<W extends Widget>({
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
/// `spot<SomeWidget>()` is the most common way to chain selectors.
///
/// This selector compares the Widgets by runtimeType rather than by super
/// type (see [WidgetTypeFilter]). This makes sure that e.g. `spot<Align>()`
/// does not accidentally match a [Center] Widget, that extends [Align].
@useResult
WidgetSelector<W> spot<W extends Widget>({
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spot<W>(
    parents: parents,
    children: children,
  );
}

/// Creates a [WidgetSelector] that includes only offstage widgets in the selection.
///
/// Offstage widgets are those that are not currently visible on the screen,
/// but are still part of the widget tree. This can be useful when you want to
/// select and perform operations on widgets that are not currently visible to the user.
///
/// Returns a new [WidgetSelector] that includes offstage widgets.
///
/// ### Example usage:
/// ```dart
/// final text = spotOffstage()
///   .spotText('text');
/// ```
@useResult
WidgetSelector<Widget> spotOffstage({
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return WidgetSelector(
    stages: [
      PredicateFilter(
        predicate: (e) => true,
        description: 'any Offstage Widget',
      ),
    ],
    visibilityMode: VisibilityMode.offstage,
  );
}

/// Creates a [WidgetSelector] that finds [widget] by identity and returns all
/// occurrences of it in the widget tree
///
/// The comparison happens by identity (===)
WidgetSelector<W> spotWidget<W extends Widget>(
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

/// Creates a chainable [WidgetSelector] that matches a single [Widget] by
/// identity
@useResult
@Deprecated('Use spotWidget<W>().atMost(1)')
WidgetSelector<W> spotSingleWidget<W extends Widget>(
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
@useResult
@Deprecated('Use spotWidget<W>()')
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
@useResult
WidgetSelector<W> spotElement<W extends Widget>(
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
@useResult
WidgetSelector<AnyText> spotText(
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
@useResult
WidgetSelector<AnyText> spotTextWhere(
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
@useResult
WidgetSelector<W> spotSingleText<W extends Widget>(
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
/// To find [SelectableText] Widgets, use
/// `spotSingle<SelectableText>(children: [spotTexts('foo')])`
/// which finds a [SelectableText] Widget that contains an [EditableText]
/// with 'foo'.
@Deprecated(
  'Use spotText("Hello") or '
  'spot<Text>().whereText((it) => it.equals("Hello")) instead',
)
@useResult
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

/// Creates a chainable [WidgetSelector] that finds an [Icon] based on [IconData]
/// [icon]
@useResult
@Deprecated('Use spotIcon<W>().atMost(1)')
WidgetSelector<Icon> spotSingleIcon(
  IconData icon, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotSingleIcon(
    icon,
    parents: parents,
    children: children,
  );
}

/// Creates a chainable [WidgetSelector] that finds a [Icon] based on [IconData]
/// [icon]
@useResult
WidgetSelector<Icon> spotIcon(
  IconData icon, {
  List<WidgetSelector> parents = const [],
  List<WidgetSelector> children = const [],
}) {
  return _global.spotIcon(
    icon,
    parents: parents,
    children: children,
  );
}

/// Creates a chainable [WidgetSelector] that finds all widgets of type [Icon]
/// that have [icon] as [IconData]
@useResult
@Deprecated('Use spotIcon()')
WidgetSelector<Icon> spotIcons(
  IconData icon, {
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
@useResult
@Deprecated('Use spotKey().atMost(1)')
WidgetSelector<W> spotSingleKey<W extends Widget>(
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

/// Creates a chainable [WidgetSelector] that finds a widget with the given [key].
@useResult
WidgetSelector<W> spotKey<W extends Widget>(
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

/// Creates a chainable [WidgetSelector] that finds all widgets with the given
/// [key].
@useResult
@Deprecated('Use spotKey()')
WidgetSelector<W> spotKeys<W extends Widget>(
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
