// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:archive/archive.dart';

/// A web compatible view on the original timeline event.
///
/// This class is used to display the timeline event in the HTML file.
class TimelineEvent {
  TimelineEvent({
    required this.eventType,
    required this.color,
    required this.screenshotUrl,
    required this.overlayUrls,
    required this.details,
    required this.timestamp,
    required this.wallTimestamp,
    required this.caller,
    required this.ideLink,
    required this.ideName,
    required this.sourcePath,
    required this.callerLine,
    required this.isFailure,
    required this.widgetTree,
    required this.structuredWidgetTree,
    this.compressedFrameData,
    this.frameNumber,
    this.renderedFrameNumber,
  });

  final String eventType;
  final int? color;
  final String? screenshotUrl;
  final List<String> overlayUrls;
  final String details;

  /// When the event happened on the test's clock, which fakeAsync simulates.
  final String timestamp;

  /// When the event happened on the wall clock, unaffected by fakeAsync.
  final String wallTimestamp;

  final String caller;

  /// Opens [caller] in the IDE the test ran in, `null` when none was detected.
  final String? ideLink;

  /// The IDE [ideLink] opens, `null` alongside [ideLink].
  final String? ideName;

  /// Key into the timeline's source files, `null` when none was readable.
  final String? sourcePath;

  /// The line in [sourcePath] the event was triggered from.
  final int? callerLine;

  /// Whether this event is the test failing, which is what the report opens on.
  final bool isFailure;
  final String widgetTree;
  final Map<String, dynamic> structuredWidgetTree;
  final String? compressedFrameData;
  final int? frameNumber;

  /// How many frames the test had rendered when the event was recorded.
  ///
  /// Unlike [frameNumber], which only counts frames events happened in, this
  /// counts every frame. The distance between two events is how much rendering
  /// the test did in between without recording anything.
  final int? renderedFrameNumber;

  Map<String, dynamic> toMap() {
    return {
      'eventType': eventType,
      'color': color,
      'screenshotUrl': screenshotUrl,
      'overlayUrls': overlayUrls,
      'details': details,
      'timestamp': timestamp,
      'wallTimestamp': wallTimestamp,
      'caller': caller,
      'ideLink': ideLink,
      'ideName': ideName,
      'sourcePath': sourcePath,
      'callerLine': callerLine,
      'isFailure': isFailure,
      'widgetTree': widgetTree,
      'structuredWidgetTree': structuredWidgetTree,
      'compressedFrameData': compressedFrameData,
      'frameNumber': frameNumber,
      'renderedFrameNumber': renderedFrameNumber,
    };
  }

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      eventType: map['eventType'] as String,
      color: map['color'] as int?,
      screenshotUrl: map['screenshotUrl'] as String?,
      overlayUrls:
          (map['overlayUrls'] as List?)?.cast<String>() ?? const <String>[],
      details: map['details'] as String,
      timestamp: map['timestamp'] as String,
      wallTimestamp: map['wallTimestamp'] as String,
      caller: map['caller'] as String,
      ideLink: map['ideLink'] as String?,
      ideName: map['ideName'] as String?,
      sourcePath: map['sourcePath'] as String?,
      callerLine: map['callerLine'] as int?,
      isFailure: map['isFailure'] as bool? ?? false,
      widgetTree: map['widgetTree'] as String? ?? '',
      structuredWidgetTree:
          (map['structuredWidgetTree'] as Map?)?.cast<String, dynamic>() ??
          const {},
      compressedFrameData: map['compressedFrameData'] as String?,
      frameNumber: map['frameNumber'] as int?,
      renderedFrameNumber: map['renderedFrameNumber'] as int?,
    );
  }
}

/// One source file, stored once for all events that point into it.
class TimelineSourceFile {
  const TimelineSourceFile({
    required this.path,
    required this.lines,
    required this.truncated,
  });

  /// Project-relative where possible, the absolute path otherwise.
  final String path;

  /// Every line of the file, each one bounded in length.
  final List<String> lines;

  /// Whether the file was longer than the report stores.
  final bool truncated;

  Map<String, dynamic> toMap() {
    return {'path': path, 'lines': lines, 'truncated': truncated};
  }

  factory TimelineSourceFile.fromMap(Map<String, dynamic> map) {
    return TimelineSourceFile(
      path: map['path'] as String,
      lines: (map['lines'] as List).cast<String>(),
      truncated: map['truncated'] as bool? ?? false,
    );
  }
}

class TimelineFrameData {
  const TimelineFrameData({
    required this.widgetTree,
    required this.structuredWidgetTree,
  });

  final String widgetTree;
  final Map<String, dynamic> structuredWidgetTree;
}

String compressTimelineFrameData({
  required String widgetTree,
  required Map<String, dynamic> structuredWidgetTree,
}) {
  final json = jsonEncode({
    'widgetTree': widgetTree,
    'structuredWidgetTree': structuredWidgetTree,
  });
  return base64Encode(const GZipEncoder().encodeBytes(utf8.encode(json)));
}

TimelineFrameData decompressTimelineFrameData(String encoded) {
  final json = utf8.decode(
    const GZipDecoder().decodeBytes(base64Decode(encoded)),
  );
  final data = (jsonDecode(json) as Map).cast<String, dynamic>();
  return TimelineFrameData(
    widgetTree: data['widgetTree'] as String? ?? '',
    structuredWidgetTree:
        (data['structuredWidgetTree'] as Map?)?.cast<String, dynamic>() ??
        const {},
  );
}
