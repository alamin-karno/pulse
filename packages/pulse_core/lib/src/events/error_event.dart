part of 'pulse_event.dart';

/// A [PulseEvent] representing a Dart [Error].
///
/// Dart [Error]s (e.g., `AssertionError`, `RangeError`, `StackOverflowError`)
/// indicate programming mistakes that typically should not be caught in
/// production. They are distinguished from [ExceptionEvent] to allow
/// downstream consumers to route and prioritize them differently.
///
/// Captured via [Pulse.captureError] or automatically when
/// [PulseConfig.captureUnhandledErrors] is `true`.
///
/// See also:
/// - [ExceptionEvent] — for [Exception]s and other thrown objects.
@immutable
final class ErrorEvent extends PulseEvent {
  /// The runtime type name of the error (e.g., `'AssertionError'`).
  final String errorType;

  /// A human-readable description of the error.
  final String message;

  /// The stack trace at the point the error was captured.
  ///
  /// May be `null` if a stack trace was not available at capture time.
  final StackTrace? stackTrace;

  /// Breadcrumbs recorded before this error was captured.
  ///
  /// Contains the most recent breadcrumbs up to [PulseConfig.maxBreadcrumbs].
  final List<BreadcrumbEvent> breadcrumbs;

  /// Creates an [ErrorEvent].
  const ErrorEvent({
    required super.id,
    required super.timestamp,
    required super.sdkVersion,
    required super.appVersion,
    required super.environment,
    required super.platform,
    required super.context,
    required this.errorType,
    required this.message,
    required this.breadcrumbs,
    this.stackTrace,
    super.schemaVersion,
  }) : super(type: PulseEventType.error);

  @override
  Map<String, dynamic> toJson() => {
        ...baseJson(),
        'error_type': errorType,
        'message': message,
        if (stackTrace != null) 'stack_trace': stackTrace.toString(),
        'breadcrumbs': breadcrumbs.map((b) => b.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorEvent &&
          id == other.id &&
          errorType == other.errorType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(id, errorType, message);

  @override
  String toString() =>
      'ErrorEvent(id: $id, type: $errorType, message: $message)';
}
