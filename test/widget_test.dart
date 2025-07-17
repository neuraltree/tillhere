// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:tillhere/main.dart';
import 'package:tillhere/core/injection/dependency_injection.dart';

void main() {
  setUpAll(() {
    // Initialize Flutter binding for testing
    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize FFI for testing (required for SQLite in tests)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Initialize timezone data for tests
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York'));
  });

  setUp(() {
    // Initialize dependency injection before each test
    DependencyInjection.initialize();
  });

  tearDown(() {
    // Clean up dependency injection after each test
    DependencyInjection.dispose();
  });

  testWidgets('App launches and shows home page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TillHereApp());

    // Pump a few frames to allow initial rendering
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that the app bar is present with correct title
    expect(find.text('Home'), findsOneWidget);

    // Verify that the drawer menu button is present
    expect(find.byIcon(Icons.menu), findsOneWidget);

    // The app should show either loading state or content
    // Let's check for basic structure first
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
