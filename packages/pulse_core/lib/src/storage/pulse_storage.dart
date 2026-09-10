import '../events/pulse_event.dart';

/// Defines the contract for persisting [PulseEvent]s on the device.
///
/// Storage enables offline event queuing: events captured when the transport
/// is unavailable are stored locally and retried when connectivity is restored.
///
/// ## Note
///
/// No implementation is provided in Phase 1. This interface is defined early
/// so that the [EventPipeline] architecture accommodates persistence without
/// requiring structural refactoring in future phases.
///
/// Implementations will be added in Phase 3 (offline queue support).
///
/// ## Implementing custom storage
///
/// ```dart
/// final class SharedPrefsStorage implements PulseStorage {
///   @override
///   Future<void> store(PulseEvent event) async { ... }
///
///   @override
///   Future<List<PulseEvent>> retrieveAll() async { ... }
///
///   @override
///   Future<void> delete(String eventId) async { ... }
///
///   @override
///   Future<void> clear() async { ... }
/// }
/// ```
///
/// See also:
/// - [PulseTransport] — for the event delivery abstraction.
abstract interface class PulseStorage {
  /// Persists [event] for later retrieval.
  ///
  /// Implementations should be resilient to storage failures and must not
  /// throw.
  Future<void> store(PulseEvent event);

  /// Returns all currently stored events.
  ///
  /// The returned list may be empty if no events are stored.
  Future<List<PulseEvent>> retrieveAll();

  /// Removes the event with [eventId] from storage.
  ///
  /// A no-op if the event does not exist.
  Future<void> delete(String eventId);

  /// Removes all stored events.
  Future<void> clear();
}
