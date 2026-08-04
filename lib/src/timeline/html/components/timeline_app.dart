// ignore_for_file: public_member_api_docs, avoid_dynamic_calls

/// This library is compiled for both vm and web platforms.
/// Therefore, this and all imported libraries need to be platform agnostic or stubbed.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' if (dart.library.io) '../web/web_stubs.dart' show window;
import 'dart:math' as math;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:spot/src/timeline/html/components/snackbar.dart';
import 'package:spot/src/timeline/html/web/timeline_event.dart';

/// The main entry point for the timeline web app.
class TimelineApp extends StatefulComponent {
  const TimelineApp({
    required this.testName,
    required this.testNameWithHierarchy,
    required this.timelineEvents,
    required this.sourceFiles,
    required this.renderedFrameCount,
  });

  final String testName;
  final String testNameWithHierarchy;
  final List<TimelineEvent> timelineEvents;

  /// Every source file the events point into, keyed by path.
  final Map<String, TimelineSourceFile> sourceFiles;

  /// Frames the test rendered in total, whether anything was recorded in them
  /// or not. What a test costs, in the one unit that always applies.
  final int renderedFrameCount;

  @override
  State<TimelineApp> createState() => TimelineAppState();
}

enum _InspectorTab { details, widgetInspector, widgetTree, raw }

const _treeTextPageLineCount = 250;

/// The source pane and the caller line inside it, so the pane can be scrolled
/// to the caller after a selection changes.
const _sourceCodeId = 'source-code';
const _callerLineId = 'source-caller-line';

/// Lines kept visible above the caller when the source pane scrolls to it.
const int _sourceContextLinesAbove = 4;

/// The widget tree's scroll container, so it can be scrolled to a match.
const _widgetTreeId = 'interactive-tree';

/// The timeline strip's scroll container, so it can be scrolled to an event.
const _timelineScrollClass = 'timeline-scroll';

/// Space left between an event and the edge it was scrolled in from.
const double _timelineScrollPadding = 16;

/// Height of one widget tree row, matching `.tree-node__row` in the CSS.
///
/// The tree renders only the rows in view, which needs the height of a row
/// that has not been rendered yet. Keeping every row the same height is what
/// makes that possible.
const double _treeRowHeight = 25;

/// How much of one indentation step a row takes, matching the CSS.
const double _treeIndentWidth = 14;

/// Rows rendered above and below the viewport, so scrolling does not flash.
const int _treeOverscanRows = 16;

/// One row of the flattened widget tree.
class TreeRow {
  TreeRow({
    required this.node,
    required this.depth,
    required this.hasChildren,
    required this.expanded,
  });

  final Map<String, dynamic> node;

  /// Indentation steps, not the depth in the tree, see [flattenWidgetTree].
  final int depth;
  final bool hasChildren;
  final bool expanded;

  String get id => node['id'] as String;
}

/// Flattens the expanded parts of [root] into the rows to display.
///
/// A chain of single-child widgets stays at one indentation, the way Flutter's
/// own inspector shows it. Widget trees are mostly such chains, and indenting
/// every one of them pushes the interesting rows off the right edge.
///
/// Rendering reads this list by index, which is what lets the tree draw only
/// the rows in view instead of thousands of DOM nodes.
List<TreeRow> flattenWidgetTree(
  Map<String, dynamic>? root, {
  required Set<String> expandedNodeIds,
  required Set<String> visibleNodeIds,
  required bool searchActive,
}) {
  if (root == null) {
    return const [];
  }
  final rows = <TreeRow>[];

  void walk(Map<String, dynamic> node, int depth) {
    final children = _structuredNodeChildren(node)
        .where((child) => !searchActive || visibleNodeIds.contains(child['id']))
        .toList(growable: false);
    // A search shows every node on the way to a match, collapsing them would
    // hide the matches the search just found.
    final expanded = searchActive || expandedNodeIds.contains(node['id']);
    rows.add(
      TreeRow(
        node: node,
        depth: depth,
        hasChildren: children.isNotEmpty,
        expanded: expanded,
      ),
    );
    if (!expanded) {
      return;
    }
    final childDepth = children.length > 1 ? depth + 1 : depth;
    for (final child in children) {
      walk(child, childDepth);
    }
  }

  walk(root, 0);
  return rows;
}

/// The row the widget tree's arrow keys act on, or `null` when it has none.
///
/// The first row when nothing is selected, which is the row the tree already
/// draws as selected in that case.
TreeRow? selectedTreeRow(List<TreeRow> rows, String? selectedNodeId) {
  if (rows.isEmpty) {
    return null;
  }
  final index = rows.indexWhere((row) => row.id == selectedNodeId);
  return rows[index == -1 ? 0 : index];
}

/// The node to select when moving [delta] rows from [selectedNodeId].
///
/// Stops at the ends instead of wrapping, so holding an arrow down settles at
/// the top or the bottom of the tree.
String? adjacentTreeNodeId(
  List<TreeRow> rows,
  String? selectedNodeId,
  int delta,
) {
  final from = selectedTreeRow(rows, selectedNodeId);
  if (from == null) {
    return null;
  }
  final index = (rows.indexOf(from) + delta).clamp(0, rows.length - 1);
  return rows[index].id;
}

enum _ResizeTarget { timeline, captureTree, treeDetails }

const double _headerHeight = 48;
const double _resizeHandleSize = 6;
const double _minimumTimelineHeight = 150;
const double _minimumInspectorHeight = 180;

double resizedTimelineHeight({
  required double pointerY,
  required double containerTop,
  required double containerHeight,
}) {
  final maximum = math.max(
    _minimumTimelineHeight,
    containerHeight -
        _headerHeight -
        _resizeHandleSize -
        _minimumInspectorHeight,
  );
  return (pointerY - containerTop - _headerHeight).clamp(
    _minimumTimelineHeight,
    maximum,
  );
}

double resizedPanePercent({
  required double pointer,
  required double containerStart,
  required double containerExtent,
  required double minimum,
  required double maximum,
  double leadingInset = 0,
}) {
  if (containerExtent <= 0) {
    return minimum;
  }
  return ((pointer - containerStart - leadingInset) / containerExtent * 100)
      .clamp(minimum, maximum);
}

double adjustedPaneSize(
  double current,
  double delta, {
  required double minimum,
  required double maximum,
}) => (current + delta).clamp(minimum, maximum);

class TimelineTextSlice {
  const TimelineTextSlice({
    required this.text,
    required this.startLine,
    required this.visibleLineCount,
    required this.hasPrevious,
    required this.hasMore,
  });

  final String text;
  final int startLine;
  final int visibleLineCount;
  final bool hasPrevious;
  final bool hasMore;

  int get endLine => startLine + visibleLineCount - 1;
}

TimelineTextSlice sliceTimelineText(
  String text, {
  required int startLine,
  required int maximumLines,
}) {
  if (startLine < 1) {
    throw ArgumentError.value(startLine, 'startLine', 'Must be positive');
  }
  if (maximumLines < 1) {
    throw ArgumentError.value(maximumLines, 'maximumLines', 'Must be positive');
  }
  if (text.isEmpty) {
    return const TimelineTextSlice(
      text: '',
      startLine: 1,
      visibleLineCount: 0,
      hasPrevious: false,
      hasMore: false,
    );
  }

  var sliceStart = 0;
  for (var line = 1; line < startLine; line++) {
    final lineEnd = text.indexOf('\n', sliceStart);
    if (lineEnd == -1 || lineEnd == text.length - 1) {
      return TimelineTextSlice(
        text: '',
        startLine: startLine,
        visibleLineCount: 0,
        hasPrevious: true,
        hasMore: false,
      );
    }
    sliceStart = lineEnd + 1;
  }

  var searchStart = sliceStart;
  for (var line = 1; line <= maximumLines; line++) {
    final lineEnd = text.indexOf('\n', searchStart);
    if (lineEnd == -1 || lineEnd == text.length - 1) {
      return TimelineTextSlice(
        text: text.substring(sliceStart),
        startLine: startLine,
        visibleLineCount: line,
        hasPrevious: startLine > 1,
        hasMore: false,
      );
    }
    if (line == maximumLines) {
      return TimelineTextSlice(
        text: text.substring(sliceStart, lineEnd),
        startLine: startLine,
        visibleLineCount: line,
        hasPrevious: startLine > 1,
        hasMore: true,
      );
    }
    searchStart = lineEnd + 1;
  }

  throw StateError('Unreachable');
}

class TimelineFrameGroup {
  TimelineFrameGroup({
    required this.frameNumber,
    required this.renderedFrameNumber,
    required this.eventIndexes,
    required this.screenshotUrl,
  });

  final int frameNumber;

  /// How many frames the test had rendered when this group was recorded.
  ///
  /// Falls back to [frameNumber] for reports written before frames were
  /// counted, which leaves consecutive groups adjacent and so shows no gaps.
  final int renderedFrameNumber;
  final List<int> eventIndexes;
  final String? screenshotUrl;
}

List<TimelineFrameGroup> groupTimelineFrames(List<TimelineEvent> events) {
  final indexesByFrame = <int, List<int>>{};
  for (var index = 0; index < events.length; index++) {
    final frameNumber = events[index].frameNumber ?? index + 1;
    indexesByFrame.putIfAbsent(frameNumber, () => []).add(index);
  }
  return indexesByFrame.entries
      .map((entry) {
        String? screenshotUrl;
        for (final index in entry.value) {
          screenshotUrl ??= events[index].screenshotUrl;
        }
        return TimelineFrameGroup(
          frameNumber: entry.key,
          renderedFrameNumber:
              events[entry.value.first].renderedFrameNumber ?? entry.key,
          eventIndexes: List.unmodifiable(entry.value),
          screenshotUrl: screenshotUrl,
        );
      })
      .toList(growable: false);
}

/// The stretch between two frames the timeline has information for.
///
/// Everything inside it was laid out and painted and then never looked at: no
/// event, no assertion, no capture. Its size is what makes the difference
/// between a `pump` and a `pumpAndSettle` visible.
class TimelineGap {
  const TimelineGap({
    required this.frames,
    required this.testClock,
    required this.wallClock,
  });

