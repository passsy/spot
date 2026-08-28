/// Writing the timeline report to an HTML file.
///
/// The report is a directory of files next to the test, which a browser cannot
/// write, so the web implementation only prints a note.
library;

export 'package:spot/src/timeline/html/print_html_web.dart'
    if (dart.library.io) 'package:spot/src/timeline/html/print_html_io.dart';
