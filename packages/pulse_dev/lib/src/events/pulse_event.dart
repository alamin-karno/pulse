import 'package:meta/meta.dart';

import '../context/pulse_context.dart';
import 'pulse_event_type.dart';

part 'error_event.dart';
part 'exception_event.dart';
part 'breadcrumb_event.dart';
part 'custom_event.dart';
part 'network_event.dart';

/// The current schema version embedded in every serialized event.
///
/// Increment this when the serialization format changes in a
/// backwards-incompatible way.
const String kPulseEventSchemaVersion = '1';

/// The current version of the Pulse SDK.
///
/// Embedded in every event for diagnostics and compatibility checking.
const String kPulseSdkVersion = '0.1.0';

/// Base class for all Pulse SDK events.
///
/// `PulseEvent` is `sealed` — all concrete implementations are defined within
/// `pulse_dev`. This guarantees:
///
/// - Exhaustive pattern matching in `switch` statements.
/// - Stable serialization contracts across all event types.
/// - No external code can introduce new subtypes that bypass the pipeline.
///
/// ## Event types
///
/// | Type | Class | Captured via |
/// |------|-------|--------------|
/// | `error` | [ErrorEvent] | [Pulse.captureError] |
/// | `exception` | [ExceptionEvent] | [Pulse.captureException] |
/// | `breadcrumb` | [BreadcrumbEvent] | [Pulse.addBreadcrumb] |
/// | `custom` | [CustomEvent] | [Pulse.track] |
/// | `network` | [NetworkEvent] | [Pulse.network] |
///
/// ## Serialization
///
/// Every event implements [toJson], which returns a JSON-compatible
/// `Map<String, dynamic>`. The schema is versioned via [schemaVersion]
/// for forward-compatibility.
///
/// ## Immutability
///
/// All events are `@immutable`. Fields are `final`. Events are write-once
/// value objects that flow through the [EventPipeline].
@immutable
sealed class PulseEvent {
  /// Unique identifier for this event (UUID v4).
  final String id;

  /// When the event was captured, in UTC.
  final DateTime timestamp;

  /// The category of this event.
  final PulseEventType type;

  /// The version of the Pulse SDK that captured this event.
  ///
  /// Defaults to [kPulseSdkVersion].
  final String sdkVersion;

  /// The version of the application, if configured via [PulseConfig.release].
  final String? appVersion;

  /// The deployment environment (e.g., `'production'`, `'staging'`).
  final String environment;

  /// The platform on which this event was captured.
  ///
  /// See [PulsePlatform] for standard values.
  final String platform;

  /// Device and application context at the time of capture.
  final PulseContext context;

  /// Serialization schema version for forward-compatibility.
  ///
  /// Always [kPulseEventSchemaVersion] for events created by this SDK version.
  final String schemaVersion;

  /// Creates a [PulseEvent].
  const PulseEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.sdkVersion,
    required this.appVersion,
    required this.environment,
    required this.platform,
    required this.context,
    this.schemaVersion = kPulseEventSchemaVersion,
  });

  /// Serializes this event to a JSON-compatible map.
  ///
  /// The returned map contains all base fields plus type-specific fields.
  /// It can be passed directly to `jsonEncode`.
  Map<String, dynamic> toJson();

  /// Returns a map containing the fields common to all [PulseEvent] subtypes.
  ///
  /// Subclasses call this from their [toJson] implementation and merge in
  /// their own type-specific fields.
  @protected
  Map<String, dynamic> baseJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        'sdk_version': sdkVersion,
        if (appVersion != null) 'app_version': appVersion,
        'environment': environment,
        'platform': platform,
        'schema_version': schemaVersion,
        'context': context.toJson(),
      };
}
