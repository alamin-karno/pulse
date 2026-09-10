import '../events/pulse_event.dart';
import 'pulse_storage.dart';

/// A minimal, non-persistent implementation of [PulseStorage].
///
/// Keeps events in a simple memory list. Events will be lost if the
/// application terminates before they are sent. Useful for development,
/// testing, or environments without file system access.
final class InMemoryPulseStorage implements PulseStorage {
  final List<PulseEvent> _events = [];

  /// Creates an [InMemoryPulseStorage].
  InMemoryPulseStorage();

  @override
  Future<void> store(PulseEvent event) async {
    _events.add(event);
  }

  @override
  Future<List<PulseEvent>> retrieveAll() async {
    return List.unmodifiable(_events);
  }

  @override
  Future<void> delete(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<void> clear() async {
    _events.clear();
  }
}
