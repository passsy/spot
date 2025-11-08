import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:spot/src/screenshot/screenshot_annotator.dart';
import 'package:spot/src/spot/element_extensions.dart';
import 'package:spot/src/spot/filters/onstage_filter.dart';
import 'package:spot/src/spot/widget_selector.dart';

/// A type alias for a snapshot that can contain multiple widgets.
@Deprecated('Use WidgetSnapshot')
typedef MultiWidgetSnapshot<W extends Widget> = WidgetSnapshot<W>;

/// A type alias for a snapshot that contains a single widget.
@Deprecated('Use WidgetSnapshot')
typedef SingleWidgetSnapshot<W extends Widget> = WidgetSnapshot<W>;

/// Represents a snapshot of widgets that have been discovered
/// by a [WidgetSelector].
///
/// This class encapsulates the result of a widget selection process, containing
/// information about the widgets that matched the selector's criteria.
class WidgetSnapshot<W extends Widget> {
  /// Constructs a [WidgetSnapshot].
  WidgetSnapshot({
    required this.selector,
    required this.discovered,
    required this.debugCandidates,
    required this.scope,
  }) : _widgets = Map.fromEntries(
          discovered
              .map((e) => MapEntry(e, selector.mapElementToWidget(e.element))),
        );

  /// The widgets at the point when the snapshot was taken
  ///
  /// [Element] is a mutable object that might have changed since the snapshot
  /// was taken. This is a reference to the widget that was found at the time
  /// the snapshot was taken. This allows to compare the widget with the current
  /// widget in the tree.
  final Map<WidgetTreeNode, Widget> _widgets;

  /// The [WidgetSelector] that was used to search/filter elements in [scope]
  final WidgetSelector<W> selector;

  /// A widget tree (not necessarily the whole tree) that was used to
  /// match elements with [selector]
  final ScopedWidgetTreeSnapshot scope;

  /// All widgets from [scope] that were checked by [selector]
  ///
  /// Only ever use this for debugging purposes, the number of candidates can vary
  final List<Element> debugCandidates;

  /// All elements in [scope] that match [selector]
  final List<WidgetTreeNode> discovered;

  @override
  String toString() {
    return 'SpotSnapshot of $selector (${discoveredElements.length} matches)';
  }
}

/// Extension on [WidgetSnapshot<W>] to convert it to [WidgetMatcher] types.
///
/// Provides convenience methods to transform a widget snapshot into matchers
/// for single or multiple widgets.
extension ToWidgetMatcher<W extends Widget> on WidgetSnapshot<W> {
  /// Converts the snapshot to a [MultiWidgetMatcher],
  /// which can match multiple widgets.
  ///
  /// This method is used when you want to perform assertions or operations
  /// on multiple widgets discovered by the snapshot.
  @useResult
  MultiWidgetMatcher<W> get multi {
    return MultiWidgetMatcher.fromSnapshot(this);
  }

  /// Converts the snapshot to a [WidgetMatcher],
  /// ensuring it matches at most one widget.
  ///
  /// This method is used for assertions or operations on a single widget.
  /// It asserts that the snapshot contains at most one widget.
  @useResult
  WidgetMatcher<W> get single {
    assert(discovered.length <= 1);
    return existsAtMostOnce();
  }
}

/// Extension on [WidgetSnapshot]`<W>` providing shorthand accessors
/// to the discovered widgets and elements.
///
/// Offers convenient methods to retrieve single widgets or elements
/// and lists of discovered widgets and elements.
extension WidgetSnapshotShorthands<W extends Widget> on WidgetSnapshot<W> {
  /// Gets the first discovered widget of type [W], if any.
  /// Returns `null` if no such widget was discovered.
  W? get discoveredWidget => discoveredWidgets.firstOrNull;

  /// Deprecated: Use [discoveredWidget] instead.
  @Deprecated('Use discoveredWidget')
  W? get widget => discoveredWidget;

  /// Gets the first discovered [Element], if any.
  /// Returns `null` if no element was discovered.
  Element? get discoveredElement => discoveredElements.firstOrNull;

  /// Deprecated: Use [discoveredElement] instead.
  @Deprecated('Use discoveredElement')
  Element? get element => discoveredElement;

