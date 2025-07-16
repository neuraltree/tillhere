import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../core/entities/user_settings.dart';
import '../../core/services/life_expectancy_service.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/life_expectancy_local_datasource.dart';
import '../../data/datasources/local/locale_detection_service.dart';

/// Provider for managing user settings and life expectancy setup
/// Handles loading, updating, and state management for user configuration
class SettingsProvider extends ChangeNotifier {
  final SettingsRepositoryImpl _settingsRepository;
  final LifeExpectancyService _lifeExpectancyService;

  UserSettings? _userSettings;
  bool _isLoading = false;
  String? _error;
  bool _isSetupComplete = false;

  SettingsProvider({
    required SettingsRepositoryImpl settingsRepository,
    required LifeExpectancyService lifeExpectancyService,
  }) : _settingsRepository = settingsRepository,
       _lifeExpectancyService = lifeExpectancyService;

  // Factory constructor for dependency injection
  factory SettingsProvider.create() {
    final databaseHelper = DatabaseHelper();
    final settingsRepository = SettingsRepositoryImpl(databaseHelper);
    final lifeExpectancyDataSource = LifeExpectancyLocalDataSource();
    final localeDetectionService = LocaleDetectionService();
    final lifeExpectancyService = LifeExpectancyService(lifeExpectancyDataSource, localeDetectionService);

    return SettingsProvider(settingsRepository: settingsRepository, lifeExpectancyService: lifeExpectancyService);
  }

  // Getters
  UserSettings? get userSettings => _userSettings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSetupComplete => _isSetupComplete;
  bool get hasBasicSetup => _userSettings?.hasBasicSetup ?? false;

  /// Initialize the provider by loading user settings
  /// Call this after Flutter bindings are initialized
  Future<void> initialize() async {
    if (_userSettings == null && !_isLoading) {
      await _loadUserSettings();
    }
  }

  /// Load user settings from database
  Future<void> _loadUserSettings() async {
    _setLoading(true);
    _clearError();

    try {
      print('🔄 SettingsProvider: Loading user settings...');
      final result = await _settingsRepository.getUserSettings();

      if (result.isSuccess) {
        _userSettings = result.data;
        _isSetupComplete = _userSettings?.hasBasicSetup ?? false;
        print('✅ SettingsProvider: Settings loaded successfully');
        print('   - Has basic setup: ${_userSettings?.hasBasicSetup}');
        print('   - Date of birth: ${_userSettings?.dateOfBirth}');
        print('   - Country code: ${_userSettings?.countryCode}');
        print('   - Death date: ${_userSettings?.deathDate}');
        print('   - Life expectancy years: ${_userSettings?.lifeExpectancyYears}');
        print('   - Last calculated at: ${_userSettings?.lastCalculatedAt}');
        print('   - Show life expectancy: ${_userSettings?.showLifeExpectancy}');
        print('   - Show weeks remaining: ${_userSettings?.showWeeksRemaining}');
        print('   - Is setup complete: $_isSetupComplete');
      } else {
        print('❌ SettingsProvider: Failed to load settings: ${result.failure}');
        _setError('Failed to load user settings: ${result.failure}');
      }
    } catch (e) {
      print('❌ SettingsProvider: Unexpected error: $e');
      _setError('Unexpected error loading settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Setup user with date of birth and country
  Future<bool> setupUser({required DateTime dateOfBirth, required String countryCode}) async {
    _setLoading(true);
    _clearError();

    try {
      // Compute death date using life expectancy service
      final result = await _lifeExpectancyService.computeDeathDate(dateOfBirth, countryCode: countryCode);

      if (result.isSuccess) {
        final settings = result.data!;
        print('💾 SettingsProvider: Saving settings to database...');
        print('   - Date of birth: ${settings.dateOfBirth}');
        print('   - Country code: ${settings.countryCode}');

        // Save settings to database
        final saveResult = await _settingsRepository.updateUserSettings(settings);

        if (saveResult.isSuccess) {
          _userSettings = settings;
          _isSetupComplete = true;
          print('✅ SettingsProvider: Settings saved successfully');
          _setLoading(false);
          return true;
        } else {
          print('❌ SettingsProvider: Failed to save settings: ${saveResult.failure}');
          _setError('Failed to save user settings: ${saveResult.failure}');
        }
      } else {
        print('❌ SettingsProvider: Failed to compute life expectancy: ${result.failure}');
        _setError('Failed to compute life expectancy: ${result.failure}');
      }
    } catch (e) {
      _setError('Unexpected error during setup: $e');
    }

    _setLoading(false);
    return false;
  }

  /// Update user settings
  Future<bool> updateSettings(UserSettings settings) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _settingsRepository.updateUserSettings(settings);

      if (result.isSuccess) {
        _userSettings = settings;
        _isSetupComplete = settings.hasBasicSetup;
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to update settings: ${result.failure}');
      }
    } catch (e) {
      _setError('Unexpected error updating settings: $e');
    }

    _setLoading(false);
    return false;
  }

  /// Refresh user settings from database
  Future<void> refreshSettings() async {
    await _loadUserSettings();
  }

  /// Clear setup and reset user to initial state
  Future<bool> clearSetup() async {
    _setLoading(true);
    _clearError();

    try {
      // Create empty settings
      final emptySettings = const UserSettings();
      final result = await _settingsRepository.updateUserSettings(emptySettings);

      if (result.isSuccess) {
        _userSettings = emptySettings;
        _isSetupComplete = false;
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to clear setup: ${result.failure}');
      }
    } catch (e) {
      _setError('Unexpected error clearing setup: $e');
    }

    _setLoading(false);
    return false;
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
