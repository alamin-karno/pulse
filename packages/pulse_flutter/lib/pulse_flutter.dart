/// Pulse Flutter — Developer Intelligence SDK for Flutter.
///
/// Import this library to access the [Pulse] static API:
///
/// ```dart
/// import 'package:pulse_flutter/pulse_flutter.dart';
///
/// await Pulse.initialize(
///   const PulseConfig(dsn: 'https://key@host.com/1'),
/// );
///
/// Pulse.run(() => runApp(const MyApp()));
/// ```
///
/// See the [Pulse] class for the complete API reference.
/// See [PulseConfig] for all configuration options.
library pulse_flutter;

// ── Public facade ──────────────────────────────────────────────────────────
export 'src/pulse.dart';

// ── Core re-exports (consumers should not need pulse_core directly) ────────
export 'package:pulse_core/pulse_core.dart'
    show
        // Configuration
        PulseConfig,
        // Events (for advanced use)
        PulseEvent,
        ErrorEvent,
        ExceptionEvent,
        BreadcrumbEvent,
        BreadcrumbLevel,
        CustomEvent,
        PulseEventType,
        // Context
        PulseContext,
        PulsePlatform,
        // Interfaces (for custom implementations)
        PulseTransport,
        PulseSanitizer,
        EventProcessor,
        PulseLogger,
        PulseLogLevel,
        PulseStorage,
        // Default implementations
        NoOpTransport,
        DefaultSanitizer,
        NoOpLogger,
        // Pipeline
        EventPipeline,
        SanitizingProcessor,
        // Utilities
        Clock,
        SystemClock,
        FakeClock,
        IdGenerator,
        UuidGenerator,
        FakeIdGenerator,
        kPulseSdkVersion,
        kPulseEventSchemaVersion;
