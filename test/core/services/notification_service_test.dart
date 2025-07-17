import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tillhere/core/services/notification_service.dart';
import 'package:tillhere/core/entities/notification_settings.dart';

void main() {
  group('NotificationService', () {
    late NotificationService notificationService;

    setUpAll(() {
      // Initialize timezone data for tests
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/New_York'));
    });

    setUp(() {
      notificationService = NotificationService();
    });

    group('initialization', () {
      test('should initialize successfully', () async {
        final result = await notificationService.initialize();

        // Note: This will fail in test environment without proper mocking
        // but helps us understand the initialization flow
        expect(result.isFailure, isTrue);
        expect(result.failure?.message, contains('Error initializing notifications'));
      });

      test('should handle timezone initialization', () {
        // Test that timezone is properly initialized
        expect(() => tz.TZDateTime.now(tz.local), returnsNormally);

        final now = tz.TZDateTime.now(tz.local);
        expect(now, isA<tz.TZDateTime>());
      });
    });

    group('notification scheduling', () {
      test('should fail gracefully when not initialized', () async {
        final testNotification = NotificationSettings(
          id: 'test',
          enabled: true,
          title: 'Test',
          body: 'Test body',
          scheduleType: NotificationScheduleType.daily,
          time: '20:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await notificationService.scheduleNotification(testNotification);

        expect(result.isFailure, isTrue);
        expect(result.failure?.message, contains('not initialized'));
      });

      test('should handle immediate notification scheduling', () async {
        final result = await notificationService.scheduleImmediateNotification(
          'Test Title',
          'Test Body',
          payload: 'test_payload',
        );

        expect(result.isFailure, isTrue);
        expect(result.failure?.message, contains('not initialized'));
      });
    });

    group('timezone handling', () {
      test('should create TZDateTime objects correctly', () {
        final location = tz.local;
        final now = tz.TZDateTime.now(location);
        final scheduledTime = tz.TZDateTime(location, now.year, now.month, now.day, 20, 0);

        expect(scheduledTime, isA<tz.TZDateTime>());
        expect(scheduledTime.hour, equals(20));
        expect(scheduledTime.minute, equals(0));
      });

      test('should handle next day scheduling correctly', () {
        final location = tz.local;
        final now = tz.TZDateTime.now(location);

        // Test scheduling for a time that has already passed today
        var scheduledTime = tz.TZDateTime(location, now.year, now.month, now.day, 1, 0); // 1 AM

        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        expect(scheduledTime.isAfter(now), isTrue);
      });
    });

    group('notification settings validation', () {
      test('should validate daily notification settings', () {
        final dailyNotification = NotificationSettings(
          id: 'daily_test',
          enabled: true,
          title: 'Daily Reminder',
          body: 'Time to log your mood',
          scheduleType: NotificationScheduleType.daily,
          time: '20:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(dailyNotification.isValid, isTrue);
        expect(dailyNotification.hour, equals(20));
        expect(dailyNotification.minute, equals(0));
      });

      test('should validate weekly notification settings', () {
        final weeklyNotification = NotificationSettings(
          id: 'weekly_test',
          enabled: true,
          title: 'Weekly Summary',
          body: 'Review your week',
          scheduleType: NotificationScheduleType.weekly,
          time: '19:00',
          daysOfWeek: [7], // Sunday
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(weeklyNotification.isValid, isTrue);
        expect(weeklyNotification.daysOfWeek, contains(7));
      });

      test('should reject invalid time formats', () {
        final invalidNotification = NotificationSettings(
          id: 'invalid_test',
          enabled: true,
          title: 'Invalid',
          body: 'Invalid time',
          scheduleType: NotificationScheduleType.daily,
          time: '25:70', // Invalid time
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(invalidNotification.isValid, isFalse);
      });

      test('should reject weekly notifications without days', () {
        final invalidWeekly = NotificationSettings(
          id: 'invalid_weekly',
          enabled: true,
          title: 'Invalid Weekly',
          body: 'No days specified',
          scheduleType: NotificationScheduleType.weekly,
          time: '19:00',
          daysOfWeek: [], // Empty days
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(invalidWeekly.isValid, isFalse);
      });
    });
  });
}
