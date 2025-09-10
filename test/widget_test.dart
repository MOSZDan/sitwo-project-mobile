import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dental_clinic_mobile/main.dart';

void main() {
  testWidgets('Dental Clinic app should build', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app builds successfully
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Bienvenido a Dental Clinic'), findsOneWidget);
  });
}
