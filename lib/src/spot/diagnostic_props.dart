import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/spot/props.dart';
import 'package:spot/src/spot/selectors.dart';
import 'package:spot/src/spot/widget_matcher.dart';
import 'package:spot/src/spot/widget_selector.dart';

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
        final diagnosticsNode = mapElementToWidget(element).toDiagnosticsNode();
        final DiagnosticsNode? prop = diagnosticsNode
            .getProperties()
            .firstOrNullWhere((e) => e.name == propName);

        final unconstrainedSelector =
            overrideQuantityConstraint(QuantityConstraint.unconstrained);
        final actual = prop?.value as T? ?? prop?.getDefaultValue<T>();

        void condition(Subject<T?> subject) {
          subject.context.nest<T>(
            () => [
              unconstrainedSelector.toStringBreadcrumb(),
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
    final diagnosticsNode =
        selector.mapElementToWidget(element).toDiagnosticsNode();
    final DiagnosticsNode? prop = diagnosticsNode
        .getProperties()
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
    final diagnosticsNode = widget.toDiagnosticsNode();
    final DiagnosticsNode? prop = diagnosticsNode
        .getProperties()
        .firstOrNullWhere((e) => e.name == propName);

    final unconstrainedSelector =
        selector.overrideQuantityConstraint(QuantityConstraint.unconstrained);
    final actual = prop?.value as T? ?? prop?.getDefaultValue<T>();

    void condition(Subject<T?> subject) {
      subject.context.nest<T>(
        () => [
          unconstrainedSelector.toStringBreadcrumb(),
          'with property $propName',
        ],
        (value) {
          _maybeAddAssertionEvent(
            "$unconstrainedSelector has $propName with value $value",
          );
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

void _maybeAddAssertionEvent(String description) {
  if (timeline.mode == TimelineMode.off) return;
  const String label = 'Assertion';
  timeline.addEvent(name: description, eventType: label);
}
