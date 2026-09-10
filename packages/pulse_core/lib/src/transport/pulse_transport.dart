import '../events/pulse_event.dart';

/// Defines the contract for delivering [PulseEvent]s to a destination.
///
/// Implement this interface to send events to a custom backend, file system,
/// third-party service, or any other destination.
///
/// ## Contract
///
/// - **Must not throw.** Internal errors must be handled within the
///   implementation. The pipeline does not catch transport exceptions.
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
///   Future<void> send(PulseEvent event) async {
///     try {
///       // Send event.toJson() to _endpoint
///     } catch (_) {
///       // Handle error internally — do not rethrow
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
  /// This method is called by the [EventPipeline] after all processors and
  /// sanitization have completed. Implementations must not throw.
  Future<void> send(PulseEvent event);

  /// Flushes any buffered events and releases resources.
  ///
  /// Called during SDK shutdown via [Pulse.close]. Must be idempotent —
  /// safe to call multiple times.
  Future<void> close();
}
