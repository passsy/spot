import 'package:spot/spot.dart';

const String timelineHeader =
    '==================== Timeline Event ====================';

const String timelineSeparator =
    '========================================================';

String localTimelineInitiator(TimelineMode timelineMode) {
  return switch (timelineMode) {
    TimelineMode.live => 'localTimelineMode = TimelineMode.live;',
    TimelineMode.record => 'localTimelineMode = TimelineMode.record;',
    TimelineMode.off => 'localTimelineMode = TimelineMode.off;',
  };
}

String globalTimelineInitiator(TimelineMode timelineMode) {
  return switch (timelineMode) {
    TimelineMode.live => 'globalTimelineMode = TimelineMode.live;',
    TimelineMode.record => 'globalTimelineMode = TimelineMode.record;',
    TimelineMode.off => 'globalTimelineMode = TimelineMode.off;',
  };
}