  /// Frames rendered inside the gap.
  final int frames;

  /// How long the gap took on the test's simulated clock, which is what the
  /// test asked for by pumping durations.
  final Duration testClock;

  /// How long the gap really took, which is what it costs to run the test.
  final Duration wallClock;
}

/// The gap between [previous] and [next], or `null` when there is none.
///
/// `null` rather than an empty gap when the two are adjacent, and for reports
/// written before frames were counted.
TimelineGap? gapBetween(
  List<TimelineEvent> events,
  TimelineFrameGroup previous,
  TimelineFrameGroup next,
) {
  final frames = next.renderedFrameNumber - previous.renderedFrameNumber - 1;
  if (frames <= 0) {
    return null;
  }
  // Measured from the last thing recorded before the gap to the first thing
  // recorded after it, which is exactly the span nothing was recorded in.
  final before = events[previous.eventIndexes.last];
  final after = events[next.eventIndexes.first];
  return TimelineGap(
    frames: frames,
    testClock: _between(before.timestamp, after.timestamp),
    wallClock: _between(before.wallTimestamp, after.wallTimestamp),
  );
}

/// One column of the timeline strip: a frame that was recorded, or a gap.
class TrackColumn {
  const TrackColumn.frame(TimelineFrameGroup this.frame) : gap = null;
  const TrackColumn.gap(TimelineGap this.gap) : frame = null;

  final TimelineFrameGroup? frame;
  final TimelineGap? gap;
}

/// The columns of the timeline strip, in order.
///
/// Every row of the strip walks this same list, which is what keeps the ruler,
/// the captures and the event lanes lined up once gaps sit between them.
List<TrackColumn> timelineTrackColumns(
  List<TimelineEvent> events,
  List<TimelineFrameGroup> frames,
) {
  final columns = <TrackColumn>[];
  for (final (index, frame) in frames.indexed) {
    if (index > 0) {
      final gap = gapBetween(events, frames[index - 1], frame);
      if (gap != null) {
        columns.add(TrackColumn.gap(gap));
      }
    }
    columns.add(TrackColumn.frame(frame));
  }
  return columns;
}

Duration _between(String from, String to) {
  final start = DateTime.tryParse(from);
  final end = DateTime.tryParse(to);
  if (start == null || end == null) {
    return Duration.zero;
  }
  return end.difference(start);
}

/// The event to select when moving [delta] frames away from
/// [selectedEventIndex].
///
/// Always the first event of the target frame. Frames are their own stories,
/// so landing in the middle of one because that is where the previous frame
/// was left off hides everything that happened before it.
int? adjacentFrameEventIndex(
  List<TimelineFrameGroup> frames,
  int? selectedEventIndex,
  int delta,
) {
  if (frames.isEmpty) {
    return null;
  }
  if (selectedEventIndex == null) {
    return delta < 0
        ? frames.last.eventIndexes.first
        : frames.first.eventIndexes.first;
  }

  final currentFrameIndex = frames.indexWhere(
    (frame) => frame.eventIndexes.contains(selectedEventIndex),
  );
  if (currentFrameIndex == -1) {
    return frames.first.eventIndexes.first;
  }
  final targetFrameIndex = (currentFrameIndex + delta).clamp(
    0,
    frames.length - 1,
  );
  return frames[targetFrameIndex].eventIndexes.first;
}

int? adjacentEventInFrameIndex(
  List<TimelineFrameGroup> frames,
  int? selectedEventIndex,
  int delta,
) {
  if (frames.isEmpty) {
    return null;
  }
  if (selectedEventIndex == null) {
    final firstFrameEvents = frames.first.eventIndexes;
    return delta < 0 ? firstFrameEvents.last : firstFrameEvents.first;
  }

  final frame = frames.where(
    (frame) => frame.eventIndexes.contains(selectedEventIndex),
  );
  if (frame.isEmpty) {
    return frames.first.eventIndexes.first;
  }
  final frameEvents = frame.first.eventIndexes;
  final currentOffset = frameEvents.indexOf(selectedEventIndex);
  return frameEvents[(currentOffset + delta).clamp(0, frameEvents.length - 1)];
}

class TimelineAppState extends State<TimelineApp> {
  // ignore: prefer_const_constructors
  final GlobalStateKey<SnackBarState> _snackBar = GlobalStateKey();

  int? _selectedIndex;
  _InspectorTab _selectedTab = _InspectorTab.details;
  final Set<String> _expandedWidgetNodes = {'0'};
  final Map<int, TimelineEvent> _decodedFrameData = {};
  String? _selectedWidgetNodeId;
  String _widgetTreeSearch = '';
  bool _showFullRawData = false;
  bool _showCaptureOverlays = true;

  /// Whether the arrow keys move through the widget tree instead of the
  /// timeline, see [_updateArrowTarget].
  bool _arrowsDriveWidgetTree = false;

  /// Where the widget tree is scrolled to, and how tall its viewport is.
  ///
  /// Together they decide which rows are rendered, see [_widgetTreeRows].
  double _treeScrollTop = 0;
  double _treeViewportHeight = 640;

  /// The event whose capture is open full screen, `null` when none is.
  TimelineEvent? _lightboxEvent;
  int _treeTextStartLine = 1;
  double _timelineHeight = 256;
  double _capturePanePercent = 57;
  double _treePanePercent = 62;
  _ResizeTarget? _resizeTarget;
  StreamSubscription<dynamic>? _keySubscription;
  StreamSubscription<dynamic>? _pointerDownSubscription;
  StreamSubscription<dynamic>? _resizeMoveSubscription;
  StreamSubscription<dynamic>? _resizeEndSubscription;

  TimelineEvent? get _selectedEvent {
    final index = _selectedIndex;
    if (index == null || index >= component.timelineEvents.length) {
      return null;
    }
    return component.timelineEvents[index];
  }

  DateTime? get _firstTimestamp => component.timelineEvents.isEmpty
      ? null
      : DateTime.tryParse(component.timelineEvents.first.timestamp);

  DateTime? get _firstWallTimestamp => component.timelineEvents.isEmpty
      ? null
      : DateTime.tryParse(component.timelineEvents.first.wallTimestamp);

  Duration get _duration {
    if (component.timelineEvents.length < 2) {
      return Duration.zero;
    }
    final first = _firstTimestamp;
    final last = DateTime.tryParse(component.timelineEvents.last.timestamp);
    if (first == null || last == null) {
      return Duration.zero;
    }
    return last.difference(first);
  }

  /// What the report opens on.
  ///
  /// The failure, because that is the reason the report is being read at all.
  /// The last one when several were recorded, since that is where the test
  /// stopped. Otherwise the first event, so the report never opens empty.
  int? _initialSelection() {
    final events = component.timelineEvents;
    if (events.isEmpty) {
      return null;
    }
    final lastFailure = events.lastIndexWhere((event) => event.isFailure);
    return lastFailure == -1 ? 0 : lastFailure;
  }

  @override
  void initState() {
    super.initState();
    final initialSelection = _initialSelection();
    _selectedIndex = initialSelection;
    if (initialSelection != null) {
      _expandedWidgetNodes
        ..clear()
        ..addAll(_expandedNodeIdsFor(initialSelection));
      // The report usually opens on the failure, which is the last event of
      // the run and sits off the right edge of a strip that opens at frame 1.
      _scrollTimelineToEvent(initialSelection);
    }
    _scrollCallerIntoView(
      initialSelection == null
          ? null
          : component.timelineEvents[initialSelection].callerLine,
    );
    if (kIsWeb) {
      _keySubscription = window.onKeyDown.listen((event) {
        final dynamic target = event.target;
        final tagName = target?.tagName?.toString().toLowerCase();
        if (tagName == 'input' ||
            tagName == 'textarea' ||
            tagName == 'select' ||
            target?.isContentEditable == true) {
          return;
        }
        if (event.key == 'Escape' && _lightboxEvent != null) {
          _closeLightbox();
          event.preventDefault();
          return;
        }
        if (_arrowsDriveWidgetTree && _handleWidgetTreeKey(event.key)) {
          event.preventDefault();
          return;
        }
        switch (event.key) {
          case 'ArrowLeft':
            _selectAdjacentFrame(-1);
          case 'ArrowRight':
            _selectAdjacentFrame(1);
          case 'ArrowUp':
            _selectAdjacentEventInFrame(-1);
          case 'ArrowDown':
            _selectAdjacentEventInFrame(1);
          case 'Home':
            _select(0);
          case 'End':
            _select(component.timelineEvents.length - 1);
          default:
            return;
        }
        event.preventDefault();
      });
      _pointerDownSubscription = window.onMouseDown.listen(_updateArrowTarget);
      _resizeMoveSubscription = window.onMouseMove.listen(_resizePane);
      _resizeEndSubscription = window.onMouseUp.listen(_finishResizing);
    }
  }

  @override
  void dispose() {
    _keySubscription?.cancel();
    _pointerDownSubscription?.cancel();
    _resizeMoveSubscription?.cancel();
    _resizeEndSubscription?.cancel();
    super.dispose();
  }

  /// Hands the arrow keys to the widget tree, or takes them back.
  ///
  /// The tree needs all four arrows for itself, so it claims them once it is
  /// clicked into and gives them back on the next click anywhere else.
  void _updateArrowTarget(dynamic event) {
    final dynamic target = event.target;
    final inTree = target != null && target.closest('#$_widgetTreeId') != null;
    if (inTree == _arrowsDriveWidgetTree) {
      return;
    }
    setState(() => _arrowsDriveWidgetTree = inTree);
  }

  /// Handles [key] for the widget tree, and reports whether it did.
  ///
  /// Up and down walk the rows on screen, left and right close and open the
  /// selected node. Everything else is left to the timeline, so Home and End
  /// keep jumping between events while the tree holds the arrows.
  bool _handleWidgetTreeKey(Object? key) {
    switch (key) {
      case 'ArrowUp':
        _selectAdjacentWidgetNode(-1);
      case 'ArrowDown':
        _selectAdjacentWidgetNode(1);
      case 'ArrowLeft':
        _setSelectedWidgetNodeExpanded(expanded: false);
      case 'ArrowRight':
        _setSelectedWidgetNodeExpanded(expanded: true);
      default:
        return false;
    }
    return true;
  }

