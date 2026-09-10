part of 'pulse_event.dart';

/// A [PulseEvent] representing a caught or uncaught [Exception] or thrown
/// [Object].
///
/// In Dart, [Exception]s represent expected failure modes that applications
/// may catch and handle. They are distinguished from [ErrorEvent] (which
/// represents programming mistakes) to allow different routing and
/// prioritization downstream.
///
/// This event type also handles arbitrary thrown objects that are neither
/// [Error] nor [Exception] — any `throw` expression is captured as an
/// [ExceptionEvent].
///
/// Captured via [Pulse.captureException] or automatically when
/// [PulseConfig.captureUnhandledErrors] or [PulseConfig.captureFlutterErrors]
/// is `true`.
///
/// See also:
/// - [ErrorEvent] — for Dart [Error]s.
@immutable
final class ExceptionEvent extends PulseEvent {
  /// The runtime type name of the exception (e.g., `'FormatException'`).
  final String exceptionType;

  /// A human-readable description of the exception.
  final String message;

  /// The stack trace at the point the exception was captured.
  ///
  /// May be `null` if a stack trace was not available.
  final StackTrace? stackTrace;

  /// Breadcrumbs recorded before this exception was captured.
  ///
  /// Contains the most recent breadcrumbs up to [PulseConfig.maxBreadcrumbs].
  final List<BreadcrumbEvent> breadcrumbs;

  /// Whether this exception was explicitly caught by application code.
  ///
  /// `true` if captured via [Pulse.captureException] (handled).
  /// `false` if captured via an unhandled error integration.
  final bool handled;

  /// Creates an [ExceptionEvent].
  const ExceptionEvent({
    required super.id,
    required super.timestamp,
    required super.sdkVersion,
    required super.appVersion,
    required super.environment,
    required super.platform,
    required super.context,
    required this.exceptionType,
    required this.message,
    required this.breadcrumbs,
    required this.handled,
    this.stackTrace,
    super.schemaVersion,
  }) : super(type: PulseEventType.exception);

  @override
  Map<String, dynamic> toJson() => {
        ...baseJson(),
        'exception_type': exceptionType,
        'message': message,
        'handled': handled,
        if (stackTrace != null) 'stack_trace': stackTrace.toString(),
        'breadcrumbs': breadcrumbs.map((b) => b.toJson()).toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExceptionEvent &&
          id == other.id &&
          exceptionType == other.exceptionType &&
          message == other.message;

  @override
  int get hashCode => Object.hash(id, exceptionType, message);

  @override
  String toString() =>
      'ExceptionEvent(id: $id, type: $exceptionType, handled: $handled)';
}
