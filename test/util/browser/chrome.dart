import 'browser_page.dart';
import 'chrome_web.dart' if (dart.library.io) 'chrome_io.dart' as impl;

export 'browser_page.dart';

/// Starts a headless Chrome and returns a page to drive.
///
/// Null when this machine has no Chrome to drive, or when the test suite
/// itself runs in a browser. Tests skip in that case, unless
/// `SPOT_REQUIRE_BROWSER_TESTS` is set — CI sets it so a job that is supposed
/// to run them cannot pass by silently skipping everything.
Future<BrowserPage?> openChrome() => impl.openChrome();