  /// The rows the widget tree shows right now.
  ///
  /// What is on screen depends on the selected event, what is expanded and
  /// what the search leaves visible, so it is flattened again rather than
  /// remembered.
  List<TreeRow> _currentTreeRows() {
    final event = _selectedEvent;
    if (event == null) {
      return const [];
    }
    final root = _widgetTreeRoot(event);
    return flattenWidgetTree(
      root,
      expandedNodeIds: _expandedWidgetNodes,
      visibleNodeIds: searchStructuredWidgetTree(
        root,
        _widgetTreeSearch,
      ).visible,
      searchActive: _widgetTreeSearch.trim().isNotEmpty,
    );
  }

  void _selectAdjacentWidgetNode(int delta) {
    final id = adjacentTreeNodeId(
      _currentTreeRows(),
      _selectedWidgetNodeId,
      delta,
    );
    if (id == null) {
      return;
    }
    _selectWidgetNode(id);
    _scrollTreeToNode(id);
  }

  void _setSelectedWidgetNodeExpanded({required bool expanded}) {
    final row = selectedTreeRow(_currentTreeRows(), _selectedWidgetNodeId);
    // A leaf has nothing to open, and a search forces everything open anyway.
    if (row == null || !row.hasChildren || row.expanded == expanded) {
      return;
    }
    _toggleWidgetNode(row.id);
  }

  void _startResizing(_ResizeTarget target, dynamic event) {
    event.preventDefault();
    _resizeTarget = target;
    if (kIsWeb) {
      final className = switch (target) {
        _ResizeTarget.captureTree => 'is-resizing-columns',
        _ResizeTarget.timeline ||
        _ResizeTarget.treeDetails => 'is-resizing-rows',
      };
      window.document.querySelector('body')?.classes.add(className);
    }
  }

  void _resizePane(dynamic event) {
    final target = _resizeTarget;
    if (!kIsWeb || target == null) {
      return;
    }

    switch (target) {
      case _ResizeTarget.timeline:
        final element = window.document.getElementById('timeline-app');
        if (element == null) {
          return;
        }
        final rect = element.getBoundingClientRect();
        final clientY = (event.client.y as num).toDouble();
        _timelineHeight = resizedTimelineHeight(
          pointerY: clientY,
          containerTop: rect.top.toDouble(),
          containerHeight: rect.height.toDouble(),
        );
        element.style.setProperty('--timeline-height', '${_timelineHeight}px');
      case _ResizeTarget.captureTree:
        final element = window.document.getElementById('interactive-inspector');
        if (element == null) {
          return;
        }
        final rect = element.getBoundingClientRect();
        if (rect.width <= 0) {
          return;
        }
        final clientX = (event.client.x as num).toDouble();
        _capturePanePercent = resizedPanePercent(
          pointer: clientX,
          containerStart: rect.left.toDouble(),
          containerExtent: rect.width.toDouble(),
          minimum: 20,
          maximum: 80,
        );
        element.style.setProperty(
          '--capture-pane-width',
          '$_capturePanePercent%',
        );
      case _ResizeTarget.treeDetails:
        final element = window.document.getElementById('widget-explorer');
        if (element == null) {
          return;
        }
        final rect = element.getBoundingClientRect();
        if (rect.height <= 0) {
          return;
        }
        final clientY = (event.client.y as num).toDouble();
        _treePanePercent = resizedPanePercent(
          pointer: clientY,
          containerStart: rect.top.toDouble(),
          containerExtent: rect.height.toDouble(),
          leadingInset: 34,
          minimum: 25,
          maximum: 82,
        );
        element.style.setProperty('--tree-pane-height', '$_treePanePercent%');
    }
  }

  void _finishResizing(dynamic _) {
    if (_resizeTarget == null) {
      return;
    }
    _resizeTarget = null;
    if (kIsWeb) {
      window.document.querySelector('body')?.classes
        ?..remove('is-resizing-columns')
        ..remove('is-resizing-rows');
    }
    setState(() {});
  }

  void _resizeWithKeyboard(_ResizeTarget target, dynamic event) {
    final key = event.key as String?;
    final delta = switch ((target, key)) {
      (_ResizeTarget.captureTree, 'ArrowLeft') => -4.0,
      (_ResizeTarget.captureTree, 'ArrowRight') => 4.0,
      (_ResizeTarget.timeline, 'ArrowUp') => -24.0,
      (_ResizeTarget.timeline, 'ArrowDown') => 24.0,
      (_ResizeTarget.treeDetails, 'ArrowUp') => -5.0,
      (_ResizeTarget.treeDetails, 'ArrowDown') => 5.0,
      _ => null,
    };
    if (delta == null) {
      return;
    }
    event.stopPropagation();
    event.preventDefault();
    setState(() {
      switch (target) {
        case _ResizeTarget.timeline:
          final element = kIsWeb
              ? window.document.getElementById('timeline-app')
              : null;
          final maximum = element == null
              ? 600.0
              : math.max(
                  _minimumTimelineHeight,
                  element.getBoundingClientRect().height -
                      _headerHeight -
                      _resizeHandleSize -
                      _minimumInspectorHeight,
                );
          _timelineHeight = adjustedPaneSize(
            _timelineHeight,
            delta,
            minimum: _minimumTimelineHeight,
            maximum: maximum,
          );
        case _ResizeTarget.captureTree:
          _capturePanePercent = adjustedPaneSize(
            _capturePanePercent,
            delta,
            minimum: 20,
            maximum: 80,
          );
        case _ResizeTarget.treeDetails:
          _treePanePercent = adjustedPaneSize(
            _treePanePercent,
            delta,
            minimum: 25,
            maximum: 82,
          );
      }
    });
  }

  void _selectAdjacentFrame(int delta) {
    final index = adjacentFrameEventIndex(
      groupTimelineFrames(component.timelineEvents),
      _selectedIndex,
      delta,
    );
    if (index == null) {
      return;
    }
    _select(index);
  }

  void _selectAdjacentEventInFrame(int delta) {
    final index = adjacentEventInFrameIndex(
      groupTimelineFrames(component.timelineEvents),
      _selectedIndex,
      delta,
    );
    if (index == null) {
      return;
    }
    _select(index);
  }

  /// Every node of the tree captured for the event at [index].
  ///
  /// Everything is expanded: only the rows in view are rendered, so the size
  /// of the tree no longer decides what it costs to show it.
  Set<String> _expandedNodeIdsFor(int index) {
    final root = _widgetTreeRoot(component.timelineEvents[index]);
    return root == null ? const {'0'} : collectStructuredWidgetNodeIds(root);
  }

  void _select(int index) {
    if (index < 0 || index >= component.timelineEvents.length) {
      return;
    }
    final expandedIds = _expandedNodeIdsFor(index);
    setState(() {
      _selectedIndex = index;
      _selectedWidgetNodeId = null;
      _showFullRawData = false;
      _treeTextStartLine = 1;
      _treeScrollTop = 0;
      _expandedWidgetNodes
        ..clear()
        ..addAll(expandedIds);
    });
    _scrollTimelineToEvent(index);
    _scrollCallerIntoView(component.timelineEvents[index].callerLine);
  }

  /// Brings the event at [index] into view in the timeline strip.
  ///
  /// The strip scrolls sideways between frames, and a frame holding more
  /// events than fit scrolls its own column, so both are moved by the least
  /// amount that puts the marker on screen.
  ///
  /// Waits for the marker to be laid out and then holds the position for a few
  /// frames. On the first load the strip has nothing to scroll yet, and
  /// hydration replaces it shortly after the first paint and takes the scroll
  /// position with it.
  void _scrollTimelineToEvent(int index) {
    if (!kIsWeb) {
      return;
    }

    var attemptsLeft = 60;
    var settledFrames = 0;
    void scrollWhenRendered() {
      void retry() {
        if (attemptsLeft-- > 0) {
          Future<void>.delayed(
            const Duration(milliseconds: 16),
            scrollWhenRendered,
          );
        }
      }

      final dynamic marker = window.document.getElementById(
        'timeline-event-$index',
      );
      final dynamic strip = window.document.querySelector(
        '.$_timelineScrollClass',
      );
      if (marker == null || strip == null || (strip.clientWidth as num) <= 0) {
        retry();
        return;
      }

      final settled = [
        _scrollPaneToChild(strip, marker, horizontal: true),
        // The lane of one frame, which scrolls on its own when the frame holds
        // more events than fit.
        _scrollPaneToChild(
          marker.closest('.frame-events'),
          marker,
          horizontal: false,
        ),
      ].every((atTarget) => atTarget);
      settledFrames = settled ? settledFrames + 1 : 0;
      if (settledFrames < 3) {
        retry();
      }
    }

    scrollWhenRendered();
  }

  /// Scrolls [pane] by the least amount that puts [child] inside it.
  ///
  /// Reports whether the pane sits where it should afterwards, which is how
  /// the caller knows the position survived the last re-render.
  bool _scrollPaneToChild(
    dynamic pane,
    dynamic child, {
    required bool horizontal,
  }) {
    if (pane == null) {
      return true;
    }
    final num viewSize =
        (horizontal ? pane.clientWidth : pane.clientHeight) as num;
    final num maxScroll =
        ((horizontal ? pane.scrollWidth : pane.scrollHeight) as num) - viewSize;
    if (maxScroll <= 0) {
      // Everything fits, there is nothing to bring into view.
      return true;
    }

    final dynamic paneRect = pane.getBoundingClientRect();
    final dynamic childRect = child.getBoundingClientRect();
    final num current = (horizontal ? pane.scrollLeft : pane.scrollTop) as num;
    final num start =
        current +
        ((horizontal ? childRect.left : childRect.top) as num) -
        ((horizontal ? paneRect.left : paneRect.top) as num);
    final num end =
        start + ((horizontal ? childRect.width : childRect.height) as num);

    num target = current;
    if (start - _timelineScrollPadding < current) {
      target = start - _timelineScrollPadding;
    } else if (end + _timelineScrollPadding > current + viewSize) {
      target = end + _timelineScrollPadding - viewSize;
    }
    final rounded = target.clamp(0, maxScroll).round();
    if (current.round() != rounded) {
      if (horizontal) {
        pane.scrollLeft = rounded;
      } else {
        pane.scrollTop = rounded;
      }
    }
    final num after = (horizontal ? pane.scrollLeft : pane.scrollTop) as num;
    return after.round() == rounded;
  }

