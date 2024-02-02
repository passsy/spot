import 'package:checks/checks.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/prop_element_filter.dart';
import 'package:spot/src/spot/selectors.dart';
import 'package:spot/src/spot/widget_selector.dart';

extension WidgetSelectorProp<W extends Widget> on WidgetSelector<W> {
  /// Filters all elements that match the selector
  ///
  /// Not yet deprecated, but it is recommend to use `whereWidgetProp()` instead.
  /// - [SelectorQueries.whereWidgetProp]
  /// - [SelectorQueries.whereElementProp]
  /// - [SelectorQueries.whereRenderObjectProp]
  ///
  /// #### Example usage:
  /// ```dart
  /// withProp(
  ///   selector: (subject) => subject.context.nest<int?>(
  ///     () => ['with "maxLines"'],
  ///     (Element element) => Extracted.value(_extractMaxLines(element)),
  ///   ),
  ///   match: (maxLines) => maxLines.equals(1),
  /// );
  /// ```
  @useResult
  WidgetSelector<W> withProp<T>({
    @Deprecated('use elementSelector instead')
    Subject<T> Function(ConditionSubject<Element>)? selector,
    Subject<T> Function(ConditionSubject<Element>)? elementSelector,
    Subject<T> Function(Subject<W>)? widgetSelector,
    required MatchProp<T> match,
  }) {
    final ConditionSubject<Element> elementSubject = it<Element>();
    final Subject<T> subject = () {
      if (selector != null) {
        return selector(elementSubject);
      }
      if (elementSelector != null) {
        return elementSelector(elementSubject);
      }
      if (widgetSelector != null) {
        final Subject<W> widgetSubject = elementSubject.context.nest<W>(
          () => [],
          (element) {
            final widget = mapElementToWidget(element);
            return Extracted.value(widget);
          },
        );
        return widgetSelector.call(widgetSubject);
      }

      throw ArgumentError(
        'Either elementSelector (former selector) or widgetSelector must be set',
      );
    }();

    match(subject);
    final name =
        describe(elementSubject).map((it) => it.trim()).toList().join(' ');

    return whereElement(
      (element) {
        final failure = softCheckHideNull(element, elementSubject);
        if (failure != null) {
          return false;
        }
        return true;
      },
      description: name,
    );
  }
}

extension PropSelectorQueries<W extends Widget> on ChainableSelectors<W> {
  /// Creates a filter for the widgets of the discovered elements which is
  /// applied when the [WidgetSelector] is snapshotted.
  ///
  /// #### Example usage:
  /// ```dart
  /// spotSingle<Checkbox>()
  ///   .whereWidgetProp(
  ///     prop: widgetProp('isChecked', (widget) => widget.value),
  ///     match: (value) => value == true,
  ///   ).existsOnce();
  /// ```
  @useResult
  WidgetSelector<W> whereWidgetProp<T>(
    NamedWidgetProp<W, T> prop,
    bool Function(T value) match,
  ) {
    return self!.addStage(
      PropFilter(
        predicate: (Element element) {
          final widget = self!.mapElementToWidget(element);
          final value = prop.get(widget);
          return match(value);
        },
        description: prop.name,
      ),
    );
  }

  /// Creates a filter for the elements of the discovered widgets based on
  /// a specified property. The filter is applied when the [WidgetSelector] is
  /// snapshotted.
  ///
  /// #### Example usage:
  /// ```dart
  /// spotSingle<Checkbox>()
  ///   .whereElementProp<bool>(
  ///     prop: elementProp('isFocused', (element) => element.isFocused),
  ///     match: (isFocused) => isFocused == true,
  ///   ).existsOnce();
  /// ```
  @useResult
  WidgetSelector<W> whereElementProp<T>(
    NamedElementProp<T> prop,
    bool Function(T value) match,
  ) {
    return self!.addStage(
      PropFilter(
        predicate: (Element element) {
          final value = prop.get(element);
          return match(value);
        },
        description: prop.name,
      ),
    );
  }

