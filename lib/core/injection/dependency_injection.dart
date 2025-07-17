import '../../core/repositories/navigation_repository.dart';
import '../../core/repositories/mood_repository.dart';
import '../../core/repositories/notification_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/usecases/navigation_usecases.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/repositories/navigation_repository_impl.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../presentation/providers/navigation_provider.dart';
import '../../presentation/providers/mood_capture_provider.dart';
import '../../presentation/providers/settings_provider.dart';
import '../../presentation/providers/notification_provider.dart';

/// Dependency injection setup
/// Following Clean Architecture principles - dependency management
class DependencyInjection {
  static NavigationRepository? _navigationRepository;
  static NavigationProvider? _navigationProvider;
  static MoodRepository? _moodRepository;
  static MoodCaptureProvider? _moodCaptureProvider;
  static SettingsProvider? _settingsProvider;
  static NotificationRepositoryImpl? _notificationRepository;
  static NotificationService? _notificationService;
  static NotificationProvider? _notificationProvider;
  static DatabaseHelper? _databaseHelper;

  /// Initialize dependencies
  static void initialize() {
    // Database helper
    _databaseHelper = DatabaseHelper();

    // Repositories
    _navigationRepository = NavigationRepositoryImpl();
    _moodRepository = MoodRepositoryImpl(_databaseHelper!);
    _notificationRepository = NotificationRepositoryImpl(_databaseHelper!);

    // Services
    _notificationService = NotificationService();

    // Navigation use cases
    final navigateToRouteUseCase = NavigateToRouteUseCase(_navigationRepository!);
    final toggleDrawerUseCase = ToggleDrawerUseCase(_navigationRepository!);
    final setDrawerStateUseCase = SetDrawerStateUseCase(_navigationRepository!);
    final updateTimeFilterUseCase = UpdateTimeFilterUseCase(_navigationRepository!);
    final getNavigationStateUseCase = GetNavigationStateUseCase(_navigationRepository!);
    final observeNavigationStateUseCase = ObserveNavigationStateUseCase(_navigationRepository!);

    // Providers
    _navigationProvider = NavigationProvider(
      navigateToRouteUseCase: navigateToRouteUseCase,
      toggleDrawerUseCase: toggleDrawerUseCase,
      setDrawerStateUseCase: setDrawerStateUseCase,
      updateTimeFilterUseCase: updateTimeFilterUseCase,
      getNavigationStateUseCase: getNavigationStateUseCase,
      observeNavigationStateUseCase: observeNavigationStateUseCase,
    );

    _moodCaptureProvider = MoodCaptureProvider(moodRepository: _moodRepository!);

    // Settings provider
    _settingsProvider = SettingsProvider.create();

    // Notification provider
    _notificationProvider = NotificationProvider(
      notificationRepository: _notificationRepository!,
      notificationService: _notificationService!,
    );
  }

  /// Get navigation provider instance
  static NavigationProvider get navigationProvider {
    if (_navigationProvider == null) {
      throw Exception('DependencyInjection not initialized. Call initialize() first.');
    }
    return _navigationProvider!;
  }

  /// Get mood capture provider instance
  static MoodCaptureProvider get moodCaptureProvider {
    if (_moodCaptureProvider == null) {
      throw Exception('DependencyInjection not initialized. Call initialize() first.');
    }
    return _moodCaptureProvider!;
  }

  /// Get mood repository instance
  static MoodRepository get moodRepository {
    if (_moodRepository == null) {
      throw Exception('DependencyInjection not initialized. Call initialize() first.');
    }
    return _moodRepository!;
  }

  /// Get settings provider instance
  static SettingsProvider get settingsProvider {
    if (_settingsProvider == null) {
      throw Exception('DependencyInjection not initialized. Call initialize() first.');
    }
    return _settingsProvider!;
  }

  /// Get notification provider instance
  static NotificationProvider get notificationProvider {
    if (_notificationProvider == null) {
      throw Exception('DependencyInjection not initialized. Call initialize() first.');
    }
    return _notificationProvider!;
  }

  /// Get notification service instance
  static NotificationService? get notificationService => _notificationService;

  /// Dispose resources
  static void dispose() {
    _navigationRepository?.dispose();
    _navigationProvider?.dispose();
    _settingsProvider?.dispose();
    _notificationProvider?.dispose();
    _navigationRepository = null;
    _navigationProvider = null;
    _settingsProvider = null;
    _notificationRepository = null;
    _notificationService = null;
    _notificationProvider = null;
  }
}
