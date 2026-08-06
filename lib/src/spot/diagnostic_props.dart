import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/selectors.dart';
import 'package:spot/src/spot/widget_matcher.dart';

/// All [DiagnosticsProperty] related selectors
extension DiagnosticPropWidgetSelector<W extends Widget> on WidgetSelector<W> {
  /// Filters widgets by their [DiagnosticsProperty] with [propName] that matches [match]
  ///
  /// #### Example usage:
  /// ```dart
  /// spot<Container>().existsOnce()
  ///   .withDiagnosticProp<double>('margin', (it) => it.equals(EdgeInsets.zero));
  /// ```
  ///
  /// #### Auto-generated selectors
  ///
  /// The official Flutter widgets already offer a lot of selectors based on their diagnostic properties.
  /// The Container example above can be written as:
  /// ```dart
  /// spot<Container>().existsOnce().hasMargin(EdgeInsets.zero);
  /// ```
  ///
  /// For non-supported Flutter widgets, use [printMatchers] to generate the selectors and matchers based on the existing diagnostic properties.
  /// ```dart
  /// // print to console
  /// spot<Container>().printMatchers();
  ///
  /// // write the Dart file directly
  /// spot<Container>().writeMatchersToFile(path: 'test/container.g.dart');
  /// ```
  @useResult
  WidgetSelector<W> withDiagnosticProp<T>(
    String propName,
    MatchProp<T> match,
  ) {
    void condition(Subject<T?> subject) {
      subject.hideNullability().context.nest<T>(
            () => ['with prop "$propName"'],
            (value) => Extracted.value(value),
          );
      match(subject.hideNullability());
    }

    final name = describe(condition).map((it) => it.trim()).toList().join(' ');

    return whereElement(
      (element) {
        final DiagnosticsNode? prop =
            _diagnosticProps(element, mapElementToWidget)
                .firstOrNullWhere((e) => e.name == propName);

        final actual = prop?.value as T? ?? prop?.getDefaultValue<T>();

        void condition(Subject<T?> subject) {
          subject.context.nest<T>(
            () => [
              removeQuantityConstraints().toStringBreadcrumb(),
              'with prop "$propName"',
            ],
            (value) {
              if (prop == null) {
                return Extracted.rejection(which: ['Has no prop "$propName"']);
              }
              if (value is! T) {
                return Extracted.rejection(
                  which: [
                    'Has no prop "$propName" of type "$T", the type is "${prop.value.runtimeType}"',
                  ],
                );
              }

              return Extracted.value(actual as T);
            },
          );
          match(subject.hideNullability());
        }

        final failure = softCheckHideNull(actual, condition);
        if (failure != null) {
          return false;
        }

        return true;
      },
      description: name,
    );
  }
}

/// All [DiagnosticsProperty] related matchers
extension DiagnosticPropWidgetMatcher<W extends Widget> on WidgetMatcher<W> {
  /// Retrieves the [DiagnosticsProperty] of the matched widget with [propName] of type [T]
  ///
  /// #### Example usage:
  /// ```dart
  /// final checked = spot<Checkbox>().existsOnce().getDiagnosticProp<bool>('value');
  /// ```
  T getDiagnosticProp<T>(String propName) {
    final DiagnosticsNode? prop =
        _diagnosticProps(element, selector.mapElementToWidget)
            .firstOrNullWhere((e) => e.name == propName);
    final actual = prop?.value as T? ?? prop?.getDefaultValue<T>();
    return actual as T;
  }

  /// Asserts that a widget has a specific diagnostic property.
  ///
  /// Useful for testing properties that are part of a widget's diagnostics.
  WidgetMatcher<W> hasDiagnosticProp<T>(
    String propName,
    MatchProp<T> match,
  ) {
    final DiagnosticsNode? prop =
        _diagnosticProps(element, selector.mapElementToWidget)
            .firstOrNullWhere((e) => e.name == propName);

    final actual = prop?.value as T? ?? prop?.getDefaultValue<T>();
    void condition(Subject<T?> subject) {
      subject.context.nest<T>(
        () => [
          selector.removeQuantityConstraints().toStringBreadcrumb(),
          'with property $propName',
        ],
        (value) {
          if (prop == null) {
            return Extracted.rejection(which: ['Has no prop "$propName"']);
          }
          if (value is! T) {
            return Extracted.rejection(
              which: [
                'Has no prop "$propName" of type "$T", the type is "${prop.value.runtimeType}"',
              ],
            );
          }
          return Extracted.value(value);
        },
      );
      match(subject.hideNullability());
    }

    final failure = softCheckHideNull(actual, condition);
    failure.throwPropertyCheckFailure(condition, element);
    return this;
  }
}

/// The [DiagnosticsProperty]s of the widget [mapElementToWidget] derives from
/// [element], cached on that widget.
///
/// [Widget.toDiagnosticsNode] returns a fresh node on every call, and each node
/// only caches [DiagnosticsNode.getProperties] for itself. Without this cache
/// every matcher in a chain re-runs `debugFillProperties` for the same widget,
/// and so does every query that inspects a widget an earlier query already
/// inspected.
///
/// Keyed on the derived widget itself, which is the only thing the properties
/// depend on. A [Widget] is immutable, so what it fills in cannot change while
/// the instance lives; a rebuild creates a new instance and with it a new
/// entry. Nothing here needs invalidating.
///
/// A [WidgetSelector] that synthesizes a widget per call gets a new entry per
/// call and never a hit — correct, just uncached. The [AnyText] selectors
/// behind [spotText] are the ones that would pay for that, which is why
/// [AnyTextWidgetSelector] hands out the same instance for an element until
/// something it was derived from changes.
List<DiagnosticsNode> _diagnosticProps(
  Element element,
  Widget Function(Element element) mapElementToWidget,
) {
  final widget = mapElementToWidget(element);
  return _propsCache[widget] ??=
      List.unmodifiable(widget.toDiagnosticsNode().getProperties());
}

/// The [DiagnosticsProperty]s of a [Widget], for as long as that widget lives.
///
/// An [Expando] because the keys are widgets of a tree the test may tear down
/// at any point, and holding them here must not keep them alive.
///
/// The lists are unmodifiable because every caller in the process now reads the
/// same instance.
final Expando<List<DiagnosticsNode>> _propsCache = Expando();

extension on DiagnosticsNode {
  T? getDefaultValue<T>() {
    try {
      if (this is DiagnosticsProperty) {
        return (this as DiagnosticsProperty).defaultValue as T?;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
