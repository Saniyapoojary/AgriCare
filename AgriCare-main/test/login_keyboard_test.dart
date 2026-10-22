import 'package:agricare/screens/auth/login_screen.dart';
import 'package:agricare/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Regression tests for the login flow's keyboard types.
///
/// The three steps each render a TextField as the first widget in the same
/// list position, so without distinct keys Flutter reuses one element across
/// steps and the name field inherits the numeric keypad from the OTP step.
void main() {
  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  TextField fieldByKey(WidgetTester tester, String key) =>
      tester.widget<TextField>(find.byKey(ValueKey(key)));

  Future<void> advanceToRegisterStep(WidgetTester tester) async {
    await tester.enterText(find.byKey(const ValueKey('field-phone')), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('field-otp')), '1234');
    await tester.tap(find.text('Verify & Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets('name field uses an alphabetic keyboard, not the numeric keypad',
      (tester) async {
    await pumpLogin(tester);
    await advanceToRegisterStep(tester);

    final nameField = fieldByKey(tester, 'field-name');

    expect(nameField.keyboardType, TextInputType.name);
    expect(nameField.keyboardType, isNot(TextInputType.number));
    expect(nameField.keyboardType, isNot(TextInputType.phone));
    expect(nameField.textCapitalization, TextCapitalization.words);
  });

  testWidgets('each step renders a distinctly keyed field so elements are not reused',
      (tester) async {
    await pumpLogin(tester);

    // Phone step.
    expect(find.byKey(const ValueKey('field-phone')), findsOneWidget);
    expect(fieldByKey(tester, 'field-phone').keyboardType, TextInputType.phone);

    await tester.enterText(find.byKey(const ValueKey('field-phone')), '9876543210');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();

    // OTP step replaces, rather than reuses, the phone field.
    expect(find.byKey(const ValueKey('field-phone')), findsNothing);
    expect(fieldByKey(tester, 'field-otp').keyboardType, TextInputType.number);

    await tester.enterText(find.byKey(const ValueKey('field-otp')), '1234');
    await tester.tap(find.text('Verify & Continue'));
    await tester.pumpAndSettle();

    // Register step replaces the OTP field.
    expect(find.byKey(const ValueKey('field-otp')), findsNothing);
    expect(find.byKey(const ValueKey('field-name')), findsOneWidget);
  });

  testWidgets('worker daily rate field still uses a numeric keyboard', (tester) async {
    await pumpLogin(tester);
    await advanceToRegisterStep(tester);

    await tester.tap(find.text('Spray Worker'));
    await tester.pumpAndSettle();

    expect(fieldByKey(tester, 'field-rate').keyboardType, TextInputType.number);
  });
}