  /// Shorthand to get the widgets of all discovered elements
  /// (see [discovered] or [discoveredElements])
  ///
  /// This list may be incomplete for synthetic widgets like [AnyText],
  /// when the widgets are not of type [W].
  ///
  /// To check the number of discovered elements, always use [discovered]
  /// or [discoveredElements]. Use [discoveredWidgets] only when you need
  /// to access any properties of the widgets.
  List<W> get discoveredWidgets => _widgets.values.whereType<W>().toList();

  /// A list of all elements that were discovered.
  /// Use this list to access elements corresponding to the discovered widgets.
  List<Element> get discoveredElements =>
      discovered.map((e) => e.element).toList();

  /// Shorthand to get the [RenderObject] of the first discovered widget.
  RenderObject get discoveredRenderObject {
    _exists(min: 1, max: 1);
    final renderObject = discoveredElement!.renderObject;
    if (renderObject == null) {
      // There is not a single Element in the Flutter SDK that returns null for `renderObject`.
      // Please file a bug if you ever encounter this.
      throw TestFailure(
        "Widget '${selector.toStringBreadcrumb()}' has no associated RenderObject.\n",
      );
    }
    return renderObject;
  }

  /// Shorthand to get all RenderObjects of the discovered widgets.
  List<RenderObject> get discoveredRenderObjects {
    return discoveredElements.mapNotNull((e) => e.renderObject).toList();
  }

  /// Shorthand to get the [RenderBox] of the first discovered widget.
  RenderBox get discoveredRenderBox {
    _exists(min: 1, max: 1);
    final renderObject = discoveredRenderObject;
    if (renderObject is! RenderBox) {
      throw TestFailure(
        "Widget '${selector.toStringBreadcrumb()}' is associated to $renderObject which "
        "is not a RenderObject in the 2D Cartesian coordinate system "
        "(implements RenderBox).",
      );
    }
    return renderObject;
  }

  /// Shorthand to get all RenderBoxes of the discovered widgets.
  List<RenderBox> get discoveredRenderBoxes {
    return discoveredRenderObjects.whereType<RenderBox>().toList();
  }
}

/// prints debug information during [snapshot] that can be enabled in the
/// assert block
void _snapshotDebugPrint(String text) {
  // always false in production, because asserts are not executed
  bool enableDebugPrint = false;
  assert(() {
    // switch here to enable debug print
    enableDebugPrint = false; // <-- Switch!
    return true;
  }());

  if (kDebugMode && enableDebugPrint) {
    // ignore: avoid_print
    print('${''.padLeft(_depth * 4)}$text');
  }
}

int _depth = -1;

/// Creates a snapshot of widgets that match the specified [selector].
///
/// This function captures the current state of widgets that match the criteria
/// defined in [selector] for further analysis or assertions. It handles both
/// simple selectors and selectors with parent constraints. For
/// parent-constrained selectors, it generates candidates based on the parent
/// selectors and applies additional filters as defined in the selector.
WidgetSnapshot<W> snapshot<W extends Widget>(
  WidgetSelector<W> selector, {
  bool validateQuantity = true,
}) {
  // Make sure that any previous asynchronous operations are completed.
  // This check makes sure that a missing `await` in the line before throws here
  TestAsyncUtils.guardSync();

  final treeSnapshot = currentWidgetTreeSnapshot();
  final List<WidgetTreeNode> candidates = treeSnapshot.allNodes;

  final isAnyOffstage = selector.isAnyOffstage();
  final isAnyCombined = selector.isAnyCombined();

  // an easy to debug list of all filters and their individual results
  final initialStage = _StageResult(
    index: -1,
    filter: WidgetSelector.all.stages.first,
    candidates: candidates.toUnmodifiable(),
  );

  final List<_StageResult> stageResults = [initialStage];

  _depth++;
  _snapshotDebugPrint(
    'snapshot() ${selector.toStringBreadcrumb()}, '
    'visibility-mode ${selector.widgetPresence}',
  );
  final stages = [
    if (!isAnyCombined && isAnyOffstage)
      OffstageFilter()
    else if (!isAnyCombined && !isAnyOffstage)
      OnstageFilter(),
    ...selector.stages,
  ];

  for (int i = 0; i < stages.length; i++) {
    final stage = stages[i];
    // using unmodifiable copies to prevent accidental modification during filtering
    final remainingCandidatesFromPreviousStage =
        stageResults.last.candidates.toUnmodifiable();

    _snapshotDebugPrint(
      "+ Stage $i: $stage, "
      "input-candidates: ${remainingCandidatesFromPreviousStage.length}",
    );

    final after = stage
        .filter(remainingCandidatesFromPreviousStage)
        .toList()
        .toUnmodifiable();
    _snapshotDebugPrint("- Stage $i: $stage, "
        "output-candidates: ${after.length}");
    stageResults.add(_StageResult(index: i, filter: stage, candidates: after));
  }

  _snapshotDebugPrint(
    '${selector.toStringBreadcrumb()}, ${stageResults.last.candidates.length} matches',
  );
  final snapshot = WidgetSnapshot<W>(
    selector: selector,
    discovered: stageResults.last.candidates,
    scope: treeSnapshot,
    debugCandidates: candidates.map((element) => element.element).toList(),
  );
  _depth--;

  if (validateQuantity) {
    snapshot.validateQuantity();
  }

  return snapshot;
}

