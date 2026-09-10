import '../config/pulse_config.dart';
import '../events/pulse_event.dart';
import '../logging/pulse_logger.dart';
import '../sanitization/pulse_sanitizer.dart';
import '../transport/pulse_transport.dart';
import 'event_processor.dart';

/// Orchestrates the Pulse event pipeline.
///
/// Every [PulseEvent] flows through three mandatory stages:
///
/// ```
/// Capture → [Processors] → Sanitizer → Transport
/// ```
///
/// 1. **Processors** — Applied in order. Any processor may drop the event by
///    returning `null`. A processor that throws is logged and skipped; the
///    pre-processor event continues.
/// 2. **Sanitizer** — Mandatory privacy gate. If the sanitizer throws, the
///    event is **dropped** and not transported to prevent sending unsanitized
///    data.
/// 3. **Transport** — The sanitized event is delivered via [PulseTransport].
///    If the transport throws, the error is logged and the event is silently
///    dropped.
///
/// ## Error isolation
///
/// The pipeline never propagates exceptions to the caller. All internal
/// failures are caught and logged via [PulseLogger].
///
/// ## Creating a pipeline
///
/// Use [EventPipeline.fromConfig] to create a pipeline from a [PulseConfig]:
///
/// ```dart
/// final pipeline = EventPipeline.fromConfig(config);
/// await pipeline.process(event);
/// ```
final class EventPipeline {
  final List<EventProcessor> _processors;
  final PulseSanitizer _sanitizer;
  final PulseTransport _transport;
  final PulseLogger _logger;

  /// Creates an [EventPipeline] with explicit dependencies.
  ///
  /// Prefer [EventPipeline.fromConfig] for typical usage.
  EventPipeline({
    required List<EventProcessor> processors,
    required PulseSanitizer sanitizer,
    required PulseTransport transport,
    required PulseLogger logger,
  })  : _processors = List.unmodifiable(processors),
        _sanitizer = sanitizer,
        _transport = transport,
        _logger = logger;

  /// Creates an [EventPipeline] from a [PulseConfig].
  factory EventPipeline.fromConfig(PulseConfig config) => EventPipeline(
        processors: config.processors,
        sanitizer: config.sanitizer,
        transport: config.transport,
        logger: config.logger,
      );

  /// Processes [event] through the full pipeline.
  ///
  /// This method never throws. Failures at each stage are caught, logged,
  /// and handled according to the stage's error policy.
  Future<void> process(PulseEvent event) async {
    var current = event;

    // ── Stage 1: Processors ───────────────────────────────────────────────
    for (final processor in _processors) {
      try {
        final result = processor.process(current);
        if (result == null) {
          _logger.log(
            PulseLogLevel.debug,
            'Event dropped by processor: ${processor.runtimeType}',
          );
          return;
        }
        current = result;
      } catch (error, stackTrace) {
        _logger.log(
          PulseLogLevel.warning,
          'Processor ${processor.runtimeType} threw — '
          'continuing with pre-processor event.',
          error: error,
          stackTrace: stackTrace,
        );
        // Continue with the event as it was before this processor ran.
        current = event;
      }
    }

    // ── Stage 2: Sanitizer (mandatory) ───────────────────────────────────
    PulseEvent sanitized;
    try {
      sanitized = _sanitizer.sanitize(current);
    } catch (error, stackTrace) {
      _logger.log(
        PulseLogLevel.error,
        'Sanitizer threw — dropping event to prevent sending '
        'unsanitized data.',
        error: error,
        stackTrace: stackTrace,
      );
      return; // Privacy-safe: drop rather than send unsanitized.
    }

    // ── Stage 3: Transport ────────────────────────────────────────────────
    try {
      await _transport.send(sanitized);
    } catch (error, stackTrace) {
      _logger.log(
        PulseLogLevel.error,
        'Transport failed to send event ${sanitized.id}.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Closes the pipeline by flushing the transport.
  ///
  /// Call this during SDK shutdown via [Pulse.close].
  Future<void> close() async {
    try {
      await _transport.close();
    } catch (error, stackTrace) {
      _logger.log(
        PulseLogLevel.warning,
        'Transport close failed.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
