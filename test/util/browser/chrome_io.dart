import 'dart:io';

import 'package:puppeteer/puppeteer.dart' as pup;

import 'browser_page.dart';

/// Starts a headless Chrome, or returns null when none is installed.
///
/// Puppeteer downloads its own Chromium when it is given no executable, which
/// would turn a missing browser into a 150MB download in the middle of a test
/// run. The browser is looked up instead and a missing one skips the test.
Future<BrowserPage?> openChrome() async {
  final executable = _findChrome();
  if (executable == null) {
    if (Platform.environment['SPOT_REQUIRE_BROWSER_TESTS'] != null) {
      throw StateError(
        'No Chrome found, but SPOT_REQUIRE_BROWSER_TESTS is set. Point '
        'PUPPETEER_EXECUTABLE_PATH at a Chrome executable.',
      );
    }
    return null;
  }

  final browser = await pup.puppeteer.launch(
    executablePath: executable,
    // The report is a local file in a throwaway profile, and CI runs as root
    // in a container, where the sandbox cannot start.
    noSandboxFlag: true,
    args: ['--allow-file-access-from-files'],
  );
  return _PuppeteerPage(browser, await browser.newPage());
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

class _PuppeteerPage implements BrowserPage {
  _PuppeteerPage(this._browser, this._page) {
    _page.onConsole.listen((message) {
      if (message.type == pup.ConsoleMessageType.error) {
        _errors.add('console.error: ${message.text}');
      }
    });
    _page.onError.listen((error) {
      _errors.add('uncaught: ${error.message}');
    });
  }

  final pup.Browser _browser;
  final pup.Page _page;
  final List<String> _errors = [];

  @override
  List<String> get errors => List.unmodifiable(_errors);

  @override
  Future<void> open(String url) async {
    await _page.goto(url, wait: pup.Until.load);
  }

  @override
  Future<T> evaluate<T>(String js) => _page.evaluate<T>(js);

  @override
  Future<void> click(String selector) async {
    await _page.click(selector);
  }

  @override
  Future<void> press(String key) async {
    await _page.keyboard.press(_keys[key]!);
  }

  @override
  Future<void> close() => _browser.close();
}

const Map<String, pup.Key> _keys = {
  'Escape': pup.Key.escape,
  'ArrowLeft': pup.Key.arrowLeft,
  'ArrowRight': pup.Key.arrowRight,
};