class _StageResult {
  final int index;
  final ElementFilter filter;
  final List<WidgetTreeNode> candidates;

  const _StageResult({
    required this.index,
    required this.filter,
    required this.candidates,
  });

  @override
  String toString() {
    return 'StageResult(#$index, candidates: ${candidates.length}, filter: $filter)';
  }
}

/// Extension on [WidgetSnapshot]`<W>` providing methods to validate the quantity of discovered widgets.
extension ValidateQuantity<W extends Widget> on WidgetSnapshot<W> {
  /// Validates the quantity of [discovered] to match [WidgetSelector.quantityConstraint]
  void validateQuantity() {
    try {
      final count = discovered.length;
      final minimumConstraint = selector.quantityConstraint.min;
      final maximumConstraint = selector.quantityConstraint.max;

      final unconstrainedSelector = selector.removeQuantityConstraints();

      String significantWidgetTree() {
        final set = discoveredElements.toSet();
        return findCommonAncestor(set).toStringDeep();
      }

      if (minimumConstraint != null && maximumConstraint == null) {
        if (minimumConstraint > count) {
          _tryMatchingLessSpecificCriteria(this);

          if (count == 0) {
            throw QuantityTestFailure(
              message:
                  'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                  'expected at least $minimumConstraint.\n'
                  'Check the timeline at the very bottom for more information.',
              significantWidgetTree: significantWidgetTree(),
              snapshot: this,
            );
          } else {
            throw QuantityTestFailure(
              message:
                  'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                  'expected at least $minimumConstraint.\n'
                  'Check the timeline at the very bottom for more information.',
              significantWidgetTree: significantWidgetTree(),
              snapshot: this,
            );
          }
        }
      }

      if (maximumConstraint != null && minimumConstraint == null) {
        if (maximumConstraint < count) {
          throw QuantityTestFailure(
            message:
                'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                'expected at most $maximumConstraint.\n'
                'Check the timeline at the very bottom for more information.',
            significantWidgetTree: significantWidgetTree(),
            snapshot: this,
          );
        }
      }

      if (minimumConstraint != null && maximumConstraint != null) {
        if (minimumConstraint == maximumConstraint) {
          final exactCount = minimumConstraint;
          if (count == exactCount) {
            // exact match, all fine
            return;
          } else {
            if (count == 0) {
              _tryMatchingLessSpecificCriteria(this);
              throw QuantityTestFailure(
                message:
                    'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                    'expected exactly $exactCount.\n'
                    'Check the timeline at the very bottom for more information.',
                significantWidgetTree: significantWidgetTree(),
                snapshot: this,
              );
            } else {
              _tryMatchingLessSpecificCriteria(this);
              throw QuantityTestFailure(
                message:
                    'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                    'expected exactly $exactCount.\n'
                    'Check the timeline at the very bottom for more information.',
                significantWidgetTree: significantWidgetTree(),
                snapshot: this,
              );
            }
          }
        } else {
          // out of range
          throw QuantityTestFailure(
            message:
                'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                'expected between $minimumConstraint and $maximumConstraint.\n'
                'Check the timeline at the very bottom for more information.',
            significantWidgetTree: significantWidgetTree(),
            snapshot: this,
          );
        }
      }
    } catch (error) {
      if (error is QuantityTestFailure) {
        if (timeline.mode != TimelineMode.off) {
          final screenshot = timeline.takeScreenshotSync(
            annotators: [
              HighlightAnnotator.elements(error.snapshot.discoveredElements),
            ],
          );
          timeline.addEvent(
            eventType: 'Assertion Failed',
            details: '${error.message}\n${error.significantWidgetTree}',
            screenshot: screenshot,
            color: Colors.red,
          );
        }
      }
      rethrow;
    }
  }
}

