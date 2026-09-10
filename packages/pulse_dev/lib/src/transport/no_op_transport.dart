import 'package:meta/meta.dart';

import '../events/pulse_event.dart';
import 'pulse_transport.dart';

/// A [PulseTransport] that silently discards all events.
///
/// This is the default transport used when no custom transport is provided
/// via [PulseConfig.transport]. All events are accepted but immediately
/// discarded without any I/O.
///
/// **Use cases:**
/// - Development environments where you do not yet have a backend.
/// - Test environments where you want to verify SDK behavior without
///   network calls (prefer [CapturingTransport] in tests to inspect events).
/// - Explicitly opting out of event delivery.
///
/// For production use, provide a real transport implementation:
///
/// ```dart
/// PulseConfig(
///   dsn: 'https://key@ingest.example.com/1',
///   transport: MyHttpTransport(),
/// )
/// ```
@immutable
final class NoOpTransport implements PulseTransport {
  /// Creates a [NoOpTransport].
  const NoOpTransport();

  @override
  Future<PulseTransportResult> send(PulseEvent event) async {
    // Intentionally discards the event. No I/O performed.
    return PulseTransportResult.success;
  }

  @override
  Future<void> close() async {
    // Nothing to flush or release.
  }
}
