import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

void main() {
  group('EventPipeline — happy path', () {
    test('sends event to transport after sanitization', () async {
      final transport = CapturingTransport();
      final pipeline = EventPipeline(
        processors: const [],
        sanitizer: const DefaultSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
      );

      final event = EventFactory.customEvent(name: 'test_event');
      await pipeline.process(event);

      expect(transport.captured, hasLength(1));
      expect(transport.captured.first.id, equals(event.id));
    });

    test('applies processors in order', () async {
      final log = <String>[];

      final p1 = _TaggingProcessor('p1', log);
      final p2 = _TaggingProcessor('p2', log);
      final transport = CapturingTransport();

      final pipeline = EventPipeline(
        processors: [p1, p2],
        sanitizer: const DefaultSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
      );

      await pipeline.process(EventFactory.customEvent());

      expect(log, equals(['p1', 'p2']));
    });

    test('sanitizes event before transport', () async {
      final transport = CapturingTransport();
      final pipeline = EventPipeline(
        processors: const [],
        sanitizer: const DefaultSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
      );

      final event = EventFactory.customEvent(
        properties: {'password': 'secret', 'screen': 'Login'},
      );
      await pipeline.process(event);

      final sent = transport.captured.first as CustomEvent;
      expect(sent.properties['password'], equals('[REDACTED]'));
      expect(sent.properties['screen'], equals('Login'));
    });
  });

  group('EventPipeline — processor drop', () {
    test('event is not transported when processor drops it', () async {
      final transport = CapturingTransport();
      final pipeline = EventPipeline(
        processors: [DroppingProcessor()],
        sanitizer: const DefaultSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
      );

      await pipeline.process(EventFactory.customEvent());

      expect(transport.captured, isEmpty);
    });

    test('processors after a dropping processor do not run', () async {
      final log = <String>[];
      final pipeline = EventPipeline(
        processors: [
          DroppingProcessor(),
          _TaggingProcessor('should-not-run', log)
        ],
        sanitizer: const DefaultSanitizer(),
        transport: CapturingTransport(),
        logger: const NoOpLogger(),
      );

      await pipeline.process(EventFactory.customEvent());

      expect(log, isEmpty);
    });
  });

  group('EventPipeline — error isolation', () {
    test('throwing processor does not stop the pipeline', () async {
      final transport = CapturingTransport();
      final pipeline = EventPipeline(
        processors: [ThrowingProcessor()],
        sanitizer: const DefaultSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
      );

      await pipeline.process(EventFactory.customEvent());

      // Event continues (with pre-processor state) and reaches transport
      expect(transport.captured, hasLength(1));
    });

    test('throwing sanitizer drops the event (privacy-safe)', () async {
      final transport = CapturingTransport();
      final pipeline = EventPipeline(
        processors: const [],
        sanitizer: ThrowingSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
      );

      await pipeline.process(EventFactory.customEvent());

      expect(transport.captured, isEmpty);
    });

    test('throwing transport does not propagate exception', () async {
      final pipeline = EventPipeline(
        processors: const [],
        sanitizer: const DefaultSanitizer(),
        transport: ThrowingTransport(),
        logger: const NoOpLogger(),
      );

      expect(
        () async => pipeline.process(EventFactory.customEvent()),
        returnsNormally,
      );
    });
  });

  group('EventPipeline — fromConfig', () {
    test('creates pipeline from PulseConfig defaults', () async {
      final config = PulseConfig(
        dsn: 'https://key@host.com/1',
        transport: CapturingTransport(),
      );
      final pipeline = EventPipeline.fromConfig(config);

      await pipeline.process(EventFactory.customEvent());
      // No exception thrown — pipeline constructed successfully
    });
  });

  group('EventPipeline — close', () {
    test('close flushes the transport', () async {
      final transport = CapturingTransport();
      final pipeline = EventPipeline(
        processors: const [],
        sanitizer: const DefaultSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
      );

      await pipeline.close();
      expect(transport.isClosed, isTrue);
    });
    test('drops events based on sampleRate', () async {
      final transport = CapturingTransport();
      final pipeline = EventPipeline(
        processors: [],
        sanitizer: const DefaultSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
        sampleRate: 0.0, // Drop all
      );

      await pipeline.process(EventFactory.customEvent());
      await pipeline.process(EventFactory.customEvent());
      expect(transport.captured.length, 0, reason: 'sampleRate 0.0 should drop everything');

      final transportHalf = CapturingTransport();
      final pipelineHalf = EventPipeline(
        processors: [],
        sanitizer: const DefaultSanitizer(),
        transport: transportHalf,
        logger: const NoOpLogger(),
        sampleRate: 0.5,
      );

      // Statistically, sending 100 events with 0.5 sample rate should send
      // roughly 50. We just assert it sends some but not all.
      for (int i = 0; i < 100; i++) {
        await pipelineHalf.process(EventFactory.customEvent());
      }
      expect(transportHalf.captured.length, greaterThan(0));
      expect(transportHalf.captured.length, lessThan(100));
    });

    test('always sends events when sampleRate is 1.0', () async {
      final transport = CapturingTransport();
      final pipeline = EventPipeline(
        processors: [],
        sanitizer: const DefaultSanitizer(),
        transport: transport,
        logger: const NoOpLogger(),
        sampleRate: 1.0,
      );

      for (int i = 0; i < 10; i++) {
        await pipeline.process(EventFactory.customEvent());
      }
      expect(transport.captured.length, 10);
    });
  });
}

/// Test processor that records its tag to a log list and passes the event through.
final class _TaggingProcessor implements EventProcessor {
  final String tag;
  final List<String> log;

  _TaggingProcessor(this.tag, this.log);

  @override
  PulseEvent? process(PulseEvent event) {
    log.add(tag);
    return event;
  }
}
