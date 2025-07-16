import '../entities/user_settings.dart';
import '../utils/result.dart';

/// Repository interface for user settings management
/// Defines the contract for settings data operations
abstract class SettingsRepository {
  /// Gets the current user settings
  /// 
  /// Returns a Result containing UserSettings or a Failure
  Future<Result<UserSettings>> getUserSettings();

  /// Updates the user settings
  /// 
  /// [settings] - The UserSettings to save
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<UserSettings>> updateUserSettings(UserSettings settings);

  /// Gets a specific setting value by key
  /// 
  /// [key] - The setting key to retrieve
  /// 
  /// Returns a Result containing the setting value or a Failure
  Future<Result<String?>> getSetting(String key);

  /// Sets a specific setting value
  /// 
  /// [key] - The setting key
  /// [value] - The setting value
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> setSetting(String key, String? value);

  /// Gets a boolean setting value
  /// 
  /// [key] - The setting key
  /// [defaultValue] - Default value if setting doesn't exist
  /// 
  /// Returns a Result containing the boolean value or a Failure
  Future<Result<bool>> getBoolSetting(String key, {bool defaultValue = false});

  /// Sets a boolean setting value
  /// 
  /// [key] - The setting key
  /// [value] - The boolean value
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> setBoolSetting(String key, bool value);

  /// Gets an integer setting value
  /// 
  /// [key] - The setting key
  /// [defaultValue] - Default value if setting doesn't exist
  /// 
  /// Returns a Result containing the integer value or a Failure
  Future<Result<int?>> getIntSetting(String key, {int? defaultValue});

  /// Sets an integer setting value
  /// 
  /// [key] - The setting key
  /// [value] - The integer value
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> setIntSetting(String key, int? value);

  /// Gets a double setting value
  /// 
  /// [key] - The setting key
  /// [defaultValue] - Default value if setting doesn't exist
  /// 
  /// Returns a Result containing the double value or a Failure
  Future<Result<double?>> getDoubleSetting(String key, {double? defaultValue});

  /// Sets a double setting value
  /// 
  /// [key] - The setting key
  /// [value] - The double value
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> setDoubleSetting(String key, double? value);

  /// Gets a DateTime setting value
  /// 
  /// [key] - The setting key
  /// [defaultValue] - Default value if setting doesn't exist
  /// 
  /// Returns a Result containing the DateTime value or a Failure
  Future<Result<DateTime?>> getDateTimeSetting(String key, {DateTime? defaultValue});

  /// Sets a DateTime setting value
  /// 
  /// [key] - The setting key
  /// [value] - The DateTime value
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> setDateTimeSetting(String key, DateTime? value);

  /// Deletes a specific setting
  /// 
  /// [key] - The setting key to delete
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> deleteSetting(String key);

  /// Clears all settings
  /// 
  /// Returns a Result indicating success or failure
  Future<Result<void>> clearAllSettings();

  /// Checks if a setting exists
  /// 
  /// [key] - The setting key to check
  /// 
  /// Returns a Result containing true if the setting exists, false otherwise
  Future<Result<bool>> hasSetting(String key);

  /// Gets all setting keys
  /// 
  /// Returns a Result containing a list of all setting keys
  Future<Result<List<String>>> getAllSettingKeys();
}
