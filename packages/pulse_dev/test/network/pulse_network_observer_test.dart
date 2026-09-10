import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

class SpyTransport implements PulseTransport {
  final List<PulseEvent> events = [];

  @override
  Future<PulseTransportResult> send(PulseEvent event) async {
    events.add(event);
    return PulseTransportResult.success;
  }

  Future<void> flush() async {}

  @override
  Future<void> close() async {}
}

void main() {
  group('PulseNetworkObserver', () {
    late SpyTransport transport;
    late PulseConfig config;
    late EventPipeline pipeline;
    late PulseNetworkObserver observer;

    setUp(() {
      transport = SpyTransport();
      config = PulseConfig(
        dsn: 'https://key@host.com/1',
        transport: transport,
        network: const PulseNetworkConfig(
          enabled: true,
          sampleRate: 1.0,
          captureHeaders: false,
          captureBody: false,
          redactQueryParameters: {'secret', 'token'},
        ),
      );
      pipeline = EventPipeline.fromConfig(config);
      observer = PulseNetworkObserver(
        config: config,
        pipeline: pipeline,
        platform: PulsePlatform.dart,
        context: const PulseContext(),
      );
    });

    test('captures successful network request', () async {
      observer.capture(
        method: 'GET',
        url: 'https://api.example.com/users',
        duration: const Duration(milliseconds: 150),
        success: true,
        statusCode: 200,
      );

      // Processing is asynchronous if there are async processors, but DefaultSanitizer is synchronous.
      // However, we should await a short delay or await the pipeline if it has a way to wait.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transport.events, hasLength(1));
      final event = transport.events.first as NetworkEvent;

      expect(event.method, equals('GET'));
      expect(event.url, equals('https://api.example.com/users'));
      expect(event.statusCode, equals(200));
      expect(event.success, isTrue);
      expect(event.duration.inMilliseconds, equals(150));
    });

    test('redacts sensitive query parameters', () async {
      observer.capture(
        method: 'POST',
        url:
            'https://api.example.com/login?username=alice&secret=password123&token=abc',
        duration: const Duration(milliseconds: 200),
        success: false,
        statusCode: 401,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transport.events, hasLength(1));
      final event = transport.events.first as NetworkEvent;

      // 'username' is kept, 'secret' and 'token' are redacted
      final uri = Uri.parse(event.url);
      expect(uri.queryParameters['username'], equals('alice'));
      expect(uri.queryParameters['secret'], equals('[REDACTED]'));
      expect(uri.queryParameters['token'], equals('[REDACTED]'));
    });

    test('drops request if disabled in config', () async {
      config = PulseConfig(
        dsn: 'https://key@host.com/1',
        transport: transport,
        network: const PulseNetworkConfig(enabled: false),
      );
      pipeline = EventPipeline.fromConfig(config);
      observer = PulseNetworkObserver(
        config: config,
        pipeline: pipeline,
        platform: PulsePlatform.dart,
        context: const PulseContext(),
      );

      observer.capture(
        method: 'GET',
        url: 'https://api.example.com/',
        duration: const Duration(milliseconds: 10),
        success: true,
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(transport.events, isEmpty);
    });

    test('drops headers and body if not enabled in config', () async {
      observer.capture(
        method: 'POST',
        url: 'https://api.example.com/data',
        duration: const Duration(milliseconds: 50),
        success: true,
        requestHeaders: {'Content-Type': 'application/json'},
        responseHeaders: {'Server': 'nginx'},
        requestBody: '{"hello": "world"}',
        responseBody: '{"success": true}',
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transport.events, hasLength(1));
      final event = transport.events.first as NetworkEvent;
      expect(event.requestHeaders, isNull);
      expect(event.responseHeaders, isNull);
      expect(event.requestBody, isNull);
      expect(event.responseBody, isNull);
    });

    test('captures headers and body if enabled in config', () async {
      config = PulseConfig(
        dsn: 'https://key@host.com/1',
        transport: transport,
        network: const PulseNetworkConfig(
          captureHeaders: true,
          captureBody: true,
        ),
      );
      pipeline = EventPipeline.fromConfig(config);
      observer = PulseNetworkObserver(
        config: config,
        pipeline: pipeline,
        platform: PulsePlatform.dart,
        context: const PulseContext(),
      );

      observer.capture(
        method: 'POST',
        url: 'https://api.example.com/data',
        duration: const Duration(milliseconds: 50),
        success: true,
        requestHeaders: {'Content-Type': 'application/json'},
        responseHeaders: {'Server': 'nginx'},
        requestBody: '{"hello": "world"}',
        responseBody: '{"success": true}',
      );

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(transport.events, hasLength(1));
      final event = transport.events.first as NetworkEvent;
      expect(
          event.requestHeaders, equals({'Content-Type': 'application/json'}));
      expect(event.responseHeaders, equals({'Server': 'nginx'}));
      expect(event.requestBody, equals('{"hello": "world"}'));
      expect(event.responseBody, equals('{"success": true}'));
    });
  });
}
