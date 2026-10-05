/// A page in a real browser, driven from a test.
///
/// The timeline report is the one part of spot that only exists as HTML and
/// JavaScript, so asserting on the markup a test renders says nothing about
/// whether the report works. These tests load the real file in Chrome.
abstract interface class BrowserPage {
  /// Loads [url] and waits for the load event.
  ///
  /// The report's client app waits for that same event before it hydrates the
  /// server-rendered markup, so nothing is interactive before it fires.
  Future<void> open(String url);

  /// Evaluates [js] in the page and returns its value.
  ///
  /// [js] is either a JavaScript expression or an arrow function.
  Future<T> evaluate<T>(String js);

  /// Clicks the first element matching [selector].
  Future<void> click(String selector);

  /// Presses a key by its `KeyboardEvent.key` name, e.g. `Escape`.
  Future<void> press(String key);

  /// Everything the page logged at error level, plus uncaught exceptions.
  ///
  /// A hydration failure shows up here and nowhere else: the server-rendered
  /// markup stays on screen, so every assertion about content still passes.
  List<String> get errors;

  /// Closes the browser.
  Future<void> close();
}

/// Polling for a page that is still catching up with the test.
extension BrowserPageWait on BrowserPage {
  /// Waits until the JavaScript [condition] evaluates to true.
  ///
  /// Hydration and rendering happen in their own microtasks, so there is
  /// always a moment where the page is loaded but not yet interactive.
  Future<void> waitUntil(
    String condition, {
    required String description,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (await evaluate<bool>(condition)) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    throw StateError('Timed out waiting until $description.\n$condition');
  }
}
