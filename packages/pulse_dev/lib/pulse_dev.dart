/// Pulse Core — Pure Dart Developer Intelligence SDK.
///
/// This library provides the foundational building blocks of the Pulse SDK:
/// event models, the event pipeline, transport and storage interfaces,
/// privacy sanitization, and configuration.
///
/// ## Typical usage
///
/// For Flutter applications, use the higher-level
/// [`pulse_dev_flutter`](https://pub.dev/packages/pulse_dev_flutter) package which
/// builds on this library.
///
/// For pure Dart projects, import this library directly:
///
/// ```dart
/// import 'package:pulse_dev/pulse_dev.dart';
/// ```
///
/// ## Key types
///
/// - [PulseConfig] — SDK configuration
/// - [PulseEvent] — sealed base for all events
/// - [EventPipeline] — the processing engine
/// - [PulseTransport] — interface for event delivery
/// - [PulseSanitizer] — interface for privacy sanitization
/// - [EventProcessor] — interface for event enrichment/filtering
// ignore_for_file: directives_ordering
library pulse_dev;

// ── Configuration ──────────────────────────────────────────────────────────
export 'src/config/pulse_config.dart';

// ── Context ────────────────────────────────────────────────────────────────
export 'src/context/pulse_context.dart';

// ── Events ─────────────────────────────────────────────────────────────────
export 'src/events/pulse_event.dart'
    show
        PulseEvent,
        ErrorEvent,
        ExceptionEvent,
        BreadcrumbEvent,
        BreadcrumbLevel,
        CustomEvent,
        NetworkEvent,
        kPulseSdkVersion,
        kPulseEventSchemaVersion;
export 'src/events/pulse_event_type.dart';

// ── Breadcrumbs ────────────────────────────────────────────────────────────
export 'src/breadcrumbs/breadcrumb_buffer.dart';

// ── Pipeline ───────────────────────────────────────────────────────────────
export 'src/pipeline/event_pipeline.dart';
export 'src/pipeline/event_processor.dart';
export 'src/pipeline/processors/sanitizing_processor.dart';

// ── Sanitization ───────────────────────────────────────────────────────────
export 'src/sanitization/default_sanitizer.dart';
export 'src/sanitization/pulse_sanitization_config.dart';
export 'src/sanitization/pulse_sanitizer.dart';

// ── Network ────────────────────────────────────────────────────────────────
export 'src/network/pulse_network_config.dart';
export 'src/network/pulse_network_observer.dart';

// ── Transport ──────────────────────────────────────────────────────────────
export 'src/transport/no_op_transport.dart';
export 'src/transport/pulse_transport.dart';

// ── Storage ────────────────────────────────────────────────────────────────
export 'src/storage/pulse_storage.dart';

// ── Logging ────────────────────────────────────────────────────────────────
export 'src/logging/no_op_logger.dart';
export 'src/logging/pulse_logger.dart';

// ── Utilities ──────────────────────────────────────────────────────────────
export 'src/utils/clock.dart' show Clock, SystemClock, FakeClock;
export 'src/utils/id_generator.dart'
    show IdGenerator, UuidGenerator, FakeIdGenerator;
