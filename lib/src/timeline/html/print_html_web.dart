import 'package:spot/src/timeline/timeline.dart';

/// Writes the timeline as an HTML file
extension HtmlTimelinePrinter on Timeline {
  /// Prints the timeline as an HTML file.
  ///
  /// The report is written next to the test on disk, which a browser cannot
  /// do. The console timeline is still printed on the web.
  Future<void> printHTML() async {
    // ignore: avoid_print
    print('The HTML timeline report is not supported on the web.');
  }
}
