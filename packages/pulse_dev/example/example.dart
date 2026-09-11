// ignore_for_file: avoid_print
import 'dart:developer' as developer;

import 'package:pulse_dev/pulse_dev.dart';

/// A minimal [PulseTransport] that logs delivered events instead of sending
/// them anywhere. Replace this with a real HTTP or self-hosted transport in
/// production — see [PulseTransport] for the interface contract.
final class LoggingTransport implements PulseTransport {
  /// Creates a [LoggingTransport].
  const LoggingTransport();

  @override
  Future<PulseTransportResult> send(PulseEvent event) async {
    developer.log(
      'Pulse event delivered: ${event.toJson()}',
      name: 'pulse_dev.example',
    );
    return PulseTransportResult.success;
  }

  @override
  Future<void> close() async {}
}

/// Demonstrates configuring [PulseConfig], building an [EventPipeline], and
/// manually pushing a [CustomEvent] through it — the same pipeline that
/// `pulse_dev_flutter`'s `Pulse` facade uses under the hood.
Future<void> main() async {
  const config = PulseConfig(
    dsn: 'https://your-key@ingest.example.com/your-project-id',
    environment: 'development',
    transport: LoggingTransport(),
  );

  final pipeline = EventPipeline.fromConfig(config);

  final event = CustomEvent(
    id: const UuidGenerator().newId(),
    timestamp: const SystemClock().now(),
    sdkVersion: kPulseSdkVersion,
    appVersion: '1.0.0',
    environment: config.environment,
    platform: PulsePlatform.dart,
    context: PulseContext.empty,
    name: 'example_started',
    properties: const {'source': 'example.dart'},
  );

  await pipeline.process(event);
  await pipeline.close();
}
