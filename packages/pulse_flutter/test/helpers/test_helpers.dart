import 'package:pulse_core/pulse_core.dart';
import 'package:pulse_flutter/pulse_flutter.dart';

/// Creates a [PulseConfig] suitable for tests.
///
/// Uses [NoOpLogger] and an optional custom [transport].
/// [captureFlutterErrors] is `false` to avoid side-effects in tests.
PulseConfig testConfig({
  PulseTransport? transport,
  bool captureFlutterErrors = false,
  bool captureUnhandledErrors = false,
}) {
  return PulseConfig(
    dsn: 'https://test-key@test.host.com/test-project',
    environment: 'test',
    transport: transport ?? const NoOpTransport(),
    captureFlutterErrors: captureFlutterErrors,
    captureUnhandledErrors: captureUnhandledErrors,
  );
}

/// A [PulseTransport] that records received events for assertion in tests.
final class CapturingTransport implements PulseTransport {
  /// All events sent to this transport.
  final List<PulseEvent> captured = [];

  /// Whether [close] has been called.
  bool isClosed = false;

  @override
  Future<void> send(PulseEvent event) async => captured.add(event);

  @override
  Future<void> close() async => isClosed = true;
}
