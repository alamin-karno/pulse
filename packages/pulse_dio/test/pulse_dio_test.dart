import 'package:dio/dio.dart';
import 'package:pulse_dev/pulse_dev.dart';
import 'package:pulse_dio/pulse_dio.dart';
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
  group('PulseDioInterceptor', () {
    late SpyTransport transport;
    late PulseConfig config;
    late EventPipeline pipeline;
    late PulseNetworkObserver observer;
    late Dio dio;

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

      dio = Dio();
      dio.httpClientAdapter = _MockHttpClientAdapter();
      dio.interceptors.add(PulseDioInterceptor(observer: observer));
    });

    test('captures successful request', () async {
      await dio.get('https://api.example.com/users');

      await Future.delayed(const Duration(milliseconds: 50));
      expect(transport.events, hasLength(1));

      final event = transport.events.first as NetworkEvent;
      expect(event.method, equals('GET'));
      expect(event.url, equals('https://api.example.com/users'));
      expect(event.statusCode, equals(200));
      expect(event.success, isTrue);
    });

    test('captures failed request', () async {
      try {
        await dio.post('https://api.example.com/error');
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 50));
      expect(transport.events, hasLength(1));

      final event = transport.events.first as NetworkEvent;
      expect(event.method, equals('POST'));
      expect(event.url, equals('https://api.example.com/error'));
      expect(event.statusCode, equals(500));
      expect(event.success, isFalse);
      expect(event.errorCategory, equals('server'));
    });
  });
}

class _MockHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    if (options.uri.path == '/error') {
      return ResponseBody.fromString('', 500);
    }
    return ResponseBody.fromString('{"status":"ok"}', 200, headers: {
      'content-type': ['application/json']
    });
  }

  @override
  void close({bool force = false}) {}
}
