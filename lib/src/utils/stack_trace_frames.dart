/// Makes the frames of a stack trace comparable across compilers.
///
/// Each compiler reports frames differently, so the implementation is picked
/// at compile time. dart2wasm has neither `dart:io` nor `dart:html`, which is
/// what separates it from the JavaScript compilers here.
library;

export 'package:spot/src/utils/stack_trace_frames_wasm.dart'
    if (dart.library.io) 'package:spot/src/utils/stack_trace_frames_vm.dart'
    if (dart.library.html) 'package:spot/src/utils/stack_trace_frames_js.dart';
