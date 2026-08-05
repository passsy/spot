import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/checks/checks_nullability.dart';
import 'package:spot/src/flutter/frame_clock.dart';
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
/// [element], cached for the duration of the current frame.
///
/// [Widget.toDiagnosticsNode] returns a fresh node on every call, and each node
/// only caches [DiagnosticsNode.getProperties] for itself. Without this cache
/// every matcher in a chain re-runs `debugFillProperties` for the same widget,
/// and every `with*` selector re-runs it for every widget in the tree.
///
/// The cache is keyed on the [Element]'s own widget rather than the derived
/// one, because [WidgetSelector.mapElementToWidget] may synthesize a widget per
/// call, as the [AnyText] selectors do. [mapElementToWidget] is part of the key
/// so that two selectors deriving different widgets from one element, such as
/// `spot<RichText>()` and `spotText()`, don't read each other's properties.
///
/// A frame is the longest span over which a derived widget is guaranteed to
/// keep reporting the same properties. Widgets themselves are immutable, but a
/// derived widget can read live state: [AnyText.fromEditableText] takes the
/// text from the controller, and an [EditableText] keeps its widget instance
/// while its text changes. Holding entries past the frame that produced them
/// would serve the text a test just replaced.
List<DiagnosticsNode> _diagnosticProps(
  Element element,
  Widget Function(Element element) mapElementToWidget,
) {
  _dropCacheOnNewFrame();
  final derived = _propsCache[element.widget] ??= {};
  return derived[mapElementToWidget] ??=
      mapElementToWidget(element).toDiagnosticsNode().getProperties();
}

/// Maps an [Element]'s widget to the properties of every widget derived from it
/// in the current frame, keyed by the function that derived it.
///
/// An [Expando] because the keys are widgets of a tree the test may tear down
/// at any point, and holding them here must not keep them alive.
Expando<Map<Function, List<DiagnosticsNode>>> _propsCache = Expando();

int _cachedFrame = -1;

/// Drops everything cached in an earlier frame.
///
/// [FrameClock] counts frames for the whole process, so this only has to
/// notice that the number moved. Nothing here registers a frame callback of
/// its own.
void _dropCacheOnNewFrame() {
  final frame = FrameClock.frameNumberInProcess;
  if (frame != _cachedFrame) {
    _cachedFrame = frame;
    _propsCache = Expando();
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
