import 'package:spot/spot.dart';

const String timelineHeader =
    '==================== Timeline Event ====================';

const String timelineSeparator =
    '========================================================';

String localTimelineInitiator(TimelineMode timelineMode) {
  return switch (timelineMode) {
    TimelineMode.live =>
      'timeline.mode = TimelineMode.live;\nexpect(timeline.mode, TimelineMode.live);',
    TimelineMode.always =>
      'timeline.mode = TimelineMode.always;\nexpect(timeline.mode, TimelineMode.always);',
    // ignore: deprecated_member_use_from_same_package
    TimelineMode.record =>
      'timeline.mode = TimelineMode.record;\nexpect(timeline.mode, TimelineMode.record);',
    TimelineMode.reportOnError =>
      'timeline.mode = TimelineMode.reportOnError;\nexpect(timeline.mode, TimelineMode.reportOnError);',
    TimelineMode.off =>
      'timeline.mode = TimelineMode.off;\nexpect(timeline.mode, TimelineMode.off);',
  };
}

String globalTimelineInitiator(TimelineMode timelineMode) {
  return switch (timelineMode) {
    TimelineMode.live => 'globalTimelineMode = TimelineMode.live;',
    TimelineMode.always => 'globalTimelineMode = TimelineMode.always;',
    TimelineMode.reportOnError =>
      'globalTimelineMode = TimelineMode.reportOnError;',
    // ignore: deprecated_member_use_from_same_package
    TimelineMode.record => 'globalTimelineMode = TimelineMode.record;',
    TimelineMode.off => 'globalTimelineMode = TimelineMode.off;',
  };
}
