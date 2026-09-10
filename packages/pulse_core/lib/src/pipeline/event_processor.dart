import '../events/pulse_event.dart';

/// Defines the contract for processing [PulseEvent]s in the pipeline.
///
/// Processors are applied in order before sanitization and transport.
/// They can enrich events with additional data, filter events, or transform
/// event fields.
///
/// ## Contract
///
/// - Return the (possibly modified) event to continue pipeline processing.
/// - Return `null` to **drop** the event — no further processors run, and
///   the event is not sanitized or transported.
/// - Do not throw — exceptions from processors are caught by the pipeline,
///   logged, and the original pre-processor event continues.
///
/// ## Example: tag all events with user metadata
///
/// ```dart
/// final class UserTagProcessor implements EventProcessor {
///   final String userId;
///   const UserTagProcessor(this.userId);
///
///   @override
///   PulseEvent? process(PulseEvent event) {
///     // For now, pass through — event enrichment will use context in future
///     return event;
///   }
/// }
/// ```
///
/// ## Example: filter events by environment
///
/// ```dart
/// final class StagingFilterProcessor implements EventProcessor {
///   @override
///   PulseEvent? process(PulseEvent event) {
///     if (event.environment == 'staging') return null; // drop staging events
///     return event;
///   }
/// }
/// ```
abstract interface class EventProcessor {
  /// Processes [event] and returns the result.
  ///
  /// Returns a [PulseEvent] (the same or a transformed copy) to continue.
  /// Returns `null` to drop the event from the pipeline.
  PulseEvent? process(PulseEvent event);
}