  /// Creates a filter for the render objects of the discovered widgets based on
  /// a specified property. This filter is applied when the [WidgetSelector] is
  /// snapshotted.
  ///
  /// Useful for selecting widgets based on specific properties of their render
  /// objects. Provide a [NamedRenderObjectProp] and a matching function.
  ///
  /// #### Example usage:
  /// ```dart
  /// spotSingle<Checkbox>()
  ///   .whereRenderObjectProp<double, RenderBox>(
  ///     prop: renderObjectProp('opacity', (ro) => ro.opacity),
  ///     match: (opacity) => opacity > 0.5,
  ///   ).existsOnce();
  /// ```
  @useResult
  WidgetSelector<W> whereRenderObjectProp<T, R extends RenderObject>(
    NamedRenderObjectProp<R, T> prop,
    bool Function(T value) match,
  ) {
    return self!.addStage(
      PropFilter(
        predicate: (Element element) {
          final renderObject = element.renderObject;
          if (renderObject is R) {
            final value = prop.get(renderObject);
            return match(value);
          }
          return false;
        },
        description: prop.name,
      ),
    );
  }
}

/// A Function that fires checks against [T] using the [Subject] API
///
/// The [Subject] keeps the error states and is further processed
typedef MatchProp<T> = void Function(Subject<T>);

/// Extension on [MatchProp<T>] to handle nullable types.
///
/// Provides methods to convert a matcher of nullable types to a matcher of
/// non-nullable types, ensuring nullability is appropriately handled in
/// matchers.
extension MatchPropNullable<T> on MatchProp<T> {
  /// Converts a [MatchProp<T>] to [MatchProp<T?>], hiding its nullability.
  MatchProp<T?> hideNullability() {
    return (Subject<T?> subject) {
      this.call(subject.hideNullability());
    };
  }
}

/// Extension on [MatchProp<T?>] to handle non-nullable types.
///
/// Provides methods to convert a matcher of non-nullable types to a matcher of
/// nullable types, ensuring nullability is appropriately handled in matchers.
extension MatchPropNonNullable<T> on MatchProp<T?> {
  /// Converts a [MatchProp<T?>] to [MatchProp<T>], revealing its nullability.
  MatchProp<T> revealNullability() {
    return (Subject<T> subject) {
      this.call(subject.revealNullability());
    };
  }
}

/// A property of a Widget with a [name] that can be extracted with [get].
///
/// Use with [WidgetMatcherExtensions.hasWidgetProp] or [SelectorQueries.whereWidgetProp].
NamedWidgetProp<W, T> widgetProp<W extends Widget, T>(
  String name,
  T Function(W widget) get,
) {
  return NamedWidgetProp._(name: name, get: get);
}

/// A property of a widget that can be extracted from the widget.
///
/// Use [widgetProp] to create a [NamedWidgetProp].
class NamedWidgetProp<W extends Widget, T> {
  /// The name of the widget property.
  final String name;

  /// The function that extracts the property from a widget.
  final T Function(W widget) get;

  NamedWidgetProp._({
    required this.name,
    required this.get,
  });
}

/// A property of an Element with a [name] that can be extracted with [get].
///
/// Use with [WidgetMatcherExtensions.hasElementProp] or [SelectorQueries.whereElementProp].
NamedElementProp<T> elementProp<T>(
  String name,
  T Function(Element element) get,
) {
  return NamedElementProp._(name: name, get: get);
}

/// A property of an element that can be extracted from the element.
///
/// Use [elementProp] to create a [NamedElementProp].
class NamedElementProp<T> {
  /// The name of the element property.
  final String name;

  /// The function that extracts the property from an element.
  final T Function(Element element) get;

  NamedElementProp._({
    required this.name,
    required this.get,
  });
}

/// A property of a RenderObject with a [name] that can be extracted with [get].
///
/// Use with [WidgetMatcherExtensions.hasRenderObjectProp] or [SelectorQueries.whereRenderObjectProp].
NamedRenderObjectProp<R, T> renderObjectProp<T, R extends RenderObject>(
  String name,
  T Function(R renderObject) get,
) {
  return NamedRenderObjectProp._(name: name, get: get);
}

/// A property of a render object that can be extracted from the render object.
///
/// Use [renderObjectProp] to create a [NamedRenderObjectProp].
class NamedRenderObjectProp<R extends RenderObject, T> {
  /// The name of the render object property.
  final String name;

  /// The function that extracts the property from a render object.
  final T Function(R renderObject) get;

  NamedRenderObjectProp._({
    required this.name,
    required this.get,
  });
}
