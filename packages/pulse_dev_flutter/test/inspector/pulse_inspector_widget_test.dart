import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_dev_flutter/pulse_dev_flutter.dart';
import 'package:pulse_dev_flutter/src/inspector/inspector_state.dart';

void main() {
  setUp(() {
    InspectorState.instance.clear();
  });

  testWidgets('PulseInspector wraps child and renders floating button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: PulseInspector.builder(),
        home: const Scaffold(body: Text('Hello App')),
      ),
    );

    expect(find.text('Hello App'), findsOneWidget);

    // Floating button should be rendered because kReleaseMode is false in tests
    expect(find.byIcon(Icons.monitor_heart), findsOneWidget);
  });

  testWidgets('PulseInspector opens bottom sheet on tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: PulseInspector.builder(),
        home: const Scaffold(body: Text('Hello App')),
      ),
    );

    await tester.tap(find.byIcon(Icons.monitor_heart));
    await tester.pumpAndSettle();

    expect(find.text('Pulse Inspector'), findsOneWidget);
    expect(find.text('Errors'), findsOneWidget);
    expect(find.text('Network'), findsOneWidget);
  });

  testWidgets('PulseInspector respects enabled flag',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: PulseInspector.builder(enabled: false),
        home: const Scaffold(body: Text('Hello App')),
      ),
    );

    expect(find.text('Hello App'), findsOneWidget);
    expect(find.byIcon(Icons.monitor_heart), findsNothing);
  });
}
