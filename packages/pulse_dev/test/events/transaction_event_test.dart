import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

void main() {
  group('TransactionEvent', () {
    test('toJson serializes correctly', () {
      final now = DateTime.utc(2026, 9, 10, 12, 0, 0);
      final span = PulseSpan(
        name: 'test_span',
        startTime: now,
        endTime: now.add(const Duration(milliseconds: 50)),
        duration: const Duration(milliseconds: 50),
        status: 'ok',
      );

      final event = TransactionEvent(
        id: '123e4567-e89b-12d3-a456-426614174000',
        timestamp: now,
        sdkVersion: '0.1.0',
        appVersion: '1.0.0',
        environment: 'production',
        platform: 'ios',
        context: const PulseContext(
            osName: 'iOS', osVersion: '15.0', deviceModel: 'iPhone 13'),
        name: 'load_dashboard',
        duration: const Duration(milliseconds: 200),
        status: 'ok',
        spans: [span],
      );

      final json = event.toJson();

      expect(json['id'], '123e4567-e89b-12d3-a456-426614174000');
      expect(json['type'], 'transaction');
      expect(json['transaction'], 'load_dashboard');
      expect(json['duration_ms'], 200);
      expect(json['status'], 'ok');
      expect(json['spans'], isA<List<dynamic>>());
      final spans = json['spans'] as List<dynamic>;
      expect((spans[0] as Map<String, dynamic>)['name'], 'test_span');
      expect((spans[0] as Map<String, dynamic>)['duration_ms'], 50);
    });
  });
}
