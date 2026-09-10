import '../events/pulse_event.dart';

/// Represents the outcome of an event delivery attempt.
enum PulseTransportResult {
  /// The event was successfully delivered. The queue should remove it.
  success,

  /// Delivery failed but may succeed later (e.g., network error, 503).
  /// The queue should retain the event and apply a backoff before retrying.
  retryableFailure,

  /// Delivery failed permanently (e.g., 400 Bad Request, auth failure).
  /// The queue should drop the event to avoid infinite retries.
  permanentFailure,
}

/// Defines the contract for delivering [PulseEvent]s to a destination.
///
/// Implement this interface to send events to a custom backend, file system,
/// third-party service, or any other destination.
///
/// ## Contract
///
/// - **Must not throw.** Internal errors must be handled within the
///   implementation. Returns a [PulseTransportResult] to signal the outcome.
/// - **Must be idempotent on [close].** Calling [close] multiple times must
///   be safe.
/// - **May be called concurrently.** Implementations should be safe for
///   concurrent invocations of [send].
///
/// ## Example
///
/// ```dart
/// final class MyHttpTransport implements PulseTransport {
///   final Uri _endpoint;
///   MyHttpTransport(this._endpoint);
///
///   @override
///   Future<PulseTransportResult> send(PulseEvent event) async {
///     try {
///       // Send event.toJson() to _endpoint
///       return PulseTransportResult.success;
///     } catch (e) {
///       // Handle error internally
///       return PulseTransportResult.retryableFailure;
///     }
///   }
///
///   @override
///   Future<void> close() async {
///     // Flush pending events, close HTTP client
///   }
/// }
/// ```
///
/// See also:
/// - [NoOpTransport] — a no-operation transport suitable for development
///   and testing.
abstract interface class PulseTransport {
  /// Sends a single [event] to the configured destination.
  ///
  /// This method is called by the queue after all processors and
  /// sanitization have completed. Implementations must not throw.
  ///
  /// Returns a [PulseTransportResult] so the caller knows whether to retry.
  Future<PulseTransportResult> send(PulseEvent event);

  /// Flushes any buffered events and releases resources.
  ///
  /// Called during SDK shutdown via [Pulse.close]. Must be idempotent —
  /// safe to call multiple times.
  Future<void> close();
}
