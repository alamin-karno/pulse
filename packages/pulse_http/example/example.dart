// ignore_for_file: avoid_print
import 'package:http/http.dart' as http;
import 'package:pulse_dev/pulse_dev.dart';
import 'package:pulse_http/pulse_http.dart';

/// Demonstrates wrapping [http.Client] with [PulseHttpClient] so every
/// request/response is captured as a [NetworkEvent] on the Pulse pipeline.
///
/// In a Flutter app, obtain the [PulseNetworkObserver] via `Pulse.network`
/// (from `pulse_dev_flutter`) instead of constructing one manually.
Future<void> main() async {
  final config = PulseConfig(
    dsn: 'https://your-key@ingest.example.com/your-project-id',
  );
  final pipeline = EventPipeline.fromConfig(config);

  final observer = PulseNetworkObserver(
    config: config,
    pipeline: pipeline,
    platform: PulsePlatform.dart,
    context: PulseContext.empty,
  );

  final client = PulseHttpClient(http.Client(), observer: observer);

  final response = await client.get(Uri.parse('https://example.com'));
  print('Response status: ${response.statusCode}');

  client.close();
  await pipeline.close();
}
