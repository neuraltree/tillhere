import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:tillhere/core/entities/notification_settings.dart';
import 'package:tillhere/core/errors/failures.dart';
import 'package:tillhere/core/services/notification_service.dart';
import 'package:tillhere/core/utils/result.dart';
import 'package:tillhere/data/repositories/notification_repository_impl.dart';
import 'package:tillhere/presentation/providers/notification_provider.dart';

import 'notification_provider_test.mocks.dart';

@GenerateMocks([NotificationRepositoryImpl, NotificationService])
void main() {
  group('NotificationProvider', () {
    late NotificationProvider notificationProvider;
    late MockNotificationRepositoryImpl mockRepository;
    late MockNotificationService mockNotificationService;

    setUpAll(() {
      // Initialize timezone data for tests
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/New_York'));
    });

    setUp(() {
      mockRepository = MockNotificationRepositoryImpl();
      mockNotificationService = MockNotificationService();

      notificationProvider = NotificationProvider(
        notificationRepository: mockRepository,
        notificationService: mockNotificationService,
      );
    });

    group('initialization', () {
      test('should initialize successfully when service initialization succeeds', () async {
        // Arrange
        when(mockNotificationService.initialize()).thenAnswer((_) async => Result.success(true));
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => Result.success(true));
        when(mockRepository.getAllNotificationSettings()).thenAnswer((_) async => Result.success([]));

        // Act
        await notificationProvider.initialize();

        // Assert
        expect(notificationProvider.isInitialized, isTrue);
        expect(notificationProvider.error, isNull);
        expect(notificationProvider.isLoading, isFalse);

        verify(mockNotificationService.initialize()).called(1);
        verify(mockNotificationService.requestPermissions()).called(1);
        verify(mockRepository.getAllNotificationSettings()).called(1);
      });

      test('should handle service initialization failure', () async {
        // Arrange
        when(
          mockNotificationService.initialize(),
        ).thenAnswer((_) async => Result.failure(const NotificationFailure('Init failed')));

        // Act
        await notificationProvider.initialize();

        // Assert
        expect(notificationProvider.isInitialized, isFalse);
        expect(notificationProvider.error, contains('Init failed'));
        expect(notificationProvider.isLoading, isFalse);
      });

      test('should handle permission denial', () async {
        // Arrange
        when(mockNotificationService.initialize()).thenAnswer((_) async => Result.success(true));
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => Result.success(false));

        // Act
        await notificationProvider.initialize();

        // Assert
        expect(notificationProvider.isInitialized, isFalse);
        expect(notificationProvider.error, contains('permissions denied'));
        expect(notificationProvider.isLoading, isFalse);
      });

      test('should not initialize twice', () async {
        // Arrange
        when(mockNotificationService.initialize()).thenAnswer((_) async => Result.success(true));
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => Result.success(true));
        when(mockRepository.getAllNotificationSettings()).thenAnswer((_) async => Result.success([]));

        // Act
        await notificationProvider.initialize();
        await notificationProvider.initialize(); // Second call

        // Assert
        verify(mockNotificationService.initialize()).called(1); // Only called once
      });
    });

    group('notification management', () {
      setUp(() async {
        // Initialize provider for these tests
        when(mockNotificationService.initialize()).thenAnswer((_) async => Result.success(true));
        when(mockNotificationService.requestPermissions()).thenAnswer((_) async => Result.success(true));
        when(mockRepository.getAllNotificationSettings()).thenAnswer((_) async => Result.success([]));

        await notificationProvider.initialize();
      });

      test('should create notification setting successfully', () async {
        // Arrange
        final testNotification = NotificationSettings(
          id: 'test_id',
          enabled: true,
          title: 'Test',
          body: 'Test body',
          scheduleType: NotificationScheduleType.daily,
          time: '20:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockRepository.createNotificationSetting(testNotification),
        ).thenAnswer((_) async => Result.success(testNotification));
        when(
          mockNotificationService.scheduleNotification(testNotification),
        ).thenAnswer((_) async => Result.success(null));

        // Act
        final result = await notificationProvider.createNotificationSetting(testNotification);

        // Assert
        expect(result, isTrue);
        expect(notificationProvider.notificationSettings, contains(testNotification));
        expect(notificationProvider.error, isNull);

        verify(mockRepository.createNotificationSetting(testNotification)).called(1);
        verify(mockNotificationService.scheduleNotification(testNotification)).called(1);
      });

      test('should handle repository failure when creating notification', () async {
        // Arrange
        final testNotification = NotificationSettings(
          id: 'test_id',
          enabled: true,
          title: 'Test',
          body: 'Test body',
          scheduleType: NotificationScheduleType.daily,
          time: '20:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(
          mockRepository.createNotificationSetting(testNotification),
        ).thenAnswer((_) async => Result.failure(const DatabaseFailure('DB error')));

        // Act
        final result = await notificationProvider.createNotificationSetting(testNotification);

        // Assert
        expect(result, isFalse);
        expect(notificationProvider.error, contains('DB error'));
        expect(notificationProvider.notificationSettings, isEmpty);
      });

      test('should toggle notification enabled status', () async {
        // Arrange
        final testNotification = NotificationSettings(
          id: 'test_id',
          enabled: true,
          title: 'Test',
          body: 'Test body',
          scheduleType: NotificationScheduleType.daily,
          time: '20:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Add notification to provider state
        notificationProvider.notificationSettings.add(testNotification);

        final updatedNotification = testNotification.copyWith(enabled: false);
        when(
          mockRepository.updateNotificationSetting(any),
        ).thenAnswer((_) async => Result.success(updatedNotification));
        when(mockNotificationService.cancelNotification('test_id')).thenAnswer((_) async => Result.success(null));

        // Act
        final result = await notificationProvider.toggleNotificationEnabled('test_id');

        // Assert
        expect(result, isTrue);
        verify(mockRepository.updateNotificationSetting(any)).called(1);
        verify(mockNotificationService.cancelNotification('test_id')).called(1);
      });
    });

    group('getters', () {
      test('should return correct enabled notifications count', () {
        // Arrange
        final enabledNotification = NotificationSettings(
          id: 'enabled',
          enabled: true,
          title: 'Enabled',
          body: 'Body',
          scheduleType: NotificationScheduleType.daily,
          time: '20:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final disabledNotification = NotificationSettings(
          id: 'disabled',
          enabled: false,
          title: 'Disabled',
          body: 'Body',
          scheduleType: NotificationScheduleType.daily,
          time: '20:00',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        notificationProvider.notificationSettings.addAll([enabledNotification, disabledNotification]);

        // Act & Assert
        expect(notificationProvider.enabledNotificationCount, equals(1));
        expect(notificationProvider.hasEnabledNotifications, isTrue);
        expect(notificationProvider.enabledNotifications, contains(enabledNotification));
        expect(notificationProvider.enabledNotifications, isNot(contains(disabledNotification)));
      });
    });
  });
}