  void _selectTab(_InspectorTab tab) {
    setState(() => _selectedTab = tab);
    if (tab == _InspectorTab.details) {
      _scrollCallerIntoView(_selectedEvent?.callerLine);
    }
  }

  String _eventColor(TimelineEvent event) {
    final value = event.color;
    if (value == null) {
      return '#77808f';
    }
    return '#${value.toRadixString(16).padLeft(6, '0')}';
  }

  /// How far into the test the event happened, on the simulated clock.
  String _elapsedLabel(TimelineEvent event) {
    return _elapsedSince(_firstTimestamp, event.timestamp);
  }

  /// How far into the test the event happened, in real time.
  ///
  /// Diverges from [_elapsedLabel] as soon as the test pumps a duration: the
  /// simulated clock jumps ahead while the wall clock reports the milliseconds
  /// the work really took.
  String _wallElapsedLabel(TimelineEvent event) {
    return _elapsedSince(_firstWallTimestamp, event.wallTimestamp);
  }

  String _elapsedSince(DateTime? first, String timestamp) {
    final parsed = DateTime.tryParse(timestamp);
    if (first == null || parsed == null) {
      return timestamp;
    }
    final milliseconds = parsed.difference(first).inMicroseconds / 1000;
    if (milliseconds >= 1000) {
      return '+${(milliseconds / 1000).toStringAsFixed(2)} s';
    }
    return '+${milliseconds.toStringAsFixed(0)} ms';
  }

  Component _rulerCell(TimelineFrameGroup frame, List<TimelineEvent> events) {
    return div(classes: 'ruler-cell', [
      span(classes: 'ruler-cell__time', [
        Component.text(_elapsedLabel(events[frame.eventIndexes.first])),
      ]),
      span(
        classes:
            'ruler-cell__frame ${frame.screenshotUrl == null ? 'is-missing' : ''}',
        [Component.text(_frameLabel(frame))],
      ),
    ]);
  }

  Component _frameEventMarkers(
    TimelineFrameGroup frame,
    List<TimelineEvent> events,
  ) {
    return div(
      classes: 'frame-events',
      attributes: {
        'role': 'group',
        'aria-label': 'Events for ${_frameLabel(frame)}',
      },
      [
        for (final index in frame.eventIndexes)
          _eventMarker(events[index], index),
      ],
    );
  }

  /// The frames the test rendered without recording anything in them.
  ///
  /// Deliberately not selectable: there is nothing behind it to show, and the
  /// arrow keys walk frames, so they step straight over it.
  Component _frameGap(TimelineGap gap) {
    final frames =
        '${_count(gap.frames)} '
        '${gap.frames == 1 ? 'frame' : 'frames'}';
    return div(
      classes: 'frame-gap',
      attributes: {
        'aria-hidden': 'true',
        'title':
            '$frames rendered without an event · '
            '${_durationLabel(gap.testClock)} test clock · '
            '${_durationLabel(gap.wallClock)} wall clock',
      },
      [
        const span(classes: 'frame-gap__ellipsis', [Component.text('⋯')]),
        span(classes: 'frame-gap__frames', [
          Component.text(_count(gap.frames)),
        ]),
        span(classes: 'frame-gap__label', [
          Component.text(gap.frames == 1 ? 'frame' : 'frames'),
        ]),
        span(classes: 'frame-gap__time', [
          Component.text(_durationLabel(gap.testClock)),
          const span(classes: 'frame-gap__clock', [Component.text('test')]),
        ]),
        span(classes: 'frame-gap__time', [
          Component.text(_durationLabel(gap.wallClock)),
          const span(classes: 'frame-gap__clock', [Component.text('wall')]),
        ]),
      ],
    );
  }

  /// The frame a group was rendered in, counted the way the test rendered it.
  ///
  /// Falls back to the group's own number for reports written before frames
  /// were counted.
  String _frameLabel(TimelineFrameGroup frame) {
    return 'Frame ${_count(frame.renderedFrameNumber)}';
  }

