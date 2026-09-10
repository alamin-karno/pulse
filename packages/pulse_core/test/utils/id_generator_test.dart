import 'package:pulse_core/pulse_core.dart';
import 'package:test/test.dart';

void main() {
  group('UuidGenerator', () {
    test('generates a non-empty string', () {
      final gen = const UuidGenerator();
      expect(gen.newId(), isNotEmpty);
    });

    test('generates unique IDs on successive calls', () {
      final gen = const UuidGenerator();
      final ids = List.generate(100, (_) => gen.newId());
      final unique = ids.toSet();
      expect(unique.length, equals(100));
    });

    test('generates UUIDv4-formatted strings', () {
      final gen = const UuidGenerator();
      final id = gen.newId();
      // UUIDv4: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      expect(uuidRegex.hasMatch(id), isTrue,
          reason: 'Expected UUIDv4 format, got: $id');
    });
  });

  group('FakeIdGenerator', () {
    test('first ID is test-id-1', () {
      final gen = FakeIdGenerator();
      expect(gen.newId(), equals('test-id-1'));
    });

    test('IDs increment sequentially', () {
      final gen = FakeIdGenerator();
      expect(gen.newId(), equals('test-id-1'));
      expect(gen.newId(), equals('test-id-2'));
      expect(gen.newId(), equals('test-id-3'));
    });

    test('each FakeIdGenerator instance has its own counter', () {
      final gen1 = FakeIdGenerator();
      final gen2 = FakeIdGenerator();
      expect(gen1.newId(), equals('test-id-1'));
      expect(gen2.newId(), equals('test-id-1'));
    });
  });
}
