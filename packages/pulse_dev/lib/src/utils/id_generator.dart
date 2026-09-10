import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

/// An abstraction over unique identifier generation.
///
/// Inject a [FakeIdGenerator] in tests to produce predictable, deterministic
/// event IDs:
///
/// ```dart
/// final ids = FakeIdGenerator();
/// final id1 = ids.newId(); // 'test-id-1'
/// final id2 = ids.newId(); // 'test-id-2'
/// ```
///
/// Use [UuidGenerator] in production.
abstract interface class IdGenerator {
  /// Generates a new unique identifier.
  ///
  /// Implementations must return globally unique values across calls.
  String newId();
}

/// Production [IdGenerator] backed by UUID v4.
///
/// Generates RFC 4122-compliant version 4 UUIDs.
@immutable
final class UuidGenerator implements IdGenerator {
  static const _uuid = Uuid();

  /// Creates a [UuidGenerator].
  const UuidGenerator();

  @override
  String newId() => _uuid.v4();
}

/// A sequential [IdGenerator] for use in tests.
///
/// Returns IDs in the form `'test-id-1'`, `'test-id-2'`, etc.
/// Each instance maintains its own independent counter.
///
/// ```dart
/// final gen = FakeIdGenerator();
/// expect(gen.newId(), 'test-id-1');
/// expect(gen.newId(), 'test-id-2');
/// ```
@visibleForTesting
final class FakeIdGenerator implements IdGenerator {
  int _counter = 0;

  /// Creates a [FakeIdGenerator].
  FakeIdGenerator();

  @override
  String newId() => 'test-id-${++_counter}';
}
