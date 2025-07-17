import '../entities/notification_settings.dart';
import '../utils/result.dart';

/// Repository interface for notification settings management
/// Defines the contract for notification data operations
abstract class NotificationRepository {
  /// Creates a new notification setting
  /// 
  /// [settings] - The NotificationSettings to create
  /// 
  /// Returns a Result containing the created NotificationSettings or a Failure
  Future<Result<NotificationSettings>> createNotificationSetting(NotificationSettings settings);

  /// Gets a notification setting by ID
  /// 
  /// [id] - The notification setting ID
  /// 
  /// Returns a Result containing NotificationSettings or a Failure
  Future<Result<NotificationSettings?>> getNotificationSetting(String id);

  /// Gets all notification settings
  /// 
  /// Returns a Result containing a list of all NotificationSettings or a Failure
  Future<Result<List<NotificationSettings>>> getAllNotificationSettings();

  /// Gets all enabled notification settings
  /// 
  /// Returns a Result containing a list of enabled NotificationSettings or a Failure
  Future<Result<List<NotificationSettings>>> getEnabledNotificationSettings();

  /// Updates an existing notification setting
  /// 
  /// [settings] - The NotificationSettings to update
  /// 
  /// Returns a Result containing the updated NotificationSettings or a Failure
  Future<Result<NotificationSettings>> updateNotificationSetting(NotificationSettings settings);

  /// Deletes a notification setting by ID
  /// 
  /// [id] - The notification setting ID to delete
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> deleteNotificationSetting(String id);

  /// Deletes all notification settings
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> deleteAllNotificationSettings();

  /// Enables or disables a notification setting
  /// 
  /// [id] - The notification setting ID
  /// [enabled] - Whether to enable or disable the notification
  /// 
  /// Returns a Result containing the updated NotificationSettings or a Failure
  Future<Result<NotificationSettings>> setNotificationEnabled(String id, bool enabled);

  /// Gets notification settings by schedule type
  /// 
  /// [scheduleType] - The schedule type to filter by
  /// 
  /// Returns a Result containing a list of matching NotificationSettings or a Failure
  Future<Result<List<NotificationSettings>>> getNotificationsByScheduleType(
    NotificationScheduleType scheduleType,
  );

  /// Checks if any notifications are enabled
  /// 
  /// Returns a Result containing true if any notifications are enabled, false otherwise
  Future<Result<bool>> hasEnabledNotifications();

  /// Gets the count of notification settings
  /// 
  /// Returns a Result containing the total count of notification settings
  Future<Result<int>> getNotificationCount();

  /// Gets the count of enabled notification settings
  /// 
  /// Returns a Result containing the count of enabled notification settings
  Future<Result<int>> getEnabledNotificationCount();
}