/// Thrown when the quantity of discovered widgets does not match the expected quantity.
class QuantityTestFailure implements TestFailure {
  /// Creates a new [QuantityTestFailure] based on a snapshot.
  QuantityTestFailure({
    required this.message,
    required this.significantWidgetTree,
    required this.snapshot,
  });

  /// A plain-text message describing the failure.
  @override
  final String message;

  /// A string representation of the relevant widget tree that contains all discovered widgets.
  final String significantWidgetTree;

  /// The snapshot that caused the failure.
  final WidgetSnapshot snapshot;

  @override
  String toString() {
    return message;
  }
}

/// Extension on [WidgetSnapshot]`<W>` providing matchers for asserting
/// the existence of a specific number of widgets.
///
/// These matchers allow checking if a certain number of widgets of type [W]
/// exist in the widget tree based on the snapshot's selector.
extension MultiWidgetSelectorMatcher<W extends Widget> on WidgetSnapshot<W> {
  /// Asserts that no widgets of type [W] exist.
  void doesNotExist() {
    _exists(max: 0);
    if (timeline.mode != TimelineMode.off) {
      timeline.addEvent(
        eventType: 'Assertion',
        details: '${selector.removeQuantityConstraints()} does not exist.',
        color: Colors.grey,
        screenshot: timeline.takeScreenshotSync(
          annotators: [
            HighlightAnnotator.elements(discoveredElements),
          ],
        ),
      );
    }
  }

  /// Asserts that exactly one widget of type [W] exists.
  WidgetMatcher<W> existsOnce() {
    final snapshot = _exists(min: 1, max: 1);
    if (timeline.mode != TimelineMode.off) {
      timeline.addEvent(
        eventType: 'Assertion',
        details: '${selector.removeQuantityConstraints()} exists once.',
        color: Colors.grey,
        screenshot: timeline.takeScreenshotSync(
          annotators: [
            HighlightAnnotator.elements(discoveredElements),
          ],
        ),
      );
    }
    return WidgetMatcher.fromSnapshot(snapshot);
  }

  /// Asserts that at least one widget of type [W] exists.
  MultiWidgetMatcher<W> existsAtLeastOnce() {
    final snapshot = _exists(min: 1);
    if (timeline.mode != TimelineMode.off) {
      timeline.addEvent(
        eventType: 'Assertion',
        details:
            '${selector.removeQuantityConstraints()} exists at least once, found ${discovered.length}.',
        color: Colors.grey,
        screenshot: timeline.takeScreenshotSync(
          annotators: [
            HighlightAnnotator.elements(discoveredElements),
          ],
        ),
      );
    }
    return snapshot.multi;
  }

  /// Asserts that at most one widget of type [W] exists.
  WidgetMatcher<W> existsAtMostOnce() {
    final snapshot = _exists(max: 1);
    if (timeline.mode != TimelineMode.off) {
      timeline.addEvent(
        eventType: 'Assertion',
        details:
            '${selector.removeQuantityConstraints()} exists at most once, found ${discovered.length}.',
        color: Colors.grey,
        screenshot: timeline.takeScreenshotSync(
          annotators: [
            HighlightAnnotator.elements(discoveredElements),
          ],
        ),
      );
    }
    return WidgetMatcher.fromSnapshot(snapshot);
  }

  /// Asserts that exactly [n] widgets of type [W] exist.
  MultiWidgetMatcher<W> existsExactlyNTimes(int n) {
    final snapshot = _exists(min: n, max: n);
    if (timeline.mode != TimelineMode.off) {
      timeline.addEvent(
        eventType: 'Assertion',
        details:
            '${selector.removeQuantityConstraints()} exists exactly $n times, found ${discovered.length}.',
        color: Colors.grey,
        screenshot: timeline.takeScreenshotSync(
          annotators: [
            HighlightAnnotator.elements(discoveredElements),
          ],
        ),
      );
    }
    return snapshot.multi;
  }

