import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_example/main.dart';

void main() {
  testWidgets('PulseExampleApp builds without error', (tester) async {
    await tester.pumpWidget(const PulseExampleApp());
    expect(find.text('Pulse SDK Demo'), findsOneWidget);
  });
}
