// Conditionally exports the `dart:io`-backed OS version resolver on
// platforms that support it, falling back to a no-op stub on Flutter Web.
//
// This indirection exists so that `flutter_context_collector.dart` never
// imports `dart:io` directly, keeping it (and this package) Flutter Web
// compatible.
export 'os_version_stub.dart' if (dart.library.io) 'os_version_io.dart';
