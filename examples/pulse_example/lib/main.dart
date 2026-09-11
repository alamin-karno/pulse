import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';
import 'package:pulse_dio/pulse_dio.dart';
import 'package:pulse_http/pulse_http.dart';

// ── Bootstrap ────────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Pulse.initialize(
    PulseConfig(
      dsn: 'https://example-key@ingest.example.com/demo-project',
      environment: 'development',
      release: '1.0.0+1',
      debug: true,
      transport: _ConsoleTransport(),
      maxBreadcrumbs: 100,
      sampleRate: 1.0,
      network: PulseNetworkConfig(
        enabled: true,
        captureHeaders: false,
        captureBody: false,
      ),
      performance: PulsePerformanceConfig(
        enabled: true,
        sampleRate: 1.0,
        detectSlowOperations: true,
      ),
    ),
  );

  // Captures all unhandled async errors automatically.
  Pulse.run(() => runApp(const PulseExampleApp()));
}

// ── Debug transport ───────────────────────────────────────────────────────────

/// Prints every event to the Flutter console for demonstration.
/// Replace with a real HTTP transport in production.
final class _ConsoleTransport implements PulseTransport {
  @override
  Future<PulseTransportResult> send(PulseEvent event) async {
    final json = event.toJson();
    debugPrint('╔══ [Pulse] ${json['type']} ══════════════════════════╗');
    debugPrint('  id        : ${json['id']}');
    debugPrint('  timestamp : ${json['timestamp']}');
    if (json.containsKey('message'))
      debugPrint('  message   : ${json['message']}');
    if (json.containsKey('name')) debugPrint('  name      : ${json['name']}');
    if (json.containsKey('exception_type'))
      debugPrint('  exception : ${json['exception_type']}');
    if (json.containsKey('url')) debugPrint('  url       : ${json['url']}');
    debugPrint('╚═══════════════════════════════════════════════════════╝');
    return PulseTransportResult.success;
  }

  @override
  Future<void> close() async {}
}

// ── App root ──────────────────────────────────────────────────────────────────

class PulseExampleApp extends StatelessWidget {
  const PulseExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse SDK Demo',
      debugShowCheckedModeBanner: false,
      // Injects the Pulse Debug Inspector overlay.
      // Automatically disabled in release builds (kReleaseMode guard).
      builder: PulseInspector.builder(enabled: true),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5A0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardColor: const Color(0xFF161B22),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          foregroundColor: Color(0xFF00E5A0),
        ),
      ),
      home: const _HomeScreen(),
    );
  }
}

