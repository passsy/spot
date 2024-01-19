import 'package:flutter/widgets.dart';
import 'package:spot/src/spot/selectors.dart';

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
