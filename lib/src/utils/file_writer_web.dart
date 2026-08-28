/// Writes [content] to [path], creating parent directories as needed.
///
/// Deletes the file at [path] when [content] is null.
///
/// A browser has no file system to write to.
void writeStringToFile(String path, String? content) {
  throw UnsupportedError('Writing files is not supported on the web');
}