  /// Asserts that at least [n] widgets of type [W] exist.
  MultiWidgetMatcher<W> existsAtLeastNTimes(int n) {
    final snapshot = _exists(min: n);
    if (timeline.mode != TimelineMode.off) {
      timeline.addEvent(
        eventType: 'Assertion',
        details:
            '${selector.removeQuantityConstraints()} exists at least $n times, found ${discovered.length}.',
        color: Colors.grey,
        screenshot: timeline.takeScreenshotSync(
          annotators: [
            HighlightAnnotator.elements(discoveredElements),
          ],
        ),
      );
    }
    return snapshot.multi;
  }

  /// Asserts that at most [n] widgets of type [W] exist.
  MultiWidgetMatcher<W> existsAtMostNTimes(int n) {
    final snapshot = _exists(max: n);
    if (timeline.mode != TimelineMode.off) {
      timeline.addEvent(
        eventType: 'Assertion',
        details:
            '${selector.removeQuantityConstraints()} exists at most $n times, found ${discovered.length}.',
        color: Colors.grey,
        screenshot: timeline.takeScreenshotSync(
          annotators: [
            HighlightAnnotator.elements(discoveredElements),
          ],
        ),
      );
    }
    return snapshot.multi;
  }

  /// Internal method to check the existence of widgets with optional
  /// minimum and maximum limits.
  ///
  /// Validates the number of discovered widgets against the provided [min]
  /// and [max] constraints.
  /// Throws a descriptive error if the actual count of widgets does not meet
  /// the constraints.
  WidgetSnapshot<W> _exists({int? min, int? max}) {
    assert(min != null || max != null);
    assert(min == null || min >= 0);
    assert(max == null || max >= 0);
    assert(min == null || max == null || min <= max);

    final count = discovered.length;

    if (min != null) {
      if (count < min) {
        // try finding similar selectors (less specific)
        // if one is found, fail with a more specific error message
        _tryMatchingLessSpecificCriteria(
          this,
          quantityConstraint: QuantityConstraint(min: min, max: max),
        );

        final unconstrainedSelector = selector.removeQuantityConstraints();

        // else fail with default message
        final errorBuilder = StringBuffer();
        if (count == 0) {
          if (min == max) {
            errorBuilder.writeln(
              'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected exactly $min.',
            );
          } else {
            errorBuilder.writeln(
              'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected at least $min',
            );
          }
        } else {
          if (min == max) {
            errorBuilder.writeln(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected exactly $min.',
            );
          } else {
            errorBuilder.writeln(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected at least $min.',
            );
          }
        }
        _dumpWidgetTree(errorBuilder);
        if (timeline.mode != TimelineMode.off) {
          timeline.addEvent(
            eventType: 'Assertion Failed',
            details: errorBuilder.toString(),
            color: Colors.red,
            screenshot: timeline.takeScreenshotSync(
              annotators: [
                HighlightAnnotator.elements(discoveredElements),
              ],
            ),
          );
        }
        fail(
            'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree');
      }
    }

    if (max != null) {
      if (count > max) {
        final errorBuilder = StringBuffer();
        errorBuilder.writeln(
          'Found ${discovered.length} elements matching $selector in widget tree, '
          'expected at most $max.',
        );

        discovered.forEachIndexed((candidate, index) {
          errorBuilder.writeln("Possible match #$index:");
          errorBuilder.writeln(candidate.element.widget.toStringDeep());
        });

        final tree = findCommonAncestor(discoveredElements).toStringDeep();
        if (timeline.mode != TimelineMode.off) {
          timeline.addEvent(
            eventType: 'Assertion Failed',
            details: '$errorBuilder\n'
                '$tree',
            color: Colors.red,
            screenshot: timeline.takeScreenshotSync(
              annotators: [
                HighlightAnnotator.elements(discoveredElements),
              ],
            ),
          );
        }
        fail(errorBuilder.toString());
      }
    }
    return this;
  }
}