  /// [value] with thousands separators, because frame counts reach five digits.
  String _count(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer(value < 0 ? '-' : '');
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[index]);
    }
    return buffer.toString();
  }

  String _durationLabel(Duration duration) {
    final milliseconds = duration.inMicroseconds / 1000;
    if (milliseconds >= 1000) {
      return '${(milliseconds / 1000).toStringAsFixed(2)} s';
    }
    return '${milliseconds.toStringAsFixed(0)} ms';
  }

  @override
  Component build(BuildContext context) {
    final events = component.timelineEvents;
    final frames = groupTimelineFrames(events);
    final columns = timelineTrackColumns(events, frames);
    final capturedFrames = frames
        .where((frame) => frame.screenshotUrl != null)
        .length;
    final frameByEvent = {
      for (final frame in frames)
        for (final index in frame.eventIndexes) index: frame,
    };

    return main_(
      id: 'timeline-app',
      classes: 'timeline-app',
      styles: Styles(
        raw: {'--timeline-height': '${_timelineHeight.toStringAsFixed(0)}px'},
      ),
      [
        const a(href: '#inspector', classes: 'skip-link', [
          Component.text('Skip to inspector'),
        ]),
        header(classes: 'app-bar', [
          const div(classes: 'brand', [
            span(classes: 'brand-mark', [Component.text('S')]),
            span(classes: 'brand-name', [Component.text('Spot timeline')]),
          ]),
          div(classes: 'test-title', [
            const span(classes: 'test-title__label', [Component.text('Test')]),
            span(classes: 'test-title__value', [
              Component.text(component.testNameWithHierarchy),
            ]),
          ]),
          div(classes: 'app-actions', [
            span(classes: 'shortcut-hint', [
              const Component.text('Frames'),
              _keyboardKey('←'),
              _keyboardKey('→'),
              const Component.text('Events'),
              _keyboardKey('↑'),
              _keyboardKey('↓'),
            ]),
            button(
              type: ButtonType.button,
              classes: 'toolbar-button',
              attributes: const {'aria-label': 'Copy test command'},
              onClick: () async {
                final command =
                    'flutter test --plain-name="${component.testName}"';
                try {
                  await window.navigator.clipboard?.writeText(command);
                  _snackBar.currentState!.show('Test command copied');
                } catch (error, stackTrace) {
                  developer.log(
                    'Could not copy the test command',
                    name: 'spot.timeline',
                    error: error,
                    stackTrace: stackTrace,
                  );
                  _snackBar.currentState!.show('Failed to copy test command');
                }
              },
              const [Component.text('Copy command')],
            ),
          ]),
        ]),
        section(
          classes: 'timeline-panel',
          attributes: const {'aria-label': 'Test event timeline'},
          [
            div(classes: 'timeline-summary', [
              div(classes: 'range-summary', [
                const span(classes: 'range-label', [
                  Component.text('Full range'),
                ]),
                strong([Component.text(_durationLabel(_duration))]),
                if (_selectedIndex != null)
                  span(classes: 'selection-summary', [
                    Component.text(
                      '${_frameLabel(frameByEvent[_selectedIndex]!)} · Event ${frameByEvent[_selectedIndex]!.eventIndexes.indexOf(_selectedIndex!) + 1} of ${frameByEvent[_selectedIndex]!.eventIndexes.length}',
                    ),
                  ]),
              ]),
              div(classes: 'timeline-counts', [
                span([
                  Component.text(
                    '${events.length} ${events.length == 1 ? 'event' : 'events'}',
                  ),
                ]),
                span([
                  Component.text(
                    '${frames.length} ${frames.length == 1 ? 'frame' : 'frames'}',
                  ),
                ]),
                span([Component.text('$capturedFrames captured')]),
                if (component.renderedFrameCount > 0)
                  span(
                    classes: 'timeline-counts__rendered',
                    attributes: const {
                      'title':
                          'Frames the test rendered in total. Fewer frames is '
                          'a faster test: prefer pump over pumpAndSettle where '
                          'it does the job.',
                    },
                    [
                      Component.text(
                        '${_count(component.renderedFrameCount)} rendered',
                      ),
                    ],
                  ),
              ]),
            ]),
            if (events.isEmpty)
              const div(classes: 'empty-timeline', [
                Component.text('No timeline events were recorded.'),
              ])
            else
              div(classes: _timelineScrollClass, [
                div(
                  classes: 'timeline-track',
                  styles: Styles(
                    raw: {
                      '--frame-count': frames.length.toString(),
                      '--gap-count': columns
                          .where((column) => column.gap != null)
                          .length
                          .toString(),
                      // The three rows below are separate grids, so they only
                      // line up while they share one set of track widths.
                      '--track-columns': columns
                          .map(
                            (column) => column.gap == null
                                ? 'var(--track-cell-width)'
                                : 'var(--gap-cell-width)',
                          )
                          .join(' '),
                    },
                  ),
                  [
                    div(classes: 'time-ruler', [
                      for (final column in columns)
                        column.gap != null
                            ? const div(classes: 'ruler-cell is-gap', [])
                            : _rulerCell(column.frame!, events),
                    ]),
                    div(classes: 'filmstrip', [
                      for (final column in columns)
                        column.gap != null
                            ? _frameGap(column.gap!)
                            : _frameCapture(column.frame!),
                    ]),
                    div(classes: 'event-lane', [
                      div(classes: 'lane-events', [
                        for (final column in columns)
                          column.gap != null
                              ? const div(classes: 'frame-events is-gap', [])
                              : _frameEventMarkers(column.frame!, events),
                      ]),
                    ]),
                  ],
                ),
              ]),
          ],
        ),
        _resizeHandle(
          _ResizeTarget.timeline,
          orientation: 'horizontal',
          label: 'Resize timeline and inspector',
        ),
        _inspector(),
        SnackBar(key: _snackBar),
        if (_lightboxEvent != null) _lightbox(_lightboxEvent!),
      ],
    );
  }

  Component _resizeHandle(
    _ResizeTarget target, {
    required String orientation,
    required String label,
  }) {
    final (value, minimum, maximum, unit) = switch (target) {
      _ResizeTarget.timeline => (
        _timelineHeight,
        _minimumTimelineHeight,
        600,
        'pixels',
      ),
      _ResizeTarget.captureTree => (_capturePanePercent, 20, 80, 'percent'),
      _ResizeTarget.treeDetails => (_treePanePercent, 25, 82, 'percent'),
    };
    return button(
      type: ButtonType.button,
      classes: 'resize-handle resize-handle--$orientation',
      attributes: {
        'role': 'separator',
        'aria-label': label,
        'aria-orientation': orientation,
        'aria-valuemin': minimum.toString(),
        'aria-valuemax': maximum.toString(),
        'aria-valuenow': value.round().toString(),
        'aria-valuetext': '${value.round()} $unit',
        'title': '$label. Drag or use arrow keys.',
      },
      events: {
        'mousedown': (event) => _startResizing(target, event),
        'keydown': (event) => _resizeWithKeyboard(target, event),
      },
      const [span(classes: 'resize-handle__grip', [])],
    );
  }

  Component _frameCapture(TimelineFrameGroup frame) {
    final firstEventIndex = frame.eventIndexes.first;
    final event = component.timelineEvents[firstEventIndex];
    final selected =
        _selectedIndex != null && frame.eventIndexes.contains(_selectedIndex);
    final assertionCount = frame.eventIndexes
        .where(
          (index) => component.timelineEvents[index].eventType
              .toLowerCase()
              .startsWith('assertion'),
        )
        .length;
    final eventSummary = assertionCount == frame.eventIndexes.length
        ? '$assertionCount ${assertionCount == 1 ? 'assertion' : 'assertions'}'
        : '${frame.eventIndexes.length} ${frame.eventIndexes.length == 1 ? 'event' : 'events'}';
    return button(
      type: ButtonType.button,
      classes: 'capture ${selected ? 'is-selected' : ''}',
      styles: Styles(raw: {'--event-color': _eventColor(event)}),
      attributes: {
        'aria-label':
            '${_frameLabel(frame)}, $eventSummary, ${frame.screenshotUrl == null ? 'not captured' : 'captured'}',
        'aria-pressed': selected.toString(),
        'tabindex': selected || (_selectedIndex == null && firstEventIndex == 0)
            ? '0'
            : '-1',
        'title': '${_frameLabel(frame)} · $eventSummary',
      },
      onClick: () => _select(selected ? _selectedIndex! : firstEventIndex),
      [
        div(classes: 'capture-image', [
          if (frame.screenshotUrl != null)
            img(
              src: frame.screenshotUrl!,
              alt: 'Capture for frame ${frame.renderedFrameNumber}',
              attributes: const {'loading': 'lazy', 'decoding': 'async'},
            )
          else
            div(classes: 'capture-placeholder', [
              span(classes: 'capture-placeholder__index', [
                Component.text('${frame.renderedFrameNumber}'),
              ]),
              const span([Component.text('No capture')]),
            ]),
        ]),
        div(classes: 'capture-caption', [
          span(classes: 'capture-number', [
            Component.text(
              'F${frame.renderedFrameNumber.toString().padLeft(2, '0')}',
            ),
          ]),
          span(classes: 'capture-name', [Component.text(eventSummary)]),
        ]),
      ],
    );
  }

  Component _keyboardKey(String value) {
    return Component.element(tag: 'kbd', children: [Component.text(value)]);
  }

  Component _eventMarker(TimelineEvent event, int index) {
    final selected = _selectedIndex == index;
    return button(
      id: 'timeline-event-$index',
      type: ButtonType.button,
      classes: 'event-marker ${selected ? 'is-selected' : ''}',
      styles: Styles(raw: {'--event-color': _eventColor(event)}),
      attributes: {
        'aria-label': 'Select ${event.eventType}',
        'aria-pressed': selected.toString(),
        'tabindex': '-1',
        'title':
            '${event.eventType} · ${_elapsedLabel(event)} test clock '
            '· ${_wallElapsedLabel(event)} wall clock',
      },
      onClick: () => _select(index),
      [
        const span(classes: 'event-marker__dot', []),
        span(classes: 'event-marker__label', [Component.text(event.eventType)]),
      ],
    );
  }

  Component _inspector() {
    final event = _selectedEvent;
    return section(id: 'inspector', classes: 'inspector', [
      if (event == null)
        const div(classes: 'inspector-empty', [
          div(classes: 'inspector-empty__icon', [Component.text('◇')]),
          h2([Component.text('Select an event')]),
          p([
            Component.text(
              'Choose a capture or event marker above. Use left and right to move between frames, and up and down to move between events.',
            ),
          ]),
        ])
      else
        _eventWorkbench(event),
    ]);
  }

  Component _tabButton(
    _InspectorTab tab,
    String label, {
    required String panelId,
  }) {
    final selected = _selectedTab == tab;
    return button(
      id: 'inspector-tab-${tab.name}',
      type: ButtonType.button,
      classes: 'tab-button ${selected ? 'is-selected' : ''}',
      attributes: {
        'role': 'tab',
        'aria-selected': selected.toString(),
        'aria-controls': panelId,
        'tabindex': selected ? '0' : '-1',
      },
      onClick: () => _selectTab(tab),
      [Component.text(label)],
    );
  }

  Component _eventWorkbench(TimelineEvent event) {
    final root = _widgetTreeRoot(event);
    final selectedNode = root == null
        ? null
        : _findWidgetNode(root, _selectedWidgetNodeId);
    final screenshotUrl = event.screenshotUrl;

    return div(
      id: 'interactive-inspector',
      classes: 'interactive-inspector',
      styles: Styles(
        raw: {
          '--capture-pane-width': '${_capturePanePercent.toStringAsFixed(2)}%',
        },
      ),
      [
        div(classes: 'capture-workbench', [
          div(classes: 'pane-toolbar', [
            const span(classes: 'pane-title', [Component.text('Capture')]),
            div(classes: 'capture-toolbar-actions', [
              if (selectedNode != null)
                span(classes: 'selected-widget-label', [
                  Component.text(_nodeName(selectedNode)),
                ]),
              if (event.overlayUrls.isNotEmpty || selectedNode != null)
                button(
                  type: ButtonType.button,
                  classes: 'text-button',
                  attributes: {
                    'aria-label': 'Toggle capture overlays',
                    'aria-pressed': _showCaptureOverlays.toString(),
                  },
                  onClick: () {
                    setState(
                      () => _showCaptureOverlays = !_showCaptureOverlays,
                    );
                  },
                  [
                    Component.text(
                      _showCaptureOverlays ? 'Hide overlays' : 'Show overlays',
                    ),
                  ],
                ),
              if (screenshotUrl != null)
                a(
                  href: screenshotUrl,
                  target: Target.blank,
                  classes: 'text-button capture-image-link',
                  attributes: const {'rel': 'noopener'},
                  const [Component.text('Open image')],
                ),
            ]),
          ]),
          _captureWithOutline(event, selectedNode),
        ]),
        _resizeHandle(
          _ResizeTarget.captureTree,
          orientation: 'vertical',
          label: 'Resize capture and event inspector',
        ),
        div(classes: 'inspector-sidebar', [
          nav(
            classes: 'inspector-tabs',
            attributes: const {
              'aria-label': 'Event inspector',
              'role': 'tablist',
            },
            [
              _tabButton(
                _InspectorTab.details,
                'Event details',
                panelId: 'event-details-panel',
              ),
              _tabButton(
                _InspectorTab.widgetInspector,
                'Widget tree',
                panelId: 'widget-inspector-panel',
              ),
              _tabButton(
                _InspectorTab.widgetTree,
                'Tree text',
                panelId: 'tree-text-panel',
              ),
              _tabButton(
                _InspectorTab.raw,
                'Raw data',
                panelId: 'raw-data-panel',
              ),
            ],
          ),
          div(
            id: switch (_selectedTab) {
              _InspectorTab.details => 'event-details-panel',
              _InspectorTab.widgetInspector => 'widget-inspector-panel',
              _InspectorTab.widgetTree => 'tree-text-panel',
              _InspectorTab.raw => 'raw-data-panel',
            },
            classes: 'inspector-content',
            attributes: const {'role': 'tabpanel'},
            [
              switch (_selectedTab) {
                _InspectorTab.details => _detailsPanel(event),
                _InspectorTab.widgetInspector => _widgetExplorer(event),
                _InspectorTab.widgetTree => _widgetTreePanel(event),
                _InspectorTab.raw => _rawPanel(event),
              },
            ],
          ),
        ]),
      ],
    );
  }

  Component _widgetExplorer(TimelineEvent event) {
    final root = _widgetTreeRoot(event);
    final selectedNode = root == null
        ? null
        : _findWidgetNode(root, _selectedWidgetNodeId);
    final searchResult = searchStructuredWidgetTree(root, _widgetTreeSearch);
    final searchActive = _widgetTreeSearch.trim().isNotEmpty;

    return div(
      id: 'widget-explorer',
      classes: 'widget-explorer',
      styles: Styles(
        raw: {'--tree-pane-height': '${_treePanePercent.toStringAsFixed(2)}%'},
      ),
      [
        div(classes: 'pane-toolbar pane-toolbar--tree', [
          const span(classes: 'pane-title', [Component.text('Widget tree')]),
          div(classes: 'tree-toolbar-controls', [
            input<String>(
              type: InputType.search,
              value: _widgetTreeSearch,
              classes: 'widget-search',
              attributes: const {
                'aria-label': 'Search widget types',
                'placeholder': 'Search widget types',
                'autocomplete': 'off',
                'spellcheck': 'false',
              },
              onInput: (value) {
                setState(() => _widgetTreeSearch = value);
              },
              events: {
                'keydown': (event) {
                  final dynamic keyboardEvent = event;
                  if (keyboardEvent.key != 'Enter') {
                    return;
                  }
                  keyboardEvent.preventDefault();
                  _selectNextSearchMatch(
                    root,
                    reverse: keyboardEvent.shiftKey == true,
                  );
                },
              },
            ),
            if (searchActive)
              span(classes: 'search-result-count', [
                Component.text(
                  '${searchResult.matches.length} ${searchResult.matches.length == 1 ? 'match' : 'matches'}',
                ),
              ]),
            if (!searchActive)
              div(classes: 'tree-actions', [
                button(
                  type: ButtonType.button,
                  classes: 'text-button',
                  onClick: () => _collapseWidgetTree(root),
                  const [Component.text('Collapse')],
                ),
                button(
                  type: ButtonType.button,
                  classes: 'text-button',
                  onClick: () => _expandWidgetTree(root),
                  const [Component.text('Expand all')],
                ),
              ]),
          ]),
        ]),
        if (root == null)
          const div(classes: 'tree-empty', [
            Component.text('No structured widget tree was captured.'),
          ])
        else if (searchActive && searchResult.matches.isEmpty)
          div(classes: 'tree-empty', [
            Component.text('No widget types match “$_widgetTreeSearch”.'),
          ])
        else
          _widgetTreeRows(
            root,
            visibleNodeIds: searchResult.visible,
            matchingNodeIds: searchResult.matches,
            searchActive: searchActive,
          ),
        _resizeHandle(
          _ResizeTarget.treeDetails,
          orientation: 'horizontal',
          label: 'Resize widget tree and widget details',
        ),
        _widgetProperties(selectedNode),
      ],
    );
  }

  Component _captureWithOutline(
    TimelineEvent event,
    Map<String, dynamic>? selectedNode,
  ) {
    final frameData = _frameDataFor(event);
    final screenshotUrl = event.screenshotUrl;
    if (screenshotUrl == null) {
      return const div(classes: 'capture-empty', [
        h3([Component.text('No capture for this event')]),
        p([
          Component.text(
            'The widget tree is still available, but widgets cannot be outlined without an image.',
          ),
        ]),
      ]);
    }

    final bounds = _asStringMap(selectedNode?['bounds']);
    final captureWidth = frameData.structuredWidgetTree['captureWidth'] as num?;
    final captureHeight =
        frameData.structuredWidgetTree['captureHeight'] as num?;
    final canOutline =
        bounds != null &&
        captureWidth != null &&
        captureWidth > 0 &&
        captureHeight != null &&
        captureHeight > 0;

    return div(classes: 'capture-viewport', [
      div(
        classes: 'capture-canvas is-zoomable',
        attributes: const {'title': 'Click to open the capture full screen'},
        events: {'click': (dynamic _) => _openLightbox(event)},
        [
          img(
            src: screenshotUrl,
            classes: 'capture-base-image',
            alt: 'Frame capture for ${event.eventType}',
          ),
          if (_showCaptureOverlays)
            for (final overlayUrl in event.overlayUrls)
              img(
                src: overlayUrl,
                classes: 'capture-event-overlay',
                alt: '',
                attributes: const {'aria-hidden': 'true'},
              ),
          if (_showCaptureOverlays && canOutline)
            div(
              classes: 'widget-outline',
              styles: Styles(
                raw: {
                  'left':
                      '${((bounds['x'] as num) / captureWidth * 100).toStringAsFixed(4)}%',
                  'top':
                      '${((bounds['y'] as num) / captureHeight * 100).toStringAsFixed(4)}%',
                  'width':
                      '${((bounds['width'] as num) / captureWidth * 100).toStringAsFixed(4)}%',
                  'height':
                      '${((bounds['height'] as num) / captureHeight * 100).toStringAsFixed(4)}%',
                },
              ),
              attributes: {
                'aria-label': 'Bounds of ${_nodeName(selectedNode!)}',
              },
              const [],
            ),
        ],
      ),
    ]);
  }

  /// The widget tree, rendering only the rows that are in view.
  ///
  /// A captured tree runs to thousands of nodes and each row is several DOM
  /// elements, so rendering all of them blocks the page for seconds. The rows
  /// are all the same height, so the ones outside the viewport can be replaced
  /// by two spacers that keep the scrollbar honest.
  Component _widgetTreeRows(
    Map<String, dynamic>? root, {
    required Set<String> visibleNodeIds,
    required Set<String> matchingNodeIds,
    required bool searchActive,
  }) {
    final rows = flattenWidgetTree(
      root,
      expandedNodeIds: _expandedWidgetNodes,
      visibleNodeIds: visibleNodeIds,
      searchActive: searchActive,
    );
    final firstVisible = math.max(
      0,
      (_treeScrollTop / _treeRowHeight).floor() - _treeOverscanRows,
    );
    final windowRows =
        (_treeViewportHeight / _treeRowHeight).ceil() + _treeOverscanRows * 2;
    final lastVisible = math.min(rows.length, firstVisible + windowRows);

    return div(
      id: _widgetTreeId,
      classes:
          'interactive-tree ${_arrowsDriveWidgetTree ? 'has-arrow-keys' : ''}',
      attributes: const {'role': 'tree', 'aria-label': 'Flutter widget tree'},
      events: {'scroll': _onTreeScroll},
      [
        if (firstVisible > 0)
          div(
            classes: 'tree-spacer',
            styles: Styles(
              raw: {'height': '${firstVisible * _treeRowHeight}px'},
            ),
            const [],
          ),
        for (var index = firstVisible; index < lastVisible; index++)
          _widgetTreeRow(rows[index], matchingNodeIds: matchingNodeIds),
        if (lastVisible < rows.length)
          div(
            classes: 'tree-spacer',
            styles: Styles(
              raw: {
                'height': '${(rows.length - lastVisible) * _treeRowHeight}px',
              },
            ),
            const [],
          ),
      ],
    );
  }

  void _onTreeScroll(dynamic event) {
    final dynamic target = event.currentTarget ?? event.target;
    if (target == null) {
      return;
    }
    final double scrollTop = (target.scrollTop as num).toDouble();
    final double height = (target.clientHeight as num).toDouble();
    // Re-render only when the window of rows would actually change.
    if ((scrollTop - _treeScrollTop).abs() < _treeRowHeight &&
        height == _treeViewportHeight) {
      return;
    }
    setState(() {
      _treeScrollTop = scrollTop;
      _treeViewportHeight = height;
    });
  }

  Component _widgetTreeRow(
    TreeRow row, {
    required Set<String> matchingNodeIds,
  }) {
    final node = row.node;
    final id = row.id;
    final depth = row.depth;
    final expanded = row.expanded;
    final selected = _selectedWidgetNodeId == id;
    final searchMatch = matchingNodeIds.contains(id);
    final offstage = node['offstage'] == true;
    final hasBounds = node['bounds'] != null;

    return div(
      classes: 'tree-node',
      attributes: {
        'role': 'treeitem',
        'aria-expanded': !row.hasChildren ? 'false' : expanded.toString(),
        'aria-selected': selected.toString(),
      },
      [
        div(
          classes:
              'tree-node__row ${selected ? 'is-selected' : ''} ${searchMatch ? 'is-search-match' : ''} ${offstage ? 'is-offstage' : ''}',
          styles: Styles(raw: {'--tree-depth': depth.toString()}),
          [
            if (!row.hasChildren)
              const span(classes: 'tree-expander-spacer', [])
            else
              button(
                type: ButtonType.button,
                classes: 'tree-expander',
                attributes: {
                  'aria-label':
                      '${expanded ? 'Collapse' : 'Expand'} ${_nodeName(node)}',
                  'tabindex': '-1',
                },
                onClick: () => _toggleWidgetNode(id),
                [Component.text(expanded ? '▾' : '▸')],
              ),
            button(
              id: 'widget-node-$id',
              type: ButtonType.button,
              classes: 'tree-node__select',
              attributes: {
                'aria-label': 'Inspect ${_nodeDescription(node)}',
                'tabindex':
                    selected || (_selectedWidgetNodeId == null && id == '0')
                    ? '0'
                    : '-1',
              },
              onClick: () => _selectWidgetNode(id),
              [
                span(classes: 'tree-node__name', [
                  Component.text(_nodeName(node)),
                ]),
                if (_nodeDescription(node) != _nodeName(node))
                  span(classes: 'tree-node__description', [
                    Component.text(_nodeDescription(node)),
                  ]),
                if (offstage)
                  const span(classes: 'node-badge', [
                    Component.text('offstage'),
                  ]),
                if (hasBounds)
                  const span(
                    classes: 'bounds-indicator',
                    attributes: {'title': 'Can be highlighted on capture'},
                    [],
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Component _widgetProperties(Map<String, dynamic>? node) {
    if (node == null) {
      return const div(classes: 'widget-properties widget-properties--empty', [
        Component.text('Select a widget to inspect its properties.'),
      ]);
    }

    final widgetProperties = _nodeProperties(node, 'widgetProperties');
    final renderProperties = _nodeProperties(node, 'renderProperties');
    final bounds = _asStringMap(node['bounds']);

    return div(classes: 'widget-properties', [
      div(classes: 'properties-heading', [
        div([
          strong([Component.text(_nodeName(node))]),
          span([Component.text(node['elementType'] as String? ?? 'Element')]),
        ]),
        if (bounds != null)
          span(classes: 'bounds-summary', [
            Component.text(
              '${(bounds['width'] as num).toStringAsFixed(1)} × ${(bounds['height'] as num).toStringAsFixed(1)}',
            ),
          ]),
      ]),
      div(classes: 'properties-scroll', [
        _propertyGroup('Widget properties', widgetProperties),
        _propertyGroup('Render object', renderProperties),
      ]),
    ]);
  }

  Component _propertyGroup(
    String label,
    List<Map<String, dynamic>> properties,
  ) {
    return div(classes: 'property-group', [
      h3([Component.text(label)]),
      if (properties.isEmpty)
        const p(classes: 'property-empty', [
          Component.text('No diagnostic properties'),
        ])
      else
        dl([
          for (final property in properties)
            div(classes: 'property-row', [
              dt([Component.text(property['name'] as String? ?? '')]),
              dd([Component.text(property['value'] as String? ?? '')]),
            ]),
        ]),
    ]);
  }

  void _selectWidgetNode(String id) {
    setState(() => _selectedWidgetNodeId = id);
  }

  void _selectNextSearchMatch(
    Map<String, dynamic>? root, {
    required bool reverse,
  }) {
    final matches = searchStructuredWidgetTree(
      root,
      _widgetTreeSearch,
    ).matches.toList(growable: false);
    final id = nextStructuredWidgetSearchMatch(
      matches,
      _selectedWidgetNodeId,
      reverse: reverse,
    );
    if (id == null) {
      return;
    }

    _selectWidgetNode(id);
    _scrollTreeToNode(id);
  }

  /// Brings the row for [id] into view, sideways as well as down.
  ///
  /// scrollIntoView is not enough: the row may not be rendered yet, because
  /// the tree only renders what is in view, and a deep row can sit past the
  /// right edge of the pane.
  void _scrollTreeToNode(String id) {
    if (!kIsWeb) {
      return;
    }
    final rows = _currentTreeRows();
    final index = rows.indexWhere((row) => row.id == id);
    if (index == -1) {
      return;
    }

    final dynamic tree = window.document.querySelector('#$_widgetTreeId');
    if (tree == null) {
      return;
    }
    final double viewport = (tree.clientHeight as num).toDouble();
    final top = index * _treeRowHeight - (viewport - _treeRowHeight) / 2;
    tree.scrollTop = top.clamp(0, double.infinity).round();
    // Indentation is the only thing that pushes a row sideways, so the row's
    // depth says how far to scroll to put its label back on screen.
    final indent = rows[index].depth * _treeIndentWidth;
    final double width = (tree.clientWidth as num).toDouble();
    final currentLeft = (tree.scrollLeft as num).toDouble();
    if (indent < currentLeft || indent > currentLeft + width - 120) {
      tree.scrollLeft = math.max(0, indent - 40).round();
    }
    setState(() {
      _treeScrollTop = top.clamp(0, double.infinity);
      _treeViewportHeight = viewport;
    });
  }

  void _toggleWidgetNode(String id) {
    setState(() {
      if (!_expandedWidgetNodes.remove(id)) {
        _expandedWidgetNodes.add(id);
      }
    });
  }

  void _collapseWidgetTree(Map<String, dynamic>? root) {
    setState(() {
      _expandedWidgetNodes
        ..clear()
        ..add(root?['id'] as String? ?? '0');
    });
  }

  void _expandWidgetTree(Map<String, dynamic>? root) {
    if (root == null) {
      return;
    }
    final ids = collectStructuredWidgetNodeIds(root);
    setState(() {
      _expandedWidgetNodes
        ..clear()
        ..addAll(ids);
    });
  }

  Map<String, dynamic>? _widgetTreeRoot(TimelineEvent event) {
    return _asStringMap(_frameDataFor(event).structuredWidgetTree['root']);
  }

  TimelineEvent _frameDataFor(TimelineEvent event) {
    if (event.widgetTree.isNotEmpty || event.structuredWidgetTree.isNotEmpty) {
      return event;
    }
    final frameNumber = event.frameNumber;
    if (frameNumber != null) {
      final decoded = _decodedFrameData[frameNumber];
      if (decoded != null) {
        return decoded;
      }
    }
    final payloadEvent = component.timelineEvents.firstWhere(
      (candidate) =>
          candidate.frameNumber == event.frameNumber &&
          (candidate.widgetTree.isNotEmpty ||
              candidate.structuredWidgetTree.isNotEmpty ||
              candidate.compressedFrameData != null),
      orElse: () => event,
    );
    final compressed = payloadEvent.compressedFrameData;
    if (compressed == null) {
      return payloadEvent;
    }
    final data = decompressTimelineFrameData(compressed);
    final decoded = TimelineEvent(
      eventType: payloadEvent.eventType,
      color: payloadEvent.color,
      screenshotUrl: payloadEvent.screenshotUrl,
      overlayUrls: payloadEvent.overlayUrls,
      details: payloadEvent.details,
      timestamp: payloadEvent.timestamp,
      wallTimestamp: payloadEvent.wallTimestamp,
      caller: payloadEvent.caller,
      ideLink: payloadEvent.ideLink,
      ideName: payloadEvent.ideName,
      sourcePath: payloadEvent.sourcePath,
      callerLine: payloadEvent.callerLine,
      isFailure: payloadEvent.isFailure,
      widgetTree: data.widgetTree,
      structuredWidgetTree: data.structuredWidgetTree,
      frameNumber: payloadEvent.frameNumber,
    );
    if (frameNumber != null) {
      _decodedFrameData[frameNumber] = decoded;
    }
    return decoded;
  }

  Map<String, dynamic>? _findWidgetNode(Map<String, dynamic> node, String? id) {
    if (id == null) {
      return null;
    }
    if (node['id'] == id) {
      return node;
    }
    for (final child in _nodeChildren(node)) {
      final match = _findWidgetNode(child, id);
      if (match != null) {
        return match;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _nodeChildren(Map<String, dynamic> node) {
    final children = node['children'];
    if (children is! List) {
      return const [];
    }
    return children
        .map(_asStringMap)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _nodeProperties(
    Map<String, dynamic> node,
    String key,
  ) {
    final properties = node[key];
    if (properties is! List) {
      return const [];
    }
    return properties
        .map(_asStringMap)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  Map<String, dynamic>? _asStringMap(Object? value) {
    if (value is! Map) {
      return null;
    }
    return value.cast<String, dynamic>();
  }

  String _nodeName(Map<String, dynamic> node) {
    return node['name'] as String? ?? 'Widget';
  }

  String _nodeDescription(Map<String, dynamic> node) {
    return node['description'] as String? ?? _nodeName(node);
  }

  Component _detailsPanel(TimelineEvent event) {
    final source = _sourceFileFor(event);
    return div(classes: 'details-panel', [
      div(classes: 'details-content', [
        div(classes: 'details-primary', [
          h3(classes: 'details-heading', [
            span(
              classes:
                  'details-heading__dot ${event.isFailure ? 'is-failure' : ''}',
              styles: Styles(raw: {'--event-color': _eventColor(event)}),
              const [],
            ),
            Component.text(event.eventType),
          ]),
          pre(classes: 'details-copy', [Component.text(event.details)]),
          _timings(event),
        ]),
        if (source != null)
          _sourceView(source, event.callerLine, event.ideLink),
      ]),
    ]);
  }

  /// Puts [callerLine] near the top of the source pane.
  ///
  /// The pane holds the whole file, so without this it shows line 1 and the
  /// caller is somewhere below the fold.
  ///
  /// Waits for the pane to actually hold [callerLine] before measuring.
  /// Rendering happens after the state change, so scrolling straight away
  /// would measure the previously selected event's line and leave the pane
  /// wherever that happened to be.
  void _scrollCallerIntoView(int? callerLine) {
    if (!kIsWeb || callerLine == null) {
      return;
    }

    var attemptsLeft = 60;
    var settledFrames = 0;
    void scrollWhenRendered() {
      void retry() {
        if (attemptsLeft-- > 0) {
          Future<void>.delayed(
            const Duration(milliseconds: 16),
            scrollWhenRendered,
          );
        }
      }

      final dynamic pane = window.document.querySelector('#$_sourceCodeId');
      final dynamic line = window.document.querySelector('#$_callerLineId');
      final rendered = line == null
          ? null
          : int.tryParse('${line.getAttribute('data-line')}');
      if (pane == null || line == null || rendered != callerLine) {
        retry();
        return;
      }
      // Assigning scrollTop does nothing while the pane has nothing to
      // scroll, which is the case until it has been laid out.
      final num paneHeight = pane.clientHeight as num;
      if (paneHeight <= 0 || (pane.scrollHeight as num) <= paneHeight) {
        retry();
        return;
      }

      // Measured against the pane rather than through offsetTop, which is
      // relative to the closest positioned ancestor. The pane is not
      // positioned, so offsetTop carried the pane's own distance down the page
      // and scrolled the file that much too far.
      final dynamic paneRect = pane.getBoundingClientRect();
      final dynamic lineRect = line.getBoundingClientRect();
      final num scrollTop = pane.scrollTop as num;
      final num lineOffset = (lineRect.top as num) - (paneRect.top as num);
      final num lineHeight = lineRect.height as num;
      final maxScroll = (pane.scrollHeight as num) - paneHeight;
      // A few lines of lead-in rather than the middle of the pane: the caller
      // is easier to find when it sits near the top, and what follows it is
      // usually what the reader wants next.
      final target =
          (scrollTop + lineOffset - _sourceContextLinesAbove * lineHeight)
              .clamp(0, maxScroll)
              .round();

      if (scrollTop.round() != target) {
        pane.scrollTop = target;
      }
      // Hydration replaces the pane shortly after the first paint and takes
      // the scroll position with it, so hold the position for a few frames
      // rather than trusting the first assignment.
      settledFrames = (pane.scrollTop as num).round() == target
          ? settledFrames + 1
          : 0;
      if (settledFrames < 3) {
        retry();
      }
    }

    scrollWhenRendered();
  }

  /// When the event happened, on both clocks, in one line.
  ///
  /// The test clock is what `fakeAsync` simulated, the wall clock is the time
  /// that really passed. They diverge as soon as a test pumps a duration, which
  /// is the whole reason both are shown.
  Component _timings(TimelineEvent event) {
    return div(classes: 'timings', [
      _timing('Elapsed test clock', _elapsedLabel(event)),
      _timing('Elapsed wall clock', _wallElapsedLabel(event)),
      _timing('At test clock', _timeOfDay(event.timestamp)),
      _timing('At wall clock', _timeOfDay(event.wallTimestamp)),
    ]);
  }

  Component _timing(String label, String value) {
    return div(classes: 'timings__item', [
      span(classes: 'timings__label', [Component.text(label)]),
      span(classes: 'timings__value', [Component.text(value)]),
    ]);
  }

  /// The clock time of [timestamp], without the date.
  ///
  /// A test runs in one day, so the date is noise on every row.
  String _timeOfDay(String timestamp) {
    final parsed = DateTime.tryParse(timestamp);
    if (parsed == null) {
      return timestamp;
    }
    String two(int value) => value.toString().padLeft(2, '0');
    final millis = parsed.millisecond.toString().padLeft(3, '0');
    return '${two(parsed.hour)}:${two(parsed.minute)}:${two(parsed.second)}'
        '.$millis';
  }

  void _openLightbox(TimelineEvent event) {
    setState(() => _lightboxEvent = event);
  }

  void _closeLightbox() {
    setState(() => _lightboxEvent = null);
  }

  /// The capture, full screen, over everything else.
  ///
  /// Dismissed by clicking the backdrop, the close button, or Escape. The
  /// overlays follow the capture pane's toggle so the two show the same thing.
  Component _lightbox(TimelineEvent event) {
    final screenshotUrl = event.screenshotUrl;
    if (screenshotUrl == null) {
      return const Component.fragment([]);
    }
    return div(
      classes: 'lightbox',
      attributes: const {
        'role': 'dialog',
        'aria-modal': 'true',
        'aria-label': 'Capture, full screen',
      },
      events: {'click': (dynamic _) => _closeLightbox()},
      [
        div(
          classes: 'lightbox__actions',
          // Toggling overlays must not reach the backdrop, which dismisses.
          events: {'click': (dynamic event) => event.stopPropagation()},
          [
            if (event.overlayUrls.isNotEmpty)
              button(
                classes: 'lightbox__action',
                attributes: {
                  'aria-pressed': _showCaptureOverlays.toString(),
                  'title': 'Toggle the annotations drawn over the capture',
                },
                onClick: () {
                  setState(() => _showCaptureOverlays = !_showCaptureOverlays);
                },
                [
                  Component.text(
                    _showCaptureOverlays ? 'Hide overlays' : 'Show overlays',
                  ),
                ],
              ),
            button(
              classes: 'lightbox__action',
              attributes: const {'title': 'Close (Esc)'},
              onClick: _closeLightbox,
              const [Component.text('✕')],
            ),
          ],
        ),
        div(
          classes: 'lightbox__stage',
          // The stage swallows the click so only the backdrop dismisses.
          events: {'click': (dynamic event) => event.stopPropagation()},
          [
            img(
              src: screenshotUrl,
              classes: 'lightbox__image',
              alt: 'Capture for ${event.eventType}',
            ),
            if (_showCaptureOverlays)
              for (final overlayUrl in event.overlayUrls)
                img(
                  src: overlayUrl,
                  classes: 'lightbox__image lightbox__image--overlay',
                  alt: '',
                ),
          ],
        ),
        div(classes: 'lightbox__caption', [
          Component.text('${event.eventType} · ${_elapsedLabel(event)}'),
        ]),
      ],
    );
  }

  /// The source file [event] was triggered from, `null` when none was stored.
  TimelineSourceFile? _sourceFileFor(TimelineEvent event) {
    final path = event.sourcePath;
    if (path == null) {
      return null;
    }
    return component.sourceFiles[path];
  }

  /// The whole file, with the caller line highlighted and scrolled to.
  ///
  /// Shows every line rather than a window around the caller, because any
  /// window cuts off the part of the method that explains the event.
  Component _sourceView(
    TimelineSourceFile source,
    int? callerLine,
    String? ideLink,
  ) {
    final location = callerLine == null
        ? source.path
        : '${source.path}:$callerLine';
    return section(classes: 'source-panel', [
      div(classes: 'source-panel__header', [
        const h3([Component.text('Source')]),
        if (ideLink != null)
          a(href: ideLink, [Component.text(location)])
        else
          span([Component.text(location)]),
        if (source.truncated)
          span(classes: 'source-panel__note', [
            Component.text('Showing the first ${source.lines.length} lines'),
          ]),
      ]),
      pre(
        id: _sourceCodeId,
        classes: 'source-code',
        attributes: const {'aria-label': 'Source code of the event caller'},
        [
          for (var index = 0; index < source.lines.length; index++)
            span(
              id: index + 1 == callerLine ? _callerLineId : null,
              attributes: index + 1 == callerLine
                  ? {'data-line': '${index + 1}'}
                  : null,
              classes:
                  'source-line ${index + 1 == callerLine ? 'is-caller' : ''}',
              [
                span(classes: 'source-line__number', [
                  Component.text('${index + 1}'),
                ]),
                span(classes: 'source-line__content', [
                  Component.text(
                    source.lines[index].isEmpty ? ' ' : source.lines[index],
                  ),
                ]),
              ],
            ),
        ],
      ),
    ]);
  }

  Component _widgetTreePanel(TimelineEvent event) {
    final frameData = _frameDataFor(event);
    if (frameData.widgetTree.trim().isEmpty) {
      return const div(classes: 'panel-empty', [
        h3([Component.text('No widget tree was captured')]),
      ]);
    }
    final visibleTree = sliceTimelineText(
      frameData.widgetTree,
      startLine: _treeTextStartLine,
      maximumLines: _treeTextPageLineCount,
    );
    return div(classes: 'tree-panel', [
      div(classes: 'code-toolbar', [
        const span([Component.text('Flutter element tree')]),
        div(classes: 'tree-text-progress', [
          span([
            Component.text(
              visibleTree.hasMore
                  ? 'Lines ${visibleTree.startLine}–${visibleTree.endLine}'
                  : 'Lines ${visibleTree.startLine}–${visibleTree.endLine} · complete',
            ),
          ]),
          if (visibleTree.hasPrevious)
            button(
              type: ButtonType.button,
              classes: 'text-button',
              attributes: const {
                'aria-label': 'Show previous widget tree text page',
              },
              onClick: () {
                setState(() {
                  _treeTextStartLine =
                      (_treeTextStartLine - _treeTextPageLineCount).clamp(
                        1,
                        _treeTextStartLine,
                      );
                });
              },
              const [Component.text('Previous')],
            ),
          if (visibleTree.hasMore)
            button(
              type: ButtonType.button,
              classes: 'text-button',
              attributes: const {
                'aria-label': 'Show next widget tree text page',
              },
              onClick: () {
                setState(() {
                  _treeTextStartLine += _treeTextPageLineCount;
                });
              },
              const [Component.text('Next')],
            ),
        ]),
      ]),
      pre(classes: 'tree-output', [Component.text(visibleTree.text)]),
    ]);
  }

  Component _rawPanel(TimelineEvent event) {
    final frameData = _frameDataFor(event);
    final json = _showFullRawData
        ? jsonEncode({
            ...event.toMap(),
            'widgetTree': frameData.widgetTree,
            'structuredWidgetTree': frameData.structuredWidgetTree,
          })
        : const JsonEncoder.withIndent('  ').convert(_rawDataSummary(event));
    return div(classes: 'tree-panel', [
      div(classes: 'code-toolbar', [
        span([
          Component.text(
            _showFullRawData ? 'Full event payload' : 'Event payload summary',
          ),
        ]),
        button(
          type: ButtonType.button,
          classes: 'text-button',
          onClick: () {
            setState(() => _showFullRawData = !_showFullRawData);
          },
          [
            Component.text(
              _showFullRawData ? 'Show summary' : 'Load full compact JSON',
            ),
          ],
        ),
      ]),
      pre(classes: 'tree-output', [Component.text(json)]),
    ]);
  }

  Map<String, dynamic> _rawDataSummary(TimelineEvent event) {
    final frameData = _frameDataFor(event);
    final root = _widgetTreeRoot(event);
    return {
      ...event.toMap(),
      'widgetTree':
          '<available in Tree text · ${frameData.widgetTree.length} characters>',
      'structuredWidgetTree': {
        'available': root != null,
        'root': root?['name'],
        'captureWidth': frameData.structuredWidgetTree['captureWidth'],
        'captureHeight': frameData.structuredWidgetTree['captureHeight'],
        'hint': 'Open Inspector or load the full compact JSON payload.',
      },
    };
  }

  static List<StyleRule> get styles => [...SnackBarState.styles];
}

Set<String> collectStructuredWidgetNodeIds(
  Map<String, dynamic> root, {
  int? maxDepth,
}) {
  final ids = <String>{};

  void collect(Map<String, dynamic> node, int depth) {
    ids.add(node['id'] as String);
    if (maxDepth != null && depth >= maxDepth) {
      return;
    }
    for (final child in _structuredNodeChildren(node)) {
      collect(child, depth + 1);
    }
  }

  collect(root, 0);
  return ids;
}

({Set<String> visible, Set<String> matches}) searchStructuredWidgetTree(
  Map<String, dynamic>? root,
  String searchTerm,
) {
  final query = searchTerm.trim().toLowerCase();
  if (root == null || query.isEmpty) {
    return (visible: const {}, matches: const {});
  }

  final visible = <String>{};
  final matches = <String>{};

  bool visit(Map<String, dynamic> node) {
    final id = node['id'] as String;
    final name = node['name'] as String? ?? 'Widget';
    final matchesType = name.toLowerCase().contains(query);
    if (matchesType) {
      matches.add(id);
    }
    var descendantMatches = false;
    for (final child in _structuredNodeChildren(node)) {
      descendantMatches = visit(child) || descendantMatches;
    }
    if (matchesType || descendantMatches) {
      visible.add(id);
      return true;
    }
    return false;
  }

  visit(root);
  return (visible: visible, matches: matches);
}

String? nextStructuredWidgetSearchMatch(
  List<String> matches,
  String? current, {
  required bool reverse,
}) {
  if (matches.isEmpty) {
    return null;
  }
  final currentIndex = current == null ? -1 : matches.indexOf(current);
  if (currentIndex == -1) {
    return reverse ? matches.last : matches.first;
  }
  final delta = reverse ? -1 : 1;
  return matches[(currentIndex + delta) % matches.length];
}

List<Map<String, dynamic>> _structuredNodeChildren(Map<String, dynamic> node) {
  final children = node['children'];
  if (children is! List) {
    return const [];
  }
  return children
      .whereType<Map>()
      .map((child) => child.cast<String, dynamic>())
      .toList(growable: false);
}
