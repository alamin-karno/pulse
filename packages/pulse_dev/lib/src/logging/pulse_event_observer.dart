import '../events/pulse_event.dart';

/// An interface for observing events as they pass through the [EventPipeline].
///
/// Observers are notified after an event has been processed (and potentially sanitized)
/// right before it is sent to the transport. This is primarily used for developer
/// tooling, such as the Pulse Debug Inspector, to monitor outgoing telemetry locally.
abstract interface class PulseEventObserver {
  /// Called when an event is processed and ready for transport.
  void onEvent(PulseEvent event);
}
