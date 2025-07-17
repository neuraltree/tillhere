import 'package:sqflite/sqflite.dart';

import '../../core/entities/notification_settings.dart';
import '../../core/repositories/notification_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../datasources/local/database_helper.dart';
import '../models/notification_settings_model.dart';

/// Concrete implementation of NotificationRepository using SQLite
/// Handles all notification settings-related database operations
class NotificationRepositoryImpl implements NotificationRepository {
  final DatabaseHelper _databaseHelper;

  NotificationRepositoryImpl(this._databaseHelper);

  @override
  Future<Result<NotificationSettings>> createNotificationSetting(NotificationSettings settings) async {
    try {
      final db = await _databaseHelper.database;
      final model = NotificationSettingsModel.fromEntity(settings);

      await db.insert(
        DatabaseHelper.tableNotificationSettings,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );

      return Result.success(settings);
    } catch (e) {
      if (e is DatabaseException && e.isUniqueConstraintError()) {
        return Result.failure(ValidationFailure('Notification setting with ID ${settings.id} already exists'));
      }
      return Result.failure(DatabaseFailure('Failed to create notification setting: $e'));
    }
  }

  @override
  Future<Result<NotificationSettings?>> getNotificationSetting(String id) async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableNotificationSettings,
        where: '${DatabaseHelper.columnNotificationId} = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (results.isEmpty) {
        return Result.success(null);
      }

      final model = NotificationSettingsModel.fromMap(results.first);
      return Result.success(model.toEntity());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get notification setting: $e'));
    }
  }

  @override
  Future<Result<List<NotificationSettings>>> getAllNotificationSettings() async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableNotificationSettings,
        orderBy: '${DatabaseHelper.columnNotificationCreatedAt} DESC',
      );

      final settings = results
          .map((map) => NotificationSettingsModel.fromMap(map).toEntity())
          .toList();

      return Result.success(settings);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get all notification settings: $e'));
    }
  }

  @override
  Future<Result<List<NotificationSettings>>> getEnabledNotificationSettings() async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableNotificationSettings,
        where: '${DatabaseHelper.columnNotificationEnabled} = ?',
        whereArgs: [1],
        orderBy: '${DatabaseHelper.columnNotificationCreatedAt} DESC',
      );

      final settings = results
          .map((map) => NotificationSettingsModel.fromMap(map).toEntity())
          .toList();

      return Result.success(settings);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get enabled notification settings: $e'));
    }
  }

  @override
  Future<Result<NotificationSettings>> updateNotificationSetting(NotificationSettings settings) async {
    try {
      final db = await _databaseHelper.database;
      final model = NotificationSettingsModel.fromEntity(settings);

      final rowsAffected = await db.update(
        DatabaseHelper.tableNotificationSettings,
        model.toMap(),
        where: '${DatabaseHelper.columnNotificationId} = ?',
        whereArgs: [settings.id],
      );

      if (rowsAffected == 0) {
        return Result.failure(ValidationFailure('Notification setting with ID ${settings.id} not found'));
      }

      return Result.success(settings);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update notification setting: $e'));
    }
  }

  @override
  Future<Result<void>> deleteNotificationSetting(String id) async {
    try {
      final db = await _databaseHelper.database;

      final rowsAffected = await db.delete(
        DatabaseHelper.tableNotificationSettings,
        where: '${DatabaseHelper.columnNotificationId} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        return Result.failure(ValidationFailure('Notification setting with ID $id not found'));
      }

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete notification setting: $e'));
    }
  }

  @override
  Future<Result<void>> deleteAllNotificationSettings() async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(DatabaseHelper.tableNotificationSettings);

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete all notification settings: $e'));
    }
  }

  @override
  Future<Result<NotificationSettings>> setNotificationEnabled(String id, bool enabled) async {
    try {
      final db = await _databaseHelper.database;

      final rowsAffected = await db.update(
        DatabaseHelper.tableNotificationSettings,
        {
          DatabaseHelper.columnNotificationEnabled: enabled ? 1 : 0,
          DatabaseHelper.columnNotificationUpdatedAt: DateTime.now().millisecondsSinceEpoch,
        },
        where: '${DatabaseHelper.columnNotificationId} = ?',
        whereArgs: [id],
      );

      if (rowsAffected == 0) {
        return Result.failure(ValidationFailure('Notification setting with ID $id not found'));
      }

      // Get the updated setting
      final getResult = await getNotificationSetting(id);
      if (getResult.isFailure) {
        return Result.failure(getResult.failure!);
      }

      return Result.success(getResult.data!);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to set notification enabled status: $e'));
    }
  }

  @override
  Future<Result<List<NotificationSettings>>> getNotificationsByScheduleType(
    NotificationScheduleType scheduleType,
  ) async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableNotificationSettings,
        where: '${DatabaseHelper.columnNotificationScheduleType} = ?',
        whereArgs: [scheduleType.toString()],
        orderBy: '${DatabaseHelper.columnNotificationCreatedAt} DESC',
      );

      final settings = results
          .map((map) => NotificationSettingsModel.fromMap(map).toEntity())
          .toList();

      return Result.success(settings);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get notifications by schedule type: $e'));
    }
  }

  @override
  Future<Result<bool>> hasEnabledNotifications() async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableNotificationSettings,
        columns: ['COUNT(*) as count'],
        where: '${DatabaseHelper.columnNotificationEnabled} = ?',
        whereArgs: [1],
      );

      final count = results.first['count'] as int;
      return Result.success(count > 0);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to check for enabled notifications: $e'));
    }
  }

  @override
  Future<Result<int>> getNotificationCount() async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableNotificationSettings,
        columns: ['COUNT(*) as count'],
      );

      final count = results.first['count'] as int;
      return Result.success(count);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get notification count: $e'));
    }
  }

  @override
  Future<Result<int>> getEnabledNotificationCount() async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableNotificationSettings,
        columns: ['COUNT(*) as count'],
        where: '${DatabaseHelper.columnNotificationEnabled} = ?',
        whereArgs: [1],
      );

      final count = results.first['count'] as int;
      return Result.success(count);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get enabled notification count: $e'));
    }
  }
}
