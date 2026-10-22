import 'package:flutter_test/flutter_test.dart';
import 'package:agricare/main.dart';

void main() {
  testWidgets('AgriCare app smoke test', (WidgetTester tester) async {
    // Build AgriCareApp and trigger a frame.
    await tester.pumpWidget(const AgriCareApp());

    // Verify that AgriCare header title is present on the splash screen.
    expect(find.text('AgriCare'), findsWidgets);

    // Let the splash screen's navigation timer fire so no timer is left
    // pending when the widget tree is torn down.
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.text('AgriCare'), findsWidgets);
  });
}