// ── Home screen ───────────────────────────────────────────────────────────────

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    final demos = [
      _DemoEntry(
        icon: Icons.error_outline,
        color: Colors.redAccent,
        title: 'Error Capture',
        subtitle: 'Exception, Error, Flutter error, unhandled async',
        screen: const _ErrorScreen(),
      ),
      _DemoEntry(
        icon: Icons.timeline,
        color: Colors.orangeAccent,
        title: 'Breadcrumbs',
        subtitle: 'Record context before a crash',
        screen: const _BreadcrumbScreen(),
      ),
      _DemoEntry(
        icon: Icons.analytics_outlined,
        color: Colors.blueAccent,
        title: 'Custom Events',
        subtitle: 'Track arbitrary events with properties',
        screen: const _CustomEventScreen(),
      ),
      _DemoEntry(
        icon: Icons.wifi_outlined,
        color: Colors.purpleAccent,
        title: 'Network Monitoring',
        subtitle: 'PulseHttpClient + PulseDioInterceptor',
        screen: const _NetworkScreen(),
      ),
      _DemoEntry(
        icon: Icons.speed_outlined,
        color: Colors.greenAccent,
        title: 'Performance',
        subtitle: 'Transactions, spans, slow operations',
        screen: const _PerformanceScreen(),
      ),
      _DemoEntry(
        icon: Icons.privacy_tip_outlined,
        color: Colors.tealAccent,
        title: 'Sanitization',
        subtitle: 'See how PII is automatically redacted',
        screen: const _SanitizationScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulse SDK Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: const Text('v$kPulseSdkVersion'),
              backgroundColor: Colors.greenAccent.withAlpha(30),
              labelStyle:
                  const TextStyle(color: Colors.greenAccent, fontSize: 12),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final d = demos[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: d.color.withAlpha(30),
                child: Icon(d.icon, color: d.color),
              ),
              title: Text(d.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(d.subtitle,
                  style: TextStyle(color: Colors.white.withAlpha(130))),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => d.screen),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DemoEntry {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget screen;
  const _DemoEntry({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.screen,
  });
}

// ── Error capture screen ──────────────────────────────────────────────────────

class _ErrorScreen extends StatefulWidget {
  const _ErrorScreen();
  @override
  State<_ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<_ErrorScreen> {
  final List<String> _log = [];

  void _log_(String msg) => setState(() => _log.insert(0, msg));

  void _captureException() {
    Pulse.addBreadcrumb('User triggered captureException demo',
        category: 'ui.action');
    try {
      throw FormatException('Simulated FormatException for demo');
    } catch (e, st) {
      Pulse.captureException(e, stackTrace: st);
      _log_('✅ captureException: FormatException sent');
    }
  }

  void _captureError() {
    Pulse.addBreadcrumb('User triggered captureError demo',
        category: 'ui.action');
    try {
      final list = <int>[];
      // ignore: avoid_print
      print(list[99]); // intentional RangeError
    } on Error catch (e, st) {
      Pulse.captureError(e, stackTrace: st);
      _log_('✅ captureError: RangeError sent');
    }
  }

  void _flutterError() {
    Pulse.addBreadcrumb('User triggered FlutterError demo',
        category: 'ui.action');
    FlutterError.reportError(FlutterErrorDetails(
      exception: Exception('Simulated Flutter framework error'),
      stack: StackTrace.current,
      library: 'pulse_example',
    ));
    _log_('✅ FlutterError.reportError called — check console');
  }

  void _unhandledAsync() {
    Pulse.addBreadcrumb('User triggered unhandled async error',
        category: 'ui.action');
    Future<void>.error(
      StateError('Simulated unhandled async error — auto-captured'),
      StackTrace.current,
    );
    _log_('✅ Unhandled async error fired — check console');
  }

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Error Capture',
      log: _log,
      actions: [
        _ActionButton('captureException()', Icons.bug_report, Colors.red,
            _captureException),
        _ActionButton(
            'captureError()', Icons.warning, Colors.orange, _captureError),
        _ActionButton(
            'FlutterError', Icons.phone_android, Colors.pink, _flutterError),
        _ActionButton(
            'Unhandled Async', Icons.bolt, Colors.deepOrange, _unhandledAsync),
      ],
    );
  }
}

// ── Breadcrumb screen ─────────────────────────────────────────────────────────

class _BreadcrumbScreen extends StatefulWidget {
  const _BreadcrumbScreen();
  @override
  State<_BreadcrumbScreen> createState() => _BreadcrumbScreenState();
}

class _BreadcrumbScreenState extends State<_BreadcrumbScreen> {
  final List<String> _log = [];
  int _count = 0;

  void _log_(String msg) => setState(() => _log.insert(0, msg));

  void _addNav() {
    _count++;
    Pulse.addBreadcrumb(
      'Navigated to Screen #$_count',
      category: 'navigation',
      data: {'from': 'BreadcrumbScreen', 'to': 'Screen#$_count'},
    );
    _log_('✅ navigation breadcrumb #$_count');
  }

  void _addUiAction() {
    Pulse.addBreadcrumb(
      'Button tapped',
      category: 'ui.action',
      level: BreadcrumbLevel.info,
      data: {
        'button_id': 'demo_action_${DateTime.now().millisecondsSinceEpoch}'
      },
    );
    _log_('✅ ui.action breadcrumb');
  }

  void _addWarning() {
    Pulse.addBreadcrumb(
      'Cache miss for user profile',
      category: 'cache',
      level: BreadcrumbLevel.warning,
      data: {'key': 'user_profile_42'},
    );
    _log_('✅ warning breadcrumb');
  }

  void _triggerAfterBreadcrumbs() {
    try {
      throw StateError(
          'Error after breadcrumbs — see breadcrumb trail in event');
    } catch (e, st) {
      Pulse.captureException(e, stackTrace: st);
      _log_('✅ Exception sent with ${_count + 2} breadcrumbs attached');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Breadcrumbs',
      log: _log,
      actions: [
        _ActionButton('Navigation', Icons.route, Colors.blue, _addNav),
        _ActionButton(
            'UI Action', Icons.touch_app, Colors.purple, _addUiAction),
        _ActionButton(
            'Warning', Icons.warning_amber, Colors.orange, _addWarning),
        _ActionButton('Capture with Trail', Icons.send, Colors.red,
            _triggerAfterBreadcrumbs),
      ],
    );
  }
}

// ── Custom event screen ───────────────────────────────────────────────────────

class _CustomEventScreen extends StatefulWidget {
  const _CustomEventScreen();
  @override
  State<_CustomEventScreen> createState() => _CustomEventScreenState();
}

class _CustomEventScreenState extends State<_CustomEventScreen> {
  final List<String> _log = [];

  void _log_(String msg) => setState(() => _log.insert(0, msg));

  void _trackPurchase() {
    Pulse.track('purchase_completed', properties: {
      'amount': 99.99,
      'currency': 'USD',
      'payment_method': 'card',
      'items': 3,
    });
    _log_('✅ track: purchase_completed');
  }

  void _trackOnboarding() {
    Pulse.track('onboarding_step_completed', properties: {
      'step': 'profile_setup',
      'step_number': 2,
      'duration_seconds': 45,
      'skipped': false,
    });
    _log_('✅ track: onboarding_step_completed');
  }

  void _trackSearch() {
    Pulse.track('search_performed', properties: {
      'query_length': 12,
      'results_count': 42,
      'category': 'products',
      'has_filters': true,
    });
    _log_('✅ track: search_performed');
  }

  void _trackFeatureFlag() {
    Pulse.track('feature_flag_evaluated', properties: {
      'flag_key': 'new_checkout_flow',
      'value': true,
      'source': 'remote_config',
    });
    _log_('✅ track: feature_flag_evaluated');
  }

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Custom Events',
      log: _log,
      actions: [
        _ActionButton(
            'Purchase', Icons.shopping_cart, Colors.green, _trackPurchase),
        _ActionButton(
            'Onboarding', Icons.person_add, Colors.blue, _trackOnboarding),
        _ActionButton('Search', Icons.search, Colors.purple, _trackSearch),
        _ActionButton(
            'Feature Flag', Icons.flag, Colors.orange, _trackFeatureFlag),
      ],
    );
  }
}

