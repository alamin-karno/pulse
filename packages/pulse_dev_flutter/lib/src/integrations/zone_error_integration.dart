import 'dart:async';

import 'package:pulse_dev/pulse_dev.dart' show ExceptionEvent;

import '../../pulse_dev_flutter.dart' show ExceptionEvent;
import '../pulse_client.dart';
import 'flutter_error_integration.dart' show FlutterErrorIntegration;

/// Provides a [runZonedGuarded]-based wrapper for capturing unhandled errors.
///
/// Use [ZoneErrorIntegration.run] to wrap your application's entry point.
/// Any error that propagates to the zone boundary is captured as an
/// [ExceptionEvent] with `handled: false`.
///
/// This is equivalent to — and works alongside — [FlutterErrorIntegration].
/// Both integrations can be active simultaneously.
///
/// ## Usage
///
/// ```dart
/// void main() async {
///   await Pulse.initialize(...);
///   Pulse.run(() => runApp(const MyApp()));
/// }
/// ```
abstract final class ZoneErrorIntegration {
  /// Runs [body] inside a `runZonedGuarded` zone that captures unhandled errors.
  ///
  /// Any uncaught [Object] that escapes [body] is forwarded to [client] as
  /// an unhandled exception. [client] may be `null` if the SDK is not yet
  /// initialized — in that case errors are silently dropped.
  static void run(void Function() body, PulseClient? client) {
    runZonedGuarded(
      body,
      (error, stackTrace) {
        client?.captureException(
          error,
          stackTrace: stackTrace,
          handled: false,
        );
      },
    );
  }
}
