// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:pulse_dev/pulse_dev.dart';
import 'package:pulse_dio/pulse_dio.dart';

/// Demonstrates adding [PulseDioInterceptor] to a [Dio] client so every
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

  final dio = Dio()..interceptors.add(PulseDioInterceptor(observer: observer));

  final response = await dio.get<void>('https://example.com');
  print('Response status: ${response.statusCode}');

  await pipeline.close();
}
