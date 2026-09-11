/// Pulse Flutter — Developer Intelligence SDK for Flutter.
///
/// Import this library to access the [Pulse] static API:
///
/// ```dart
/// import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';
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
library pulse_dev_flutter;

import 'pulse_dev_flutter.dart' show Pulse, PulseConfig;

// ── Core re-exports (consumers should not need pulse_dev directly) ────────
export 'package:pulse_dev/pulse_dev.dart'
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
        NetworkEvent,
        TransactionEvent,
        PulseSpan,
        PulseEventType,
        // Context
        PulseContext,
        PulsePlatform,
        // Network
        PulseNetworkConfig,
        PulseNetworkObserver,
        // Performance
        PulsePerformanceConfig,
        PulseTransaction,
        // Sanitization
        PulseSanitizationConfig,
        // Interfaces (for custom implementations)
        PulseTransport,
        PulseTransportResult,
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

// ── UI Components ────────────────────────────────────────────────────────
export 'src/inspector/pulse_inspector_widget.dart';

// ── Public facade ──────────────────────────────────────────────────────────
export 'src/pulse.dart';
