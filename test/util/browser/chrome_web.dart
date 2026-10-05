import 'browser_page.dart';

/// Always null: a browser cannot start another browser.
///
/// Suites compiled for the web skip the browser tests instead of failing to
/// compile, which is what the conditional import in `chrome.dart` is for.
Future<BrowserPage?> openChrome() async => null;
