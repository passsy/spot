/// The dart2js and DDC implementation of [resolveFrames].
library;

import 'package:stack_trace/stack_trace.dart';

/// Returns the frames unchanged.
///
/// Both JavaScript compilers ship source maps, so `package:stack_trace`
/// already resolves frames back to `package:` uris and line numbers.
List<Frame> resolveFrames(Iterable<Frame> frames) => frames.toList();
