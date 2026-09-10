import 'package:meta/meta.dart';

import '../../events/pulse_event.dart';
import '../../sanitization/pulse_sanitizer.dart';
import '../event_processor.dart';

/// An [EventProcessor] that applies a [PulseSanitizer] within the processor
/// chain.
///
/// Use [SanitizingProcessor] when you need to apply custom sanitization at a
/// specific position in the processor chain — for example, before or after
/// other enrichment processors.
///
/// Note that the [EventPipeline] always applies the configured [PulseSanitizer]
/// as a **mandatory final step** regardless of whether a [SanitizingProcessor]
/// is present in the processor list. [SanitizingProcessor] is an additional,
/// optional sanitization step within the chain.
///
/// ## Example
///
/// ```dart
/// PulseConfig(
///   processors: [
///     MyEnrichmentProcessor(),
///     SanitizingProcessor(MyCustomSanitizer()), // sanitize after enrichment
///   ],
/// )
/// ```
@immutable
final class SanitizingProcessor implements EventProcessor {
  /// The sanitizer to apply.
  final PulseSanitizer sanitizer;

  /// Creates a [SanitizingProcessor] wrapping [sanitizer].
  const SanitizingProcessor(this.sanitizer);

  @override
  PulseEvent? process(PulseEvent event) => sanitizer.sanitize(event);
}
