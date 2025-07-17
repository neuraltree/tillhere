import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../entities/notification_settings.dart';
import '../utils/result.dart';
import '../errors/failures.dart';
import 'deep_linking_service.dart';

/// Service for managing local notifications
/// Handles scheduling, cancellation, and deep linking for mood tracking reminders
class NotificationService {
  static const String _channelId = 'mood_reminders';
  static const String _channelName = 'Mood Reminders';
  static const String _channelDescription = 'Daily reminders to log your mood';

  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  NotificationService() : _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  /// Must be called before using any other methods
  Future<Result<bool>> initialize() async {
    try {
      // Ensure timezone is initialized
      if (!_isTimezoneInitialized()) {
        return Result.failure(NotificationFailure('Timezone not initialized. Call tz.initializeTimeZones() first.'));
      }

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      final initialized = await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        await _createNotificationChannel();
        _isInitialized = true;
        return Result.success(true);
      } else {
        return Result.failure(NotificationFailure('Failed to initialize notifications'));
      }
    } catch (e) {
      return Result.failure(NotificationFailure('Error initializing notifications: $e'));
    }
  }

  /// Check if timezone is properly initialized
  bool _isTimezoneInitialized() {
    try {
      tz.TZDateTime.now(tz.local);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    // Handle deep linking through the deep linking service
    final deepLinkingService = DeepLinkingService();
    deepLinkingService.handleDeepLink(response.payload);
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
      );

      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  /// Request notification permissions
  Future<Result<bool>> requestPermissions() async {
    if (!_isInitialized) {
      return Result.failure(NotificationFailure('Notification service not initialized'));
    }

    try {
      if (Platform.isIOS) {
        final granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
        return Result.success(granted ?? false);
      } else if (Platform.isAndroid) {
        final granted = await _notificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        return Result.success(granted ?? false);
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure(NotificationFailure('Error requesting permissions: $e'));
    }
  }

  /// Schedule a notification based on notification settings
  Future<Result<void>> scheduleNotification(NotificationSettings settings) async {
    if (!_isInitialized) {
      return Result.failure(NotificationFailure('Notification service not initialized'));
    }

    if (!settings.enabled) {
      return Result.success(null);
    }

    try {
      // Cancel existing notifications for this setting
      await cancelNotification(settings.id);

      switch (settings.scheduleType) {
        case NotificationScheduleType.daily:
          await _scheduleDailyNotification(settings);
          break;
        case NotificationScheduleType.weekly:
          await _scheduleWeeklyNotification(settings);
          break;
        case NotificationScheduleType.custom:
          // Custom scheduling logic can be added here
          return Result.failure(NotificationFailure('Custom scheduling not yet implemented'));
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure('Error scheduling notification: $e'));
    }
  }

  /// Schedule a daily notification
  Future<void> _scheduleDailyNotification(NotificationSettings settings) async {
    final notificationDetails = _buildNotificationDetails();

    await _notificationsPlugin.zonedSchedule(
      settings.id.hashCode, // Use hash of ID as integer ID
      settings.title,
      settings.body,
      _getNextScheduledTZTime(settings.hour, settings.minute),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'mood_input', // Deep link payload
    );
  }

  /// Schedule weekly notifications
  Future<void> _scheduleWeeklyNotification(NotificationSettings settings) async {
    if (settings.daysOfWeek == null || settings.daysOfWeek!.isEmpty) {
      throw ArgumentError('Weekly notifications require days of week');
    }

    final notificationDetails = _buildNotificationDetails();

    for (final dayOfWeek in settings.daysOfWeek!) {
      await _notificationsPlugin.zonedSchedule(
        '${settings.id}_$dayOfWeek'.hashCode, // Unique ID for each day
        settings.title,
        settings.body,
        _getNextScheduledTZTimeForDay(settings.hour, settings.minute, dayOfWeek),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'mood_input',
      );
    }
  }

  /// Build notification details for both platforms
  NotificationDetails _buildNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
    );

    const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Get the next scheduled time for a daily notification
  tz.TZDateTime _getNextScheduledTZTime(int hour, int minute) {
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    var scheduledTime = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  /// Get the next scheduled time for a specific day of the week
  tz.TZDateTime _getNextScheduledTZTimeForDay(int hour, int minute, int dayOfWeek) {
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    var scheduledTime = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);

    // Adjust to the correct day of the week (1=Monday, 7=Sunday)
    final currentDayOfWeek = now.weekday;
    final daysUntilTarget = (dayOfWeek - currentDayOfWeek) % 7;

    scheduledTime = scheduledTime.add(Duration(days: daysUntilTarget));

    // If it's the same day but time has passed, schedule for next week
    if (daysUntilTarget == 0 && scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 7));
    }

    return scheduledTime;
  }

  /// Cancel a specific notification
  Future<Result<void>> cancelNotification(String settingsId) async {
    if (!_isInitialized) {
      return Result.failure(NotificationFailure('Notification service not initialized'));
    }

    try {
      // Cancel the main notification
      await _notificationsPlugin.cancel(settingsId.hashCode);

      // Cancel weekly notifications (if any)
      for (int day = 1; day <= 7; day++) {
        await _notificationsPlugin.cancel('${settingsId}_$day'.hashCode);
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure('Error canceling notification: $e'));
    }
  }

  /// Cancel all notifications
  Future<Result<void>> cancelAllNotifications() async {
    if (!_isInitialized) {
      return Result.failure(NotificationFailure('Notification service not initialized'));
    }

    try {
      await _notificationsPlugin.cancelAll();
      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure('Error canceling all notifications: $e'));
    }
  }

  /// Schedule an immediate test notification
  Future<Result<void>> scheduleImmediateNotification(String title, String body, {String? payload}) async {
    if (!_isInitialized) {
      return Result.failure(NotificationFailure('Notification service not initialized'));
    }

    try {
      final notificationDetails = _buildNotificationDetails();
      final location = tz.local;
      final now = tz.TZDateTime.now(location);
      final immediateTime = now.add(const Duration(seconds: 2)); // Schedule 2 seconds from now

      await _notificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch, // Unique ID based on timestamp
        title,
        body,
        immediateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload ?? 'mood_input',
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(NotificationFailure('Error scheduling immediate notification: $e'));
    }
  }

  /// Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) {
      return [];
    }

    return await _notificationsPlugin.pendingNotificationRequests();
  }
}
