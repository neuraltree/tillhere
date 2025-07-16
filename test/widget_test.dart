// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tillhere/main.dart';

void main() {
  testWidgets('App launches and shows home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TillHereApp());

    // Verify that the app launches and shows the home page
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('How are you feeling today?'), findsOneWidget);

    // Verify that the app bar is present
    expect(find.text('Home'), findsOneWidget);

    // Verify that the drawer menu button is present
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });
}
