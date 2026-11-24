# Contributing to spot

Welcome to spot!
We're thrilled that you'd like to contribute to this project.
Here are a few guidelines and tips to get you involved.

## Development of the Jaspr HTML timeline

To preview an already generated static timeline in a browser that cannot open `file://` URLs, serve only that report on an available loopback port:

```bash
dart run tool/serve_timeline.dart build/timeline/<report-directory>
```

The command prints the temporary `http://127.0.0.1:<port>/` URL.
The report remains a self-contained static artifact, and the preview server stops when you press Ctrl+C.

When building the timeline, you can use the `tool/hot_restart_timeline.dart` script to hot-restart the timeline.
It automatically reloads the HTML when you change any part of the Jaspr code or run the test again.

```bash
dart run hot_restart_timeline/bin/main.dart
```
