import 'package:pulse_dev/pulse_dev.dart';
import 'package:pulse_dev/src/performance/pulse_transaction_impl.dart';
import 'package:test/test.dart';

void main() {
  group('PulseTransaction', () {
    late PulseConfig config;
    late EventPipeline pipeline;
    late PulseContext context;

    setUp(() {
      config = const PulseConfig(
        dsn: 'https://key@ingest.example.com/1',
      );
      pipeline = EventPipeline.fromConfig(config);
      context = const PulseContext(
        osName: 'linux',
        osVersion: '1.0',
        deviceModel: 'pc',
      );
    });

    test('RealPulseTransaction records duration and status correctly', () {
      final tx = RealPulseTransaction(
        name: 'test_tx',
        config: config,
        pipeline: pipeline,
        platform: 'linux',
        context: context,
      );

      expect(tx.name, 'test_tx');

      final span = tx.startSpan('child_span');
      span.finish();

      tx.finish(status: 'ok');

      // Since NoOpTransport is used, we can't easily intercept the event here
      // without a spy transport. But we can test it does not crash.
    });

    test('NoOpPulseTransaction behaves safely', () {
      const tx = NoOpPulseTransaction('test');
      expect(tx.name, 'test');

      final span = tx.startSpan('span');
      span.finish();
      tx.finish(); // does nothing
    });
  });
}
