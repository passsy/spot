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
    required this.details,
    required this.timestamp,
    required this.caller,
    required this.jetBrainsLink,
    required this.widgetTree,
    required this.structuredWidgetTree,
    this.compressedFrameData,
    this.frameNumber,
  });

  final String eventType;
  final int? color;
  final String? screenshotUrl;
  final String details;
  final String timestamp;
  final String caller;
  final String? jetBrainsLink;
  final String widgetTree;
  final Map<String, dynamic> structuredWidgetTree;
  final String? compressedFrameData;
  final int? frameNumber;

  Map<String, dynamic> toMap() {
    return {
      'eventType': eventType,
      'color': color,
      'screenshotUrl': screenshotUrl,
      'details': details,
      'timestamp': timestamp,
      'caller': caller,
      'jetBrainsLink': jetBrainsLink,
      'widgetTree': widgetTree,
      'structuredWidgetTree': structuredWidgetTree,
      'compressedFrameData': compressedFrameData,
      'frameNumber': frameNumber,
    };
  }

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      eventType: map['eventType'] as String,
      color: map['color'] as int?,
      screenshotUrl: map['screenshotUrl'] as String?,
      details: map['details'] as String,
      timestamp: map['timestamp'] as String,
      caller: map['caller'] as String,
      jetBrainsLink: map['jetBrainsLink'] as String?,
      widgetTree: map['widgetTree'] as String? ?? '',
      structuredWidgetTree:
          (map['structuredWidgetTree'] as Map?)?.cast<String, dynamic>() ??
          const {},
      compressedFrameData: map['compressedFrameData'] as String?,
      frameNumber: map['frameNumber'] as int?,
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