// ── Network screen ────────────────────────────────────────────────────────────

class _NetworkScreen extends StatefulWidget {
  const _NetworkScreen();
  @override
  State<_NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<_NetworkScreen> {
  final List<String> _log = [];

  // Monitored HTTP clients
  final http.Client _httpClient = Pulse.network != null
      ? PulseHttpClient(http.Client(), observer: Pulse.network!)
      : http.Client();

  final Dio _dio = Dio();

  void _log_(String msg) => setState(() => _log.insert(0, msg));

  @override
  void initState() {
    super.initState();
    if (Pulse.network != null) {
      _dio.interceptors.add(PulseDioInterceptor(observer: Pulse.network!));
    }
  }

  Future<void> _httpGet() async {
    _log_('⏳ GET via PulseHttpClient…');
    try {
      final response = await _httpClient.get(
        Uri.parse('https://jsonplaceholder.typicode.com/todos/1'),
      );
      _log_('✅ HTTP ${response.statusCode} — ${response.body.length} bytes');
    } catch (e) {
      _log_('❌ Error: $e');
    }
  }

  Future<void> _httpPost() async {
    _log_('⏳ POST via PulseHttpClient…');
    try {
      final response = await _httpClient.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json'},
        body: '{"title": "pulse demo", "body": "test", "userId": 1}',
      );
      _log_('✅ HTTP ${response.statusCode} — POST response received');
    } catch (e) {
      _log_('❌ Error: $e');
    }
  }

