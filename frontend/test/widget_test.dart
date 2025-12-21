// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gemini_photography_agent/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This might fail in CI if it requires camera initialized, 
    // but for analysis purposes, the class name must exist.
    await tester.pumpWidget(const GeminiPhotographyApp());

    // Verify that the app starts.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
