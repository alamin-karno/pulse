import '../config/pulse_config.dart';
import '../context/pulse_context.dart';
import '../events/pulse_event.dart';
import '../pipeline/event_pipeline.dart';
import '../utils/clock.dart';
import '../utils/id_generator.dart';
import 'pulse_transaction.dart';

/// Implementation of [ActivePulseSpan] that records actual durations.
class RealActiveSpan implements ActivePulseSpan {
  final String _name;
  final DateTime _startTime;
  final Clock _clock;

  DateTime? _endTime;
  String _status = 'ok';

  /// Creates a [RealActiveSpan].
  RealActiveSpan(this._name, this._clock) : _startTime = _clock.now();

  @override
  void finish({String? status}) {
    if (_endTime != null) return; // already finished
    _endTime = _clock.now();
    if (status != null) {
      _status = status;
    }
  }

  /// Converts this active span into a finalized [PulseSpan].
  PulseSpan toPulseSpan() {
    final end = _endTime ?? _clock.now();
    return PulseSpan(
      name: _name,
      startTime: _startTime,
      endTime:
          _endTime, // could be null if transaction finished early, but we use 'end' for duration
      duration: end.difference(_startTime),
      status: _status,
    );
  }
}

/// Implementation of [PulseTransaction] that records actual durations and spans.
class RealPulseTransaction implements PulseTransaction {
  final PulseConfig _config;
  final EventPipeline _pipeline;
  final String _platform;
  final PulseContext _context;
  final IdGenerator _idGenerator;
  final Clock _clock;

  @override
  final String name;
  final DateTime _startTime;
  final List<RealActiveSpan> _spans = [];
  bool _isFinished = false;

  /// Creates a [RealPulseTransaction].
  RealPulseTransaction({
    required this.name,
    required PulseConfig config,
    required EventPipeline pipeline,
    required String platform,
    required PulseContext context,
    IdGenerator? idGenerator,
    Clock? clock,
  })  : _config = config,
        _pipeline = pipeline,
        _platform = platform,
        _context = context,
        _idGenerator = idGenerator ?? const UuidGenerator(),
        _clock = clock ?? const SystemClock(),
        _startTime = (clock ?? const SystemClock()).now();

  @override
  ActivePulseSpan startSpan(String name) {
    if (_isFinished) {
      return const NoOpActiveSpan();
    }
    final span = RealActiveSpan(name, _clock);
    _spans.add(span);
    return span;
  }

  @override
  void finish({String? status, Object? error}) {
    if (_isFinished) return;
    _isFinished = true;

    final endTime = _clock.now();
    final duration = endTime.difference(_startTime);

    String finalStatus = status ?? 'ok';
    if (error != null && status == null) {
      finalStatus = 'error';
    }

    final event = TransactionEvent(
      id: _idGenerator.newId(),
      timestamp: _startTime, // usually transactions timestamp is start time
      sdkVersion: kPulseSdkVersion,
      appVersion: _config.release,
      environment: _config.environment,
      platform: _platform,
      context: _context,
      name: name,
      duration: duration,
      status: finalStatus,
      spans: _spans.map((s) => s.toPulseSpan()).toList(),
    );

    _pipeline.process(event);
  }
}

/// A no-op implementation of [ActivePulseSpan] for disabled or unsampled transactions.
class NoOpActiveSpan implements ActivePulseSpan {
  /// Creates a [NoOpActiveSpan].
  const NoOpActiveSpan();

  @override
  void finish({String? status}) {}
}

/// A no-op implementation of [PulseTransaction] for disabled or unsampled transactions.
class NoOpPulseTransaction implements PulseTransaction {
  @override
  final String name;

  /// Creates a [NoOpPulseTransaction].
  const NoOpPulseTransaction(this.name);

  @override
  ActivePulseSpan startSpan(String name) => const NoOpActiveSpan();

  @override
  void finish({String? status, Object? error}) {}
}