  Future<void> _dioGet() async {
    _log_('⏳ GET via PulseDioInterceptor…');
    try {
      final response = await _dio.get<dynamic>(
        'https://jsonplaceholder.typicode.com/users/1',
      );
      _log_('✅ Dio ${response.statusCode} — user data fetched');
    } catch (e) {
      _log_('❌ Error: $e');
    }
  }

  Future<void> _dioError() async {
    _log_('⏳ Triggering 404 via Dio…');
    try {
      await _dio.get<dynamic>(
          'https://jsonplaceholder.typicode.com/nonexistent/99999');
    } on DioException catch (e) {
      _log_('✅ Dio captured 404: ${e.response?.statusCode}');
    } catch (e) {
      _log_('❌ Error: $e');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Network Monitoring',
      log: _log,
      actions: [
        _ActionButton('http GET', Icons.download, Colors.blue, _httpGet),
        _ActionButton('http POST', Icons.upload, Colors.indigo, _httpPost),
        _ActionButton('Dio GET', Icons.cloud_download, Colors.purple, _dioGet),
        _ActionButton('Dio 404', Icons.cloud_off, Colors.red, _dioError),
      ],
    );
  }
}

// ── Performance screen ────────────────────────────────────────────────────────

class _PerformanceScreen extends StatefulWidget {
  const _PerformanceScreen();
  @override
  State<_PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<_PerformanceScreen> {
  final List<String> _log = [];

  void _log_(String msg) => setState(() => _log.insert(0, msg));

  Future<void> _fastTransaction() async {
    _log_('⏳ Starting fast transaction…');
    final tx = Pulse.startTransaction('fast_operation');
    try {
      final span = tx.startSpan('compute');
      await Future<void>.delayed(const Duration(milliseconds: 120));
      span.finish();
      tx.finish(status: 'ok');
      _log_('✅ fast_operation finished (ok)');
    } catch (e) {
      tx.finish(status: 'error', error: e);
    }
  }

  Future<void> _multiSpanTransaction() async {
    _log_('⏳ Starting multi-span transaction…');
    final tx = Pulse.startTransaction('dashboard_load');
    try {
      final s1 = tx.startSpan('fetch_user');
      await Future<void>.delayed(const Duration(milliseconds: 80));
      s1.finish();

      final s2 = tx.startSpan('fetch_feed');
      await Future<void>.delayed(const Duration(milliseconds: 150));
      s2.finish();

      final s3 = tx.startSpan('render');
      await Future<void>.delayed(const Duration(milliseconds: 30));
      s3.finish();

      tx.finish(status: 'ok');
      _log_('✅ dashboard_load (3 spans) finished');
    } catch (e) {
      tx.finish(status: 'error', error: e);
    }
  }

  Future<void> _slowTransaction() async {
    _log_('⏳ Starting slow transaction (triggers slow-op detection)…');
    final tx = Pulse.startTransaction('slow_report_generation');
    try {
      final span = tx.startSpan('heavy_computation');
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      span.finish();
      tx.finish(status: 'ok');
      _log_('✅ slow_report_generation finished (slow op detected)');
    } catch (e) {
      tx.finish(status: 'error', error: e);
    }
  }

  Future<void> _errorTransaction() async {
    _log_('⏳ Starting transaction that will fail…');
    final tx = Pulse.startTransaction('failing_import');
    try {
      final span = tx.startSpan('parse_data');
      await Future<void>.delayed(const Duration(milliseconds: 60));
      span.finish();
      throw FormatException('Malformed CSV data at row 42');
    } catch (e, st) {
      tx.finish(status: 'error', error: e);
      Pulse.captureException(e, stackTrace: st);
      _log_('✅ failing_import finished (error) + exception captured');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Performance',
      log: _log,
      actions: [
        _ActionButton(
            'Fast (1 span)', Icons.flash_on, Colors.green, _fastTransaction),
        _ActionButton('Multi-span (3)', Icons.account_tree, Colors.blue,
            _multiSpanTransaction),
        _ActionButton('Slow (2.5s)', Icons.hourglass_bottom, Colors.orange,
            _slowTransaction),
        _ActionButton('Error tx', Icons.close, Colors.red, _errorTransaction),
      ],
    );
  }
}

// ── Sanitization screen ───────────────────────────────────────────────────────

class _SanitizationScreen extends StatefulWidget {
  const _SanitizationScreen();
  @override
  State<_SanitizationScreen> createState() => _SanitizationScreenState();
}

class _SanitizationScreenState extends State<_SanitizationScreen> {
  final List<String> _log = [];

