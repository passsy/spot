import 'package:flutter/foundation.dart';

/// dart2wasm does not support `--track-widget-creation`, so a widget's
/// creation location is null there and every assertion naming one fails.
///
/// `testWidgets` only accepts a bool for `skip`, so the reason lives here
/// rather than in a skip message.
const bool noWidgetLocationsOnWasm = kIsWasm;

/// A tap that throws under `LiveTestWidgetsFlutterBinding` leaks the error past
/// the test that raised it on dart2wasm, and the runner then reports it against
/// whichever test completed before.
///
/// The same bodies run against `AutomatedTestWidgetsFlutterBinding`, which does
/// not have the problem, so the coverage is not lost.
const String liveBindingLeaksOnWasm =
    'a throwing tap leaks past its own test on dart2wasm';
