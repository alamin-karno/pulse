import '../events/pulse_event.dart';

/// A fixed-capacity ring buffer for [BreadcrumbEvent]s.
///
/// Breadcrumbs are stored in insertion order. When the buffer is at capacity
/// and a new breadcrumb is added, the oldest breadcrumb is evicted.
///
/// The buffer is attached to [ErrorEvent]s and [ExceptionEvent]s at capture
/// time, providing context about what happened before the error.
///
/// ## Capacity
///
/// The maximum number of breadcrumbs is set via [PulseConfig.maxBreadcrumbs]
/// (default: 100). Set to `0` to disable breadcrumb collection.
///
/// ## Thread safety
///
/// [BreadcrumbBuffer] is not thread-safe. In Flutter applications it is only
/// accessed from the main isolate.
///
/// ## Example
///
/// ```dart
/// final buffer = BreadcrumbBuffer(maxCapacity: 10);
/// buffer.add(breadcrumb);
/// final snapshot = buffer.breadcrumbs; // unmodifiable copy
/// buffer.clear();
/// ```
final class BreadcrumbBuffer {
  /// The maximum number of breadcrumbs this buffer may hold.
  ///
  /// When [add] is called and the buffer is at capacity, the oldest entry is
  /// evicted. A value of `0` disables breadcrumb collection.
  final int maxCapacity;
  final List<BreadcrumbEvent> _buffer;

  /// Creates a [BreadcrumbBuffer] with the given [maxCapacity].
  ///
  /// [maxCapacity] must be non-negative. A value of `0` effectively disables
  /// breadcrumb collection.
  BreadcrumbBuffer({this.maxCapacity = 100})
      : assert(maxCapacity >= 0, 'maxCapacity must be non-negative'),
        _buffer = [];

  /// Adds [breadcrumb] to the buffer.
  ///
  /// If the buffer is at [maxCapacity], the oldest entry is evicted before
  /// the new one is added. If [maxCapacity] is `0`, this is a no-op.
  void add(BreadcrumbEvent breadcrumb) {
    if (maxCapacity == 0) return;
    if (_buffer.length >= maxCapacity) {
      _buffer.removeAt(0);
    }
    _buffer.add(breadcrumb);
  }

  /// Returns an unmodifiable snapshot of the current breadcrumbs.
  ///
  /// Breadcrumbs are ordered oldest-first. The returned list is a
  /// copy — subsequent [add] or [clear] calls do not affect it.
  List<BreadcrumbEvent> get breadcrumbs => List.unmodifiable(_buffer);

  /// Removes all breadcrumbs from the buffer.
  void clear() => _buffer.clear();

  /// The number of breadcrumbs currently in the buffer.
  int get length => _buffer.length;

  /// Whether the buffer contains no breadcrumbs.
  bool get isEmpty => _buffer.isEmpty;

  /// Whether the buffer contains at least one breadcrumb.
  bool get isNotEmpty => _buffer.isNotEmpty;
}
