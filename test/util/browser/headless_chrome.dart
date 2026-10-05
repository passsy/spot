import 'dart:io';

import 'package:puppeteer/puppeteer.dart' as pup;
import 'package:test/test.dart';

/// Drives the generated timeline report in a real browser from the outside.
///
/// The components themselves are tested from inside the browser in
/// `test/timeline/timeline_app_browser_test.dart`, where the DOM is typed.
/// What only this can do is load the file spot writes — the pre-compiled
/// bundle, inlined into a self-contained document opened over `file:` — and
/// click it with a real user gesture.
class HeadlessChrome {
  HeadlessChrome._(this._browser, this._page) {
    _page.onConsole.listen((message) {
      if (message.type == pup.ConsoleMessageType.error) {
        _errors.add('console.error: ${message.text}');
      }
    });
    _page.onError.listen((error) => _errors.add('uncaught: ${error.message}'));
  }

  /// Starts a headless Chrome, or returns null when none is installed.
  ///
  /// Puppeteer downloads its own Chromium when it is given no executable,
  /// which would turn a missing browser into a 150MB download in the middle of
  /// a test run. The browser is looked up instead, and a missing one skips the
  /// test — unless `SPOT_REQUIRE_BROWSER_TESTS` is set, which is how the CI
  /// job that exists to run these tests keeps itself from passing by skipping.
  static Future<HeadlessChrome?> launch() async {
    final executable = _findChrome();
    if (executable == null) {
      if (Platform.environment['SPOT_REQUIRE_BROWSER_TESTS'] != null) {
        throw StateError(
          'No Chrome found, but SPOT_REQUIRE_BROWSER_TESTS is set. Point '
          'PUPPETEER_EXECUTABLE_PATH at a Chrome executable.',
        );
      }
      markTestSkipped('No Chrome available to drive');
      return null;
    }

    final browser = await pup.puppeteer.launch(
      executablePath: executable,
      // The report is a local file in a throwaway profile, and CI runs as root
      // in a container, where the sandbox cannot start.
      noSandboxFlag: true,
      args: ['--allow-file-access-from-files'],
    );
    addTearDown(browser.close);
    return HeadlessChrome._(browser, await browser.newPage());
  }

  final pup.Browser _browser;
  final pup.Page _page;
  final List<String> _errors = [];

  /// Everything the page logged at error level, plus uncaught exceptions.
  ///
  /// A hydration failure shows up here and nowhere else: the server-rendered
  /// markup stays on screen, so every assertion about content still passes.
  List<String> get errors => List.unmodifiable(_errors);

  /// Loads [url] and waits for the load event.
  ///
  /// The report's client app waits for that same event before it hydrates, so
  /// nothing is interactive before it fires.
  Future<void> open(String url) async {
    await _page.goto(url, wait: pup.Until.load);
  }

  /// Evaluates a JavaScript expression in the page and returns its value.
  Future<T> evaluate<T>(String expression) => _page.evaluate<T>(expression);

  /// Clicks the first element matching [selector], as a user gesture.
  Future<void> click(String selector) => _page.click(selector);

  /// Waits until the JavaScript [condition] evaluates to true.
  Future<void> waitUntil(
    String condition, {
    required String description,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (await evaluate<bool>(condition)) return;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    throw StateError('Timed out waiting until $description.\n$condition');
  }

  Future<void> close() => _browser.close();
}

/// The Chrome to drive, or null when there is none.
///
/// `PUPPETEER_EXECUTABLE_PATH` wins, which is how CI points at the browser it
/// installed. Otherwise Chrome is looked for where it is installed by default
/// and then on the PATH, which covers the Linux packages that put it there
/// under a name of their own.
String? _findChrome() {
  for (final variable in const [
    'PUPPETEER_EXECUTABLE_PATH',
    'CHROME_EXECUTABLE',
  ]) {
    final configured = Platform.environment[variable];
    if (configured != null && File(configured).existsSync()) {
      return configured;
    }
  }

  try {
    return pup.BrowserPath.chrome;
  } catch (_) {
    // Not installed in the default location, which throws.
  }

  const names = [
    'google-chrome',
    'google-chrome-stable',
    'chromium',
    'chromium-browser',
    'chrome',
  ];
  final lookup = Platform.isWindows ? 'where' : 'which';
  for (final name in names) {
    final result = Process.runSync(lookup, [name]);
    if (result.exitCode != 0) continue;
    final path = result.stdout.toString().split('\n').first.trim();
    if (path.isNotEmpty && File(path).existsSync()) {
      return path;
    }
  }
  return null;
}
