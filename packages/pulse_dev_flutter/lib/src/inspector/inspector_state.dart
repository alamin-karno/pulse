// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:pulse_dev/pulse_dev.dart';

import '../pulse.dart';

/// Holds the in-memory state for the Pulse Debug Inspector.
///
/// In release mode, this state object is mostly a no-op to ensure zero
/// overhead. In debug/profile modes, it buffers recent events, network
/// requests, errors, and performance transactions.
class InspectorState extends ChangeNotifier implements PulseEventObserver {
  /// Singleton instance.
  static final InspectorState instance = InspectorState._();

  final int maxCapacity = 100;

  final Queue<ErrorEvent> _errors = Queue();
  final Queue<ExceptionEvent> _exceptions = Queue();
  final Queue<NetworkEvent> _network = Queue();
  final Queue<TransactionEvent> _performance = Queue();
  final Queue<CustomEvent> _custom = Queue();
  final Queue<BreadcrumbEvent> _breadcrumbs = Queue();

  bool _isListening = false;

  InspectorState._();

  /// Starts listening to the Pulse SDK pipeline.
  void start() {
    if (kReleaseMode) return;
    if (_isListening) return;
    Pulse.addEventObserver(this);
    _isListening = true;
  }

  /// Stops listening to the Pulse SDK pipeline.
  void stop() {
    if (kReleaseMode) return;
    if (!_isListening) return;
    Pulse.removeEventObserver(this);
    _isListening = false;
  }

  List<ErrorEvent> get errors => _errors.toList(growable: false);
  List<ExceptionEvent> get exceptions => _exceptions.toList(growable: false);
  List<NetworkEvent> get networkEvents => _network.toList(growable: false);
  List<TransactionEvent> get performanceEvents =>
      _performance.toList(growable: false);
  List<CustomEvent> get customEvents => _custom.toList(growable: false);
  List<BreadcrumbEvent> get breadcrumbs => _breadcrumbs.toList(growable: false);

  @override
  void onEvent(PulseEvent event) {
    if (kReleaseMode) return;

    if (event is ErrorEvent) {
      _add(_errors, event);
    } else if (event is ExceptionEvent) {
      _add(_exceptions, event);
    } else if (event is NetworkEvent) {
      _add(_network, event);
    } else if (event is TransactionEvent) {
      _add(_performance, event);
    } else if (event is CustomEvent) {
      _add(_custom, event);
    } else if (event is BreadcrumbEvent) {
      _add(_breadcrumbs, event);
    }

    notifyListeners();
  }

  void _add<T>(Queue<T> queue, T item) {
    queue.addFirst(item); // Newest first
    if (queue.length > maxCapacity) {
      queue.removeLast();
    }
  }

  /// Clears all buffered events.
  void clear() {
    if (kReleaseMode) return;
    _errors.clear();
    _exceptions.clear();
    _network.clear();
    _performance.clear();
    _custom.clear();
    _breadcrumbs.clear();
    notifyListeners();
  }
}
