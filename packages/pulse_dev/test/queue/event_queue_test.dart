import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

class StubTransport implements PulseTransport {
  PulseTransportResult nextResult = PulseTransportResult.success;
  final List<PulseEvent> sentEvents = [];
  bool throwException = false;

  @override
  Future<PulseTransportResult> send(PulseEvent event) async {
    if (throwException) {
      throw Exception('Network unreachable');
    }
    sentEvents.add(event);
    return nextResult;
  }

  @override
  Future<void> close() async {}
}

void main() {
  group('EventQueue', () {
    late EventQueue queue;
    late InMemoryPulseStorage storage;
    late StubTransport transport;
    late NoOpLogger logger;
    late SystemClock clock;

    setUp(() {
      storage = InMemoryPulseStorage();
      transport = StubTransport();
      logger = const NoOpLogger();
      clock = const SystemClock();

      queue = EventQueue(
        storage: storage,
        transport: transport,
        logger: logger,
        clock: clock,
        maxQueueSize: 3,
      );
    });

    test('success removes event from storage', () async {
      transport.nextResult = PulseTransportResult.success;
      final event = EventFactory.customEvent(name: 'success_event');

      await queue.enqueue(event);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(transport.sentEvents, hasLength(1));
      final stored = await storage.retrieveAll();
      expect(stored, isEmpty);
    });

    test('permanent failure removes event from storage', () async {
      transport.nextResult = PulseTransportResult.permanentFailure;
      final event = EventFactory.customEvent(name: 'bad_event');

      await queue.enqueue(event);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(transport.sentEvents, hasLength(1));
      final stored = await storage.retrieveAll();
      expect(stored, isEmpty);
    });

    test('retryable failure keeps event in storage', () async {
      transport.nextResult = PulseTransportResult.retryableFailure;
      final event = EventFactory.customEvent(name: 'retry_event');

      await queue.enqueue(event);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(transport.sentEvents, hasLength(1));
      final stored = await storage.retrieveAll();
      expect(stored, hasLength(1));
      expect(stored.first.id, equals(event.id));
    });

    test('transport exception acts as retryable failure', () async {
      transport.throwException = true;
      final event = EventFactory.customEvent(name: 'error_event');

      await queue.enqueue(event);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(transport.sentEvents, isEmpty); // Because it threw before adding
      final stored = await storage.retrieveAll();
      expect(stored, hasLength(1));
    });

    test('enforces maxQueueSize by dropping oldest events', () async {
      // Set to fail so events stay in the queue
      transport.nextResult = PulseTransportResult.retryableFailure;

      final e1 = EventFactory.customEvent(name: '1');
      final e2 = EventFactory.customEvent(name: '2');
      final e3 = EventFactory.customEvent(name: '3');
      final e4 = EventFactory.customEvent(name: '4');

      await queue.enqueue(e1);
      await queue.enqueue(e2);
      await queue.enqueue(e3);
      await queue.enqueue(e4); // Should evict e1

      final stored = await storage.retrieveAll();
      expect(stored, hasLength(3));
      expect(stored[0].id, equals(e2.id));
      expect(stored[1].id, equals(e3.id));
      expect(stored[2].id, equals(e4.id));
    });
  });
}
