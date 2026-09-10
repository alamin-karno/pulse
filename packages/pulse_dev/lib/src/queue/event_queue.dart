import 'dart:async';
import 'dart:math';

import '../events/pulse_event.dart';
import '../logging/pulse_logger.dart';
import '../storage/pulse_storage.dart';
import '../transport/pulse_transport.dart';
import '../utils/clock.dart';

/// Manages offline queuing, persistence, and delivery of events.
///
/// Ensures events are saved locally and dispatched to the transport when
/// available. Applies exponential backoff on retryable transport failures.
final class EventQueue {
  final PulseStorage _storage;
  final PulseTransport _transport;
  final PulseLogger _logger;
  final Clock _clock;
  final int _maxQueueSize;

  bool _isFlushing = false;
  bool _isClosed = false;

  int _consecutiveFailures = 0;
  DateTime? _nextFlushAllowed;

  /// Creates an [EventQueue].
  EventQueue({
    required PulseStorage storage,
    required PulseTransport transport,
    required PulseLogger logger,
    required Clock clock,
    int maxQueueSize = 100,
  })  : _storage = storage,
        _transport = transport,
        _logger = logger,
        _clock = clock,
        _maxQueueSize = maxQueueSize;

  /// Adds [event] to storage and attempts to flush the queue.
  Future<void> enqueue(PulseEvent event) async {
    if (_isClosed) return;

    try {
      await _storage.store(event);

      // Enforce max queue size
      final allEvents = await _storage.retrieveAll();
      if (allEvents.length > _maxQueueSize) {
        // Drop the oldest event (FIFO)
        final excess = allEvents.length - _maxQueueSize;
        for (var i = 0; i < excess; i++) {
          await _storage.delete(allEvents[i].id);
        }
        _logger.log(
          PulseLogLevel.warning,
          'Queue capacity exceeded. Dropped $excess oldest events.',
        );
      }
    } catch (e, st) {
      _logger.log(
        PulseLogLevel.error,
        'Failed to store event in queue.',
        error: e,
        stackTrace: st,
      );
      return; // If we can't store, we just lose the event.
    }

    _triggerFlush();
  }

  void _triggerFlush() {
    if (_isFlushing || _isClosed) return;

    // Check if we are currently backing off
    if (_nextFlushAllowed != null &&
        _clock.now().isBefore(_nextFlushAllowed!)) {
      return;
    }

    // Process asynchronously without blocking the caller
    unawaited(_flush());
  }

  Future<void> _flush({bool isClosing = false}) async {
    _isFlushing = true;
    try {
      final events = await _storage.retrieveAll();
      if (events.isEmpty) {
        return;
      }

      for (final event in events) {
        if (_isClosed && !isClosing) break;

        PulseTransportResult result;
        try {
          result = await _transport.send(event);
        } catch (e, st) {
          // Transport violated contract and threw
          _logger.log(
            PulseLogLevel.error,
            'Transport threw an exception. Treating as retryable failure.',
            error: e,
            stackTrace: st,
          );
          result = PulseTransportResult.retryableFailure;
        }

        if (result == PulseTransportResult.success) {
          await _storage.delete(event.id);
          _consecutiveFailures = 0;
          _nextFlushAllowed = null;
        } else if (result == PulseTransportResult.permanentFailure) {
          _logger.log(
            PulseLogLevel.warning,
            'Permanent transport failure for event ${event.id}. Dropping.',
          );
          await _storage.delete(event.id);
        } else if (result == PulseTransportResult.retryableFailure) {
          _consecutiveFailures++;
          _applyBackoff();
          // Stop flushing this batch and wait for backoff
          break;
        }
      }
    } catch (e, st) {
      _logger.log(
        PulseLogLevel.error,
        'Internal queue flush error.',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isFlushing = false;
    }
  }

  void _applyBackoff() {
    // Base delay: 1 second. Max delay: 60 seconds.
    final delaySeconds = min(60, pow(2, _consecutiveFailures - 1)).toInt();
    _nextFlushAllowed = _clock.now().add(Duration(seconds: delaySeconds));
    _logger.log(
      PulseLogLevel.debug,
      'Transport retryable failure. Backing off for $delaySeconds seconds.',
    );
  }

  /// Flushes pending events and closes the underlying transport.
  Future<void> close() async {
    _isClosed = true;

    // Attempt one last flush if not currently backing off
    if (_nextFlushAllowed == null || _clock.now().isAfter(_nextFlushAllowed!)) {
      await _flush(isClosing: true);
    }

    await _transport.close();
  }
}
