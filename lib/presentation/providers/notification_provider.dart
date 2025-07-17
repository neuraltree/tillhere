import 'package:flutter/material.dart';
import '../../core/entities/notification_settings.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';

/// Provider for managing notification settings and local notifications
/// Handles loading, updating, and state management for notification configuration
class NotificationProvider extends ChangeNotifier {
  final NotificationRepositoryImpl _notificationRepository;
  final NotificationService _notificationService;

  List<NotificationSettings> _notificationSettings = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  NotificationProvider({
    required NotificationRepositoryImpl notificationRepository,
    required NotificationService notificationService,
  }) : _notificationRepository = notificationRepository,
       _notificationService = notificationService;

  // Factory constructor for dependency injection
  factory NotificationProvider.create() {
    final databaseHelper = DatabaseHelper();
    final notificationRepository = NotificationRepositoryImpl(databaseHelper);
    final notificationService = NotificationService();

    return NotificationProvider(
      notificationRepository: notificationRepository,
      notificationService: notificationService,
    );
  }

  // Getters
  List<NotificationSettings> get notificationSettings => _notificationSettings;
  List<NotificationSettings> get enabledNotifications => 
      _notificationSettings.where((setting) => setting.enabled).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get hasEnabledNotifications => enabledNotifications.isNotEmpty;
  int get notificationCount => _notificationSettings.length;
  int get enabledNotificationCount => enabledNotifications.length;

  /// Initialize the provider by setting up notification service and loading settings
  /// Call this after Flutter bindings are initialized
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      print('🔄 NotificationProvider: Initializing notification service...');
      
      // Initialize notification service
      final initResult = await _notificationService.initialize();
      if (initResult.isFailure) {
        _setError('Failed to initialize notification service: ${initResult.failure}');
        _setLoading(false);
        return;
      }

      // Request permissions
      final permissionResult = await _notificationService.requestPermissions();
      if (permissionResult.isFailure) {
        _setError('Failed to request notification permissions: ${permissionResult.failure}');
        _setLoading(false);
        return;
      }

      if (permissionResult.data == false) {
        _setError('Notification permissions denied');
        _setLoading(false);
        return;
      }

      // Load notification settings
      await _loadNotificationSettings();

      _isInitialized = true;
      print('✅ NotificationProvider: Initialization complete');
    } catch (e) {
      print('❌ NotificationProvider: Initialization error: $e');
      _setError('Unexpected error during initialization: $e');
    }

    _setLoading(false);
  }

  /// Load notification settings from database
  Future<void> _loadNotificationSettings() async {
    try {
      print('🔄 NotificationProvider: Loading notification settings...');
      final result = await _notificationRepository.getAllNotificationSettings();

      if (result.isSuccess) {
        _notificationSettings = result.data!;
        print('✅ NotificationProvider: Loaded ${_notificationSettings.length} notification settings');
      } else {
        print('❌ NotificationProvider: Failed to load settings: ${result.failure}');
        _setError('Failed to load notification settings: ${result.failure}');
      }
    } catch (e) {
      print('❌ NotificationProvider: Unexpected error loading settings: $e');
      _setError('Unexpected error loading notification settings: $e');
    }
  }

  /// Create a new notification setting
  Future<bool> createNotificationSetting(NotificationSettings settings) async {
    _setLoading(true);
    _clearError();

    try {
      // Create in database
      final createResult = await _notificationRepository.createNotificationSetting(settings);
      if (createResult.isFailure) {
        _setError('Failed to create notification setting: ${createResult.failure}');
        _setLoading(false);
        return false;
      }

      // Schedule notification if enabled
      if (settings.enabled) {
        final scheduleResult = await _notificationService.scheduleNotification(settings);
        if (scheduleResult.isFailure) {
          _setError('Failed to schedule notification: ${scheduleResult.failure}');
          _setLoading(false);
          return false;
        }
      }

      // Update local state
      _notificationSettings.add(settings);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Unexpected error creating notification setting: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing notification setting
  Future<bool> updateNotificationSetting(NotificationSettings settings) async {
    _setLoading(true);
    _clearError();

    try {
      // Update in database
      final updateResult = await _notificationRepository.updateNotificationSetting(settings);
      if (updateResult.isFailure) {
        _setError('Failed to update notification setting: ${updateResult.failure}');
        _setLoading(false);
        return false;
      }

      // Cancel existing notification
      await _notificationService.cancelNotification(settings.id);

      // Schedule new notification if enabled
      if (settings.enabled) {
        final scheduleResult = await _notificationService.scheduleNotification(settings);
        if (scheduleResult.isFailure) {
          _setError('Failed to reschedule notification: ${scheduleResult.failure}');
          _setLoading(false);
          return false;
        }
      }

      // Update local state
      final index = _notificationSettings.indexWhere((s) => s.id == settings.id);
      if (index != -1) {
        _notificationSettings[index] = settings;
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Unexpected error updating notification setting: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a notification setting
  Future<bool> deleteNotificationSetting(String id) async {
    _setLoading(true);
    _clearError();

    try {
      // Cancel notification
      await _notificationService.cancelNotification(id);

      // Delete from database
      final deleteResult = await _notificationRepository.deleteNotificationSetting(id);
      if (deleteResult.isFailure) {
        _setError('Failed to delete notification setting: ${deleteResult.failure}');
        _setLoading(false);
        return false;
      }

      // Update local state
      _notificationSettings.removeWhere((s) => s.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Unexpected error deleting notification setting: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Toggle notification enabled status
  Future<bool> toggleNotificationEnabled(String id) async {
    final setting = _notificationSettings.firstWhere((s) => s.id == id);
    final updatedSetting = setting.copyWith(
      enabled: !setting.enabled,
      updatedAt: DateTime.now(),
    );
    
    return await updateNotificationSetting(updatedSetting);
  }

  /// Get notification setting by ID
  NotificationSettings? getNotificationSetting(String id) {
    try {
      return _notificationSettings.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get notifications by schedule type
  List<NotificationSettings> getNotificationsByScheduleType(NotificationScheduleType scheduleType) {
    return _notificationSettings.where((s) => s.scheduleType == scheduleType).toList();
  }

  /// Refresh notification settings from database
  Future<void> refreshNotificationSettings() async {
    await _loadNotificationSettings();
  }

  /// Cancel all notifications and clear settings
  Future<bool> clearAllNotifications() async {
    _setLoading(true);
    _clearError();

    try {
      // Cancel all notifications
      await _notificationService.cancelAllNotifications();

      // Delete all from database
      final deleteResult = await _notificationRepository.deleteAllNotificationSettings();
      if (deleteResult.isFailure) {
        _setError('Failed to clear all notifications: ${deleteResult.failure}');
        _setLoading(false);
        return false;
      }

      // Clear local state
      _notificationSettings.clear();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Unexpected error clearing notifications: $e');
      _setLoading(false);
      return false;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
