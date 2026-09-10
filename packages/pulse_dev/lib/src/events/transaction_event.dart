part of 'pulse_event.dart';

/// Represents a single performance measurement span.
///
/// Spans are nested within a transaction to measure specific operations.
@immutable
class PulseSpan {
  /// The name of the operation being measured (e.g., 'db.query', 'ui.render').
  final String name;

  /// The start time of the span.
  final DateTime startTime;

  /// The end time of the span, if finished.
  final DateTime? endTime;

  /// The duration of the span, if finished.
  final Duration? duration;

  /// The status of the span (e.g., 'ok', 'error', 'cancelled').
  final String status;

  /// Creates a [PulseSpan].
  const PulseSpan({
    required this.name,
    required this.startTime,
    this.endTime,
    this.duration,
    this.status = 'ok',
  });

  /// Serializes the span to JSON.
  Map<String, dynamic> toJson() => {
        'name': name,
        'start_timestamp': startTime.toIso8601String(),
        if (endTime != null) 'end_timestamp': endTime!.toIso8601String(),
        if (duration != null) 'duration_ms': duration!.inMilliseconds,
        'status': status,
      };
}

/// Represents a complete transaction consisting of multiple spans.
///
/// A transaction is a top-level performance event (e.g., a screen load).
@immutable
class TransactionEvent extends PulseEvent {
  /// The name of the transaction (e.g., 'load_dashboard').
  final String name;

  /// The overall duration of the transaction.
  final Duration duration;

  /// The status of the transaction (e.g., 'ok', 'error', 'cancelled').
  final String status;

  /// A list of spans that occurred within this transaction.
  final List<PulseSpan> spans;

  /// Creates a [TransactionEvent].
  const TransactionEvent({
    required super.id,
    required super.timestamp,
    required super.sdkVersion,
    required super.appVersion,
    required super.environment,
    required super.platform,
    required super.context,
    required this.name,
    required this.duration,
    super.schemaVersion,
    this.status = 'ok',
    this.spans = const [],
  }) : super(type: PulseEventType.transaction);

  @override
  Map<String, dynamic> toJson() {
    final json = baseJson();
    json.addAll({
      'transaction': name,
      'duration_ms': duration.inMilliseconds,
      'status': status,
      'spans': spans.map((s) => s.toJson()).toList(growable: false),
    });
    return json;
  }
}
