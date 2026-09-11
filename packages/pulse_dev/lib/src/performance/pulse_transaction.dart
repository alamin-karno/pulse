import '../config/pulse_config.dart';
import '../context/pulse_context.dart';
import '../pipeline/event_pipeline.dart';
import '../utils/clock.dart';
import '../utils/id_generator.dart';
import 'pulse_transaction_impl.dart';

/// Represents an active performance measurement span.
abstract interface class ActivePulseSpan {
  /// Finishes the span, marking its end time and duration.
  ///
  /// Optionally accepts an [error] or status string.
  void finish({String? status});
}

/// Represents an active performance transaction.
///
/// A transaction is a top-level operation (e.g., loading a screen)
/// that can contain multiple nested spans.
abstract interface class PulseTransaction {
  /// The name of this transaction.
  String get name;

  /// Starts a child span within this transaction.
  ///
  /// Returns an [ActivePulseSpan] that must be finished.
  ActivePulseSpan startSpan(String name);

  /// Finishes the transaction, capturing its duration and all completed spans,
  /// and sends it to the event pipeline.
  ///
  /// [status] defaults to 'ok'. If an [error] is provided, the status
  /// may be automatically updated.
  void finish({String? status, Object? error});

  /// Creates a real, reporting [PulseTransaction] backed by [RealPulseTransaction].
  ///
  /// Prefer [Pulse.startTransaction] for typical usage; this factory is the
  /// lower-level constructor used internally and by `pulse_dev_flutter`.
  factory PulseTransaction.create({
    required String name,
    required PulseConfig config,
    required EventPipeline pipeline,
    required String platform,
    required PulseContext context,
    IdGenerator? idGenerator,
    Clock? clock,
  }) = RealPulseTransaction;

  /// Creates a no-op [PulseTransaction] that discards data.
  factory PulseTransaction.noOp(String name) = NoOpPulseTransaction;
}
