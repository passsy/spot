import 'package:stack_trace/stack_trace.dart';
import 'package:universal_io/io.dart';

/// A screenshot taken from a widget test.
///
/// May also be just a single widget, not the entire screen
class Screenshot {
  /// Creates a [Screenshot] that points to a file on disk.
  Screenshot({
    this.file,
    this.initiator,
  });

  /// The file where the screenshot was saved to
  final File? file;

  /// Call stack of the code that initiated the screenshot
  final Frame? initiator;
}
