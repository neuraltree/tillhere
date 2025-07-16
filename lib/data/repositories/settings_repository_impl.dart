import 'package:sqflite/sqflite.dart';

import '../../core/entities/user_settings.dart';
import '../../core/repositories/settings_repository.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';
import '../datasources/local/database_helper.dart';
import '../models/settings_model.dart';

/// Concrete implementation of SettingsRepository using SQLite
/// Handles all settings-related database operations
class SettingsRepositoryImpl implements SettingsRepository {
  final DatabaseHelper _databaseHelper;

  SettingsRepositoryImpl(this._databaseHelper);

  @override
  Future<Result<UserSettings>> getUserSettings() async {
    try {
      final db = await _databaseHelper.database;

      // Get all settings from the database
      final settingsMaps = await db.query(DatabaseHelper.tableSettings);

      // Convert to SettingsModel list
      final settingsModels = settingsMaps
          .map((map) => SettingsModel.fromMap(map))
          .toList();

      // Convert to UserSettings entity
      final userSettings = UserSettingsMapper.fromModels(settingsModels);

      return Result.success(userSettings);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get user settings: $e'));
    }
  }

  @override
  Future<Result<UserSettings>> updateUserSettings(UserSettings settings) async {
    try {
      final db = await _databaseHelper.database;

      // Convert UserSettings to SettingsModel list
      final settingsModels = UserSettingsMapper.toModels(settings);

      // Use transaction to ensure atomicity
      await db.transaction((txn) async {
        for (final model in settingsModels) {
          await txn.insert(
            DatabaseHelper.tableSettings,
            model.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });

      return Result.success(settings);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to update user settings: $e'));
    }
  }

  @override
  Future<Result<String?>> getSetting(String key) async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableSettings,
        where: '${DatabaseHelper.columnSettingsKey} = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (results.isEmpty) {
        return Result.success(null);
      }

      final model = SettingsModel.fromMap(results.first);
      return Result.success(model.stringValue);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get setting $key: $e'));
    }
  }

  @override
  Future<Result<void>> setSetting(String key, String? value) async {
    try {
      final db = await _databaseHelper.database;
      final model = SettingsModel.string(key, value);

      await db.insert(
        DatabaseHelper.tableSettings,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to set setting $key: $e'));
    }
  }

  @override
  Future<Result<bool>> getBoolSetting(String key, {bool defaultValue = false}) async {
    try {
      final result = await getSetting(key);
      if (result.isFailure) {
        return Result.failure(result.failure!);
      }

      final value = result.data;
      if (value == null) {
        return Result.success(defaultValue);
      }

      return Result.success(value.toLowerCase() == 'true');
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get bool setting $key: $e'));
    }
  }

  @override
  Future<Result<void>> setBoolSetting(String key, bool value) async {
    try {
      final db = await _databaseHelper.database;
      final model = SettingsModel.boolean(key, value);

      await db.insert(
        DatabaseHelper.tableSettings,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to set bool setting $key: $e'));
    }
  }

  @override
  Future<Result<int?>> getIntSetting(String key, {int? defaultValue}) async {
    try {
      final result = await getSetting(key);
      if (result.isFailure) {
        return Result.failure(result.failure!);
      }

      final value = result.data;
      if (value == null) {
        return Result.success(defaultValue);
      }

      final intValue = int.tryParse(value);
      return Result.success(intValue ?? defaultValue);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get int setting $key: $e'));
    }
  }

  @override
  Future<Result<void>> setIntSetting(String key, int? value) async {
    try {
      final db = await _databaseHelper.database;
      final model = SettingsModel.integer(key, value);

      await db.insert(
        DatabaseHelper.tableSettings,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to set int setting $key: $e'));
    }
  }

  @override
  Future<Result<double?>> getDoubleSetting(String key, {double? defaultValue}) async {
    try {
      final result = await getSetting(key);
      if (result.isFailure) {
        return Result.failure(result.failure!);
      }

      final value = result.data;
      if (value == null) {
        return Result.success(defaultValue);
      }

      final doubleValue = double.tryParse(value);
      return Result.success(doubleValue ?? defaultValue);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get double setting $key: $e'));
    }
  }

  @override
  Future<Result<void>> setDoubleSetting(String key, double? value) async {
    try {
      final db = await _databaseHelper.database;
      final model = SettingsModel.double(key, value);

      await db.insert(
        DatabaseHelper.tableSettings,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to set double setting $key: $e'));
    }
  }

  @override
  Future<Result<DateTime?>> getDateTimeSetting(String key, {DateTime? defaultValue}) async {
    try {
      final result = await getSetting(key);
      if (result.isFailure) {
        return Result.failure(result.failure!);
      }

      final value = result.data;
      if (value == null) {
        return Result.success(defaultValue);
      }

      final dateTimeValue = DateTime.tryParse(value);
      return Result.success(dateTimeValue ?? defaultValue);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get datetime setting $key: $e'));
    }
  }

  @override
  Future<Result<void>> setDateTimeSetting(String key, DateTime? value) async {
    try {
      final db = await _databaseHelper.database;
      final model = SettingsModel.dateTime(key, value);

      await db.insert(
        DatabaseHelper.tableSettings,
        model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to set datetime setting $key: $e'));
    }
  }

  @override
  Future<Result<void>> deleteSetting(String key) async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(
        DatabaseHelper.tableSettings,
        where: '${DatabaseHelper.columnSettingsKey} = ?',
        whereArgs: [key],
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete setting $key: $e'));
    }
  }

  @override
  Future<Result<void>> clearAllSettings() async {
    try {
      final db = await _databaseHelper.database;

      await db.delete(DatabaseHelper.tableSettings);

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to clear all settings: $e'));
    }
  }

  @override
  Future<Result<bool>> hasSetting(String key) async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableSettings,
        columns: [DatabaseHelper.columnSettingsKey],
        where: '${DatabaseHelper.columnSettingsKey} = ?',
        whereArgs: [key],
        limit: 1,
      );

      return Result.success(results.isNotEmpty);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to check setting $key: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getAllSettingKeys() async {
    try {
      final db = await _databaseHelper.database;

      final results = await db.query(
        DatabaseHelper.tableSettings,
        columns: [DatabaseHelper.columnSettingsKey],
      );

      final keys = results
          .map((row) => row[DatabaseHelper.columnSettingsKey] as String)
          .toList();

      return Result.success(keys);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get all setting keys: $e'));
    }
  }
}
