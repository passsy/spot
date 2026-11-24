import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../tool/render_html.dart';

void main() {
  test('keeps screenshot paths relative to their timeline directory', () {
    final timelineDir = path.join('build', 'timeline', 'example');

    expect(
      relativeScreenshotPath(
        timelineDirPath: timelineDir,
        screenshotPath: path.join('.', 'screenshots', 'event.png'),
      ),
      path.join('screenshots', 'event.png'),
    );
  });
}
