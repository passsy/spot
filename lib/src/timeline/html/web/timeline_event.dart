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
  });

  final String eventType;
  final int? color;
  final String? screenshotUrl;
  final String details;
  final String timestamp;
  final String caller;
  final String? jetBrainsLink;

  Map<String, dynamic> toMap() {
    return {
      'eventType': eventType,
      'color': color,
      'screenshotUrl': screenshotUrl,
      'details': details,
      'timestamp': timestamp,
      'caller': caller,
      'jetBrainsLink': jetBrainsLink,
    };
  }

  factory TimelineEvent.fromMap(Map<String, dynamic> map) {
    return TimelineEvent(
      eventType: map['eventType'] as String,
      color: map['color'] as int?,
      screenshotUrl: map['screenshotUrl'] as String,
      details: map['details'] as String,
      timestamp: map['timestamp'] as String,
      caller: map['caller'] as String,
      jetBrainsLink: map['jetBrainsLink'] as String?,
    );
  }
}