  void _log_(String msg) => setState(() => _log.insert(0, msg));

  void _sendWithSensitiveData() {
    Pulse.track('user_updated', properties: {
      'username': 'john_doe', // safe — NOT redacted
      'email': 'john@example.com', // safe — NOT redacted by default
      'password': 's3cr3t!', // REDACTED ← sensitive key
      'token': 'eyJhbGciOiJSUzI1NiJ9', // REDACTED ← sensitive key
      'api_key': 'sk_live_abc123', // REDACTED ← sensitive key
      'authorization': 'Bearer xyz', // REDACTED ← sensitive key
      'preferences': {
        'theme': 'dark',
        'secret': 'internal_value', // REDACTED ← nested sensitive key
      },
    });
    _log_('✅ Sent — sensitive fields automatically redacted in pipeline');
    _log_('   Check console: password/token/api_key/secret → "[REDACTED]"');
  }

  void _sendNestedSensitiveData() {
    Pulse.track('api_response_logged', properties: {
      'response': {
        'status': 200,
        'headers': {
          'content-type': 'application/json',
          'set-cookie': 'session=abc123', // REDACTED ← 'cookie' pattern
        },
        'body': {
          'user': {
            'id': 42,
            'access_token': 'tok_xyz', // REDACTED ← nested sensitive key
            'name': 'Jane', // safe
          },
        },
      },
    });
    _log_('✅ Nested data sent — recursive sanitization applied');
    _log_('   access_token + set-cookie → "[REDACTED]"');
  }

  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      title: 'Sanitization Demo',
      log: _log,
      actions: [
        _ActionButton('Send with PII', Icons.security, Colors.teal,
            _sendWithSensitiveData),
        _ActionButton('Nested Sensitive', Icons.layers, Colors.cyan,
            _sendNestedSensitiveData),
      ],
      hint: 'Sensitive keys (password, token, api_key, cookie, etc.) are '
          'automatically redacted before reaching the transport layer.',
    );
  }
}

// ── Shared UI helpers ─────────────────────────────────────────────────────────

class _DemoScaffold extends StatelessWidget {
  final String title;
  final List<String> log;
  final List<_ActionButton> actions;
  final String? hint;

  const _DemoScaffold({
    required this.title,
    required this.log,
    required this.actions,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          if (hint != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.greenAccent.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.greenAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hint!,
                      style: const TextStyle(
                          color: Colors.greenAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: log.isEmpty
                ? const Center(
                    child: Text(
                      'Tap a button above to send events.\nCheck the Flutter console for full event JSON.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    reverse: false,
                    padding: const EdgeInsets.all(12),
                    itemCount: log.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        log[i],
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 13),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton(this.label, this.icon, this.color, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color.withAlpha(30),
        foregroundColor: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}
