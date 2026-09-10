import 'dart:convert';
import 'dart:math';

import '../config/pulse_config.dart';
import '../events/pulse_event.dart';
import '../logging/pulse_logger.dart';
import '../queue/event_queue.dart';
import '../sanitization/default_sanitizer.dart';
import '../sanitization/pulse_sanitizer.dart';
import '../storage/in_memory_pulse_storage.dart';
import '../transport/pulse_transport.dart';
import '../utils/clock.dart';
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
/// 3. **Queue** — The sanitized event is added to the offline [EventQueue],
///    which persists it to storage.
/// 4. **Transport** — The queue flushes to [PulseTransport], managing
///    retries and backoff.
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
  final EventQueue _queue;
  final PulseLogger _logger;

  /// Creates an [EventPipeline] with explicit dependencies.
  ///
  /// Prefer [EventPipeline.fromConfig] for typical usage.
  EventPipeline({
    required List<EventProcessor> processors,
    required PulseSanitizer sanitizer,
    required EventQueue queue,
    required PulseLogger logger,
    double sampleRate = 1.0,
    int maxPayloadSizeBytes = 1048576, // 1MB default
  })  : _processors = List.unmodifiable(processors),
        _sanitizer = sanitizer,
        _queue = queue,
        _logger = logger,
        _sampleRate = sampleRate,
        _maxPayloadSizeBytes = maxPayloadSizeBytes;

  final double _sampleRate;
  final int _maxPayloadSizeBytes;

  /// Creates an [EventPipeline] from a [PulseConfig].
  factory EventPipeline.fromConfig(PulseConfig config) {
    final storage = config.storage ?? InMemoryPulseStorage();
    final queue = EventQueue(
      storage: storage,
      transport: config.transport,
      logger: config.logger,
      clock: const SystemClock(),
      maxQueueSize: config.maxQueueSize,
    );

    return EventPipeline(
      processors: config.processors,
      sanitizer:
          config.sanitizer ?? DefaultSanitizer(config: config.sanitization),
      queue: queue,
      logger: config.logger,
      sampleRate: config.sampleRate,
      maxPayloadSizeBytes: config.sanitization.maxPayloadSizeBytes,
    );
  }

  /// Processes [event] through the full pipeline.
  ///
  /// This method never throws. Failures at each stage are caught, logged,
  /// and handled according to the stage's error policy.
  Future<void> process(PulseEvent event) async {
    // ── Stage 0: Sampling ──────────────────────────────────────────────────
    if (_sampleRate < 1.0) {
      if (_sampleRate <= 0.0 || Random().nextDouble() >= _sampleRate) {
        _logger.log(
          PulseLogLevel.debug,
          'Event dropped by sampling (rate: $_sampleRate)',
        );
        return;
      }
    }

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

    // ── Stage 2.5: Payload Size Check ──────────────────────────────────────
    try {
      final jsonBytes = utf8.encode(jsonEncode(sanitized.toJson()));
      if (jsonBytes.length > _maxPayloadSizeBytes) {
        _logger.log(
          PulseLogLevel.warning,
          'Event dropped — payload size (${jsonBytes.length} bytes) exceeds '
          'limit ($_maxPayloadSizeBytes bytes).',
        );
        return; // Drop oversized payload
      }
    } catch (error, stackTrace) {
      _logger.log(
        PulseLogLevel.error,
        'Failed to verify payload size — dropping event.',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    // ── Stage 3: Queue & Transport ─────────────────────────────────────────
    await _queue.enqueue(sanitized);
  }

  /// Closes the pipeline by flushing the transport.
  ///
  /// Call this during SDK shutdown via [Pulse.close].
  Future<void> close() async {
    await _queue.close();
  }
}
