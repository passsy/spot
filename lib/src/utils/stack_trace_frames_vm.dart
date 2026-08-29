/// The Dart VM implementation of [resolveFrames].
library;

import 'package:stack_trace/stack_trace.dart';

/// Returns the frames unchanged.
///
/// The VM reports the uri, line and column of every frame directly.
List<Frame> resolveFrames(Iterable<Frame> frames) => frames.toList();
