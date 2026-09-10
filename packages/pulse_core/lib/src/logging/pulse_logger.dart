/// Severity levels for [PulseLogger] messages.
enum PulseLogLevel {
  /// Verbose diagnostic information, only useful during active development.
  debug,

  /// General informational messages about SDK lifecycle events.
  info,

  /// Non-fatal issues that may require attention.
  warning,

  /// Errors that prevented an operation from completing.
  error,
}

/// Abstraction over SDK-internal logging.
///
/// Implementations receive diagnostic messages from the Pulse SDK pipeline —
/// initialization events, processor results, transport failures, etc.
///
/// **This logger is for SDK-internal diagnostics only.** It is not intended
/// to be used for application-level logging.
///
/// Provide a custom implementation via [PulseConfig.logger] to route SDK
/// output to your preferred logging system. The default is [NoOpLogger].
///
/// Example:
/// ```dart
/// final class ConsoleLogger implements PulseLogger {
///   @override
///   void log(PulseLogLevel level, String message, {Object? error, StackTrace? stackTrace}) {
///     print('[Pulse/${level.name.toUpperCase()}] $message');
///     if (error != null) print('  Error: $error');
///   }
/// }
/// ```
abstract interface class PulseLogger {
  /// Logs a diagnostic message at the given [level].
  ///
  /// [message] is a human-readable description of the event.
  /// [error] is an optional exception associated with this log entry.
  /// [stackTrace] is an optional stack trace, typically paired with [error].
  void log(
    PulseLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });
}
