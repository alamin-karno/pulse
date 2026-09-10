import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pulse_dev/pulse_dev.dart';
import 'package:pulse_http/pulse_http.dart';
import 'package:test/test.dart';

class SpyTransport implements PulseTransport {
  final List<PulseEvent> events = [];

  @override
  Future<void> send(PulseEvent event) async {
    events.add(event);
  }

  Future<void> flush() async {}

  @override
  Future<void> close() async {}
}

void main() {
  group('PulseHttpClient', () {
    late SpyTransport transport;
    late PulseConfig config;
    late EventPipeline pipeline;
    late PulseNetworkObserver observer;
    late http.Client mockClient;
    late PulseHttpClient client;

    setUp(() {
      transport = SpyTransport();
      config = PulseConfig(
        dsn: 'https://key@host.com/1',
        transport: transport,
      );
      pipeline = EventPipeline.fromConfig(config);
      observer = PulseNetworkObserver(
        config: config,
        pipeline: pipeline,
        platform: PulsePlatform.dart,
        context: const PulseContext(),
      );

      mockClient = MockClient((request) async {
        if (request.url.path == '/error') {
          return http.Response('', 500);
        }
        return http.Response('{"status":"ok"}', 200,
            headers: {'content-type': 'application/json'});
      });

      client = PulseHttpClient(mockClient, observer: observer);
    });

    test('captures successful request', () async {
      await client.get(Uri.parse('https://api.example.com/users'));

      await Future.delayed(const Duration(milliseconds: 50));
      expect(transport.events, hasLength(1));

      final event = transport.events.first as NetworkEvent;
      expect(event.method, equals('GET'));
      expect(event.url, equals('https://api.example.com/users'));
      expect(event.statusCode, equals(200));
      expect(event.success, isTrue);
    });

    test('captures failed request', () async {
      await client.post(Uri.parse('https://api.example.com/error'));

      await Future.delayed(const Duration(milliseconds: 50));
      expect(transport.events, hasLength(1));

      final event = transport.events.first as NetworkEvent;
      expect(event.method, equals('POST'));
      expect(event.url, equals('https://api.example.com/error'));
      expect(event.statusCode, equals(500));
      expect(event.success, isFalse);
      expect(event.errorCategory, equals('server_error'));
    });
  });
}
