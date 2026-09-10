import 'package:meta/meta.dart';

import 'pulse_logger.dart';

/// A [PulseLogger] that silently discards all messages.
///
/// This is the default logger when no custom logger is provided via
/// [PulseConfig.logger]. It has zero runtime cost.
///
/// To see SDK diagnostic output during development, provide a logger that
/// writes to the console:
///
/// ```dart
/// final class ConsoleLogger implements PulseLogger {
///   @override
///   void log(PulseLogLevel level, String message,
///       {Object? error, StackTrace? stackTrace}) {
///     debugPrint('[Pulse] [${ level.name}] $message');
///   }
/// }
/// ```
@immutable
final class NoOpLogger implements PulseLogger {
  /// Creates a [NoOpLogger].
  const NoOpLogger();

  @override
  void log(
    PulseLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Intentionally discards all messages.
  }
}
