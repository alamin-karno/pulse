import 'package:pulse_dev/pulse_dev.dart';
import 'package:test/test.dart';

import '../helpers/event_factory.dart';

void main() {
  group('NoOpTransport', () {
    test('send accepts any event without throwing', () async {
      const transport = NoOpTransport();
      final event = EventFactory.customEvent();

      await expectLater(transport.send(event), completes);
    });

    test('close completes without throwing', () async {
      const transport = NoOpTransport();
      await expectLater(transport.close(), completes);
    });

    test('close is idempotent', () async {
      const transport = NoOpTransport();
      await transport.close();
      await expectLater(transport.close(), completes);
    });
  });
}