/// Throws when elements are found which match less specific criteria
///
/// Uses all permutations of the criteria (props/parents/children)
void _tryMatchingLessSpecificCriteria(
  WidgetSnapshot snapshot, {
  QuantityConstraint? quantityConstraint,
}) {
  final selector = snapshot.selector;
  final count = snapshot.discovered.length;
  final errorBuilder = StringBuffer();
  final unconstrainedSelector = selector.removeQuantityConstraints();
  final minimumConstraint = quantityConstraint != null
      ? quantityConstraint.min
      : selector.quantityConstraint.min;
  final maximumConstraint = quantityConstraint != null
      ? quantityConstraint.max
      : selector.quantityConstraint.max;

  if (minimumConstraint == null && maximumConstraint == null) {
    // no constraints, so no need to check
    return;
  }
  for (final lessSpecificSelector
      in unconstrainedSelector.lessSpecificSelectors()) {
    late final WidgetSnapshot lessSpecificSnapshot;
    try {
      lessSpecificSnapshot = lessSpecificSelector.snapshot();
    } catch (e) {
      continue;
    }
    final lessSpecificCount = lessSpecificSnapshot.discovered.length;

    // error that selector could not be found, but instead spot detected lessSpecificSnapshot, which might be useful
    if (lessSpecificCount > count) {
      if (minimumConstraint != null && maximumConstraint == null) {
        if (count == 0) {
          errorBuilder.writeln(
              'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected at least $minimumConstraint');
        }

        if (minimumConstraint > count) {
          errorBuilder.writeln(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected at least $minimumConstraint');
        }
      }

      if (maximumConstraint != null && minimumConstraint == null) {
        if (maximumConstraint < count) {
          errorBuilder.writeln(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected at most $maximumConstraint');
        }
      }

      if (minimumConstraint != null && maximumConstraint != null) {
        if (minimumConstraint == maximumConstraint) {
          final exactCount = minimumConstraint;
          if (count == 0) {
            errorBuilder.writeln(
                'Could not find ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                'expected exactly $exactCount');
          } else {
            errorBuilder.writeln(
                'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
                'expected exactly $exactCount');
          }
        } else {
          // out of range
          errorBuilder.writeln(
              'Found $count elements matching ${unconstrainedSelector.toStringBreadcrumb()} in widget tree, '
              'expected between $minimumConstraint and $maximumConstraint');
        }
      }

      if (count == 0) {
        final dynamicRegexp = RegExp(r'\bdynamic\b');

        final allUsedSelectors = [
          selector,
          ...selector.parents,
          ...selector.children,
        ];
        final allUsedTypes = allUsedSelectors.map((e) => e.type).distinct();

        for (final type in allUsedTypes) {
          final typeName = "$type";
          final RegExpMatch? match = dynamicRegexp.firstMatch(typeName);
          if (match != null) {
            errorBuilder.writeln(
                '\nWARNING: You are using a "dynamic" in your selector (ex: spot<$typeName>), this may be why you got no results:');
            errorBuilder.writeln(
                "-> a spot<$typeName>() doesn't match a ${typeName.replaceAll("dynamic", "String")}.");
            errorBuilder.writeln(
                "-> \"dynamic\" is used when you don't specify a generic type.\n");
          }
        }
      }

      errorBuilder.writeln(
        "A less specific search ($lessSpecificSelector) discovered $lessSpecificCount matches!",
      );
      errorBuilder.writeln(
        'Maybe you have to adjust your WidgetSelector ($unconstrainedSelector) to cover those missing elements.\n',
      );
      int index = 0;
      for (final Element match in lessSpecificSnapshot.discoveredElements) {
        index++;
        errorBuilder.writeln(
          'Possible match #$index:\n${match.toString(minLevel: DiagnosticLevel.info)}',
        );
        const maxLength = 10000;
        if (index > 10 && errorBuilder.length > maxLength) {
          errorBuilder.writeln(
            '... (truncated after $maxLength chars, too many matches found)',
          );
          break;
        }
      }
      final significantTree =
          findCommonAncestor(lessSpecificSnapshot.discoveredElements.toSet())
              .toStringDeep();
      final timelineErrorText =
          '$errorBuilder\nFound in widget Tree:\n$significantTree';

      if (timeline.mode != TimelineMode.off) {
        final screenshot = timeline.takeScreenshotSync(
          annotators: [
            HighlightAnnotator.elements(
              lessSpecificSnapshot.discoveredElements,
              color: Colors.cyan,
            ),
          ],
        );
        timeline.addEvent(
          eventType: 'Assertion Failed',
          color: Colors.red,
          screenshot: screenshot,
          details: timelineErrorText,
        );
      }

      if (timeline.mode == TimelineMode.off) {
        errorBuilder.writeln(
          'Enable the timeline to see the relevant widget tree at this point https://github.com/passsy/spot#change-timeline-mode',
        );
      } else {
        errorBuilder.writeln(
          '⬇️⬇️⬇️ See the timeline at the very bottom for the full widget tree ⬇️⬇️⬇️',
        );
      }

      fail(errorBuilder.toString());
    }
  }
}

void _dumpWidgetTree(StringBuffer buffer) {
  // ignore: deprecated_member_use
  final rootElement = WidgetsBinding.instance.renderViewElement;
  if (rootElement != null) {
    buffer.writeln(rootElement.toStringDeep());
  } else {
    buffer.writeln('<no tree currently mounted>');
  }
}

/// Extension on [WidgetSelector] providing methods to generate less specific selectors.
@visibleForTesting
extension LessSpecificSelectors<W extends Widget> on WidgetSelector<W> {
  /// Returns all less specific selectors, removing one criteria at a time until
  /// the selector is empty.
  ///
  /// The selectors are sorted by specificity, so the first selector filters the most
  ///
  /// For example, if the selector matches for type Center and parent SizedBox it will return
  /// - selector which only matches for type Center
  /// - selector which only matches for parent SizedBox
  @visibleForTesting
  Iterable<WidgetSelector<W>> lessSpecificSelectors() sync* {
    final List<WidgetSelector<W> Function(WidgetSelector<W>)> criteria = [
      for (final stage in stages)
        (s) => s.copyWith(stages: [...s.stages, stage]),
    ];
    if (criteria.length <= 1) {
      return;
    }

    for (final subset in getAllSubsets(criteria)) {
      if (subset.isEmpty) {
        // no criteria would return all widgets, which is not useful
        continue;
      }
      yield _buildSelector(subset);
    }
  }

  WidgetSelector<W> _buildSelector(
    List<WidgetSelector<W> Function(WidgetSelector<W>)> criteria,
  ) {
    WidgetSelector<W> s = copyWith(
      // stages will be added partially with each criteria
      stages: [],
      // No constraints needed
      // In this scenario no widget was found previously, and would be happy to find any
      quantityConstraint: QuantityConstraint.unconstrained,
    );
    for (final criteria in criteria) {
      s = criteria(s);
    }
    if (!s.stages.any((stage) => stage is WidgetTypeFilter)) {
      return s.copyWith(stages: [WidgetSelector.all.stages[0], ...s.stages]);
    }
    return s;
  }
}

/// Generates all subsets of a given list.
@visibleForTesting
List<List<T>> getAllSubsets<T>(List<T> list) {
  final List<List<T>> result = [[]];
  for (final element in list) {
    final List<List<T>> newSubsets = [];
    for (final subset in result) {
      newSubsets.add([...subset, element]);
    }
    result.addAll(newSubsets);
  }
  result.remove(result.firstWhere((it) => it.length == list.length));
  return result.sortedByDescending((element) => element.length).toList();
}

/// Finds the common ancestor of a set of elements.
Element findCommonAncestor(Iterable<Element> elements) {
  // ignore: deprecated_member_use
  final rootElement = WidgetsBinding.instance.renderViewElement!;
  if (elements.isEmpty) {
    return rootElement;
  } else if (elements.length == 1) {
    return elements.first.parent ?? rootElement;
  }

  // get element with smallest depth to reach common ancestor faster
  final highestElement =
      IterableSortedBy(elements).sortedBy((element) => element.depth).first;
  // save all other parents
  final allOtherParents =
      elements.exceptElement(highestElement).map((e) => e.parents);

  final commonAncestor = highestElement.parents.firstOrNullWhere(
    (parent) => allOtherParents.every((parents) => parents.contains(parent)),
  );

  return commonAncestor ?? rootElement;
}
