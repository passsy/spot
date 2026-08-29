/// Makes the frames of a stack trace comparable across compilers.
///
/// Each compiler reports frames differently, so the implementation is picked
/// at compile time. dart2wasm has neither `dart:io` nor `dart:html`, which is
/// what separates it from the JavaScript compilers here.
library;

import 'package:stack_trace/stack_trace.dart';

export 'package:spot/src/utils/stack_trace_frames_wasm.dart'
    if (dart.library.io) 'package:spot/src/utils/stack_trace_frames_vm.dart'
    if (dart.library.html) 'package:spot/src/utils/stack_trace_frames_js.dart';

/// Whether [frame] points into the Dart SDK rather than at code someone wrote.
///
/// The compilers disagree on how to say it: the VM and dart2wasm use a `dart:`
/// uri, while dart2js and DDC serve the sources over http and leave a
/// `/dart-sdk/` path behind.
bool isSdkFrame(Frame frame) =>
    frame.isCore || frame.uri.path.contains('/dart-sdk/');
