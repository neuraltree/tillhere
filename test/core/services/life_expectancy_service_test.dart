import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tillhere/core/services/life_expectancy_service.dart';
import 'package:tillhere/core/entities/life_expectancy.dart';
import 'package:tillhere/core/entities/user_settings.dart';
import 'package:tillhere/core/entities/week_range.dart';
import 'package:tillhere/core/utils/result.dart';
import 'package:tillhere/core/errors/failures.dart';
import 'package:tillhere/data/datasources/local/life_expectancy_local_datasource.dart';
import 'package:tillhere/data/datasources/local/locale_detection_service.dart';

import 'life_expectancy_service_test.mocks.dart';

@GenerateMocks([LifeExpectancyLocalDataSource, LocaleDetectionService])
void main() {
  group('LifeExpectancyService', () {
    late LifeExpectancyService service;
    late MockLifeExpectancyLocalDataSource mockDataSource;
    late MockLocaleDetectionService mockLocaleService;

    setUp(() {
      mockDataSource = MockLifeExpectancyLocalDataSource();
      mockLocaleService = MockLocaleDetectionService();
      service = LifeExpectancyService(mockDataSource, mockLocaleService);
    });

    group('computeDeathDate', () {
      test('should compute death date successfully with provided country code', () async {
        // Arrange
        final dateOfBirth = DateTime(1990, 5, 15);
        const countryCode = 'US';
        final lifeExpectancy = LifeExpectancy(
          countryCode: countryCode,
          yearsAtBirth: 78.5,
          year: 2023,
          fetchedAt: DateTime.now(),
        );

        when(mockDataSource.getLifeExpectancy(countryCode)).thenAnswer((_) async => Result.success(lifeExpectancy));

        // Act
        final result = await service.computeDeathDate(dateOfBirth, countryCode: countryCode);

        // Assert
        expect(result.isSuccess, isTrue);
        final userSettings = result.data!;
        expect(userSettings.dateOfBirth, equals(dateOfBirth));
        expect(userSettings.countryCode, equals(countryCode));
        expect(userSettings.lifeExpectancyYears, equals(78.5));
        expect(userSettings.deathDate, isNotNull);
        expect(userSettings.showLifeExpectancy, isTrue);
        expect(userSettings.showWeeksRemaining, isTrue);

        // Verify death date calculation (approximately 78.5 years from birth)
        final expectedDeathDate = dateOfBirth.add(Duration(days: (78.5 * 365.25).round()));
        expect(userSettings.deathDate, equals(expectedDeathDate));

        verify(mockDataSource.getLifeExpectancy(countryCode)).called(1);
        verifyNever(mockLocaleService.detectCountryCode());
      });

      test('should detect country code when not provided', () async {
        // Arrange
        final dateOfBirth = DateTime(1990, 5, 15);
        const detectedCountryCode = 'GB';
        final lifeExpectancy = LifeExpectancy(
          countryCode: detectedCountryCode,
          yearsAtBirth: 81.2,
          year: 2023,
          fetchedAt: DateTime.now(),
        );

        when(mockLocaleService.detectCountryCode()).thenAnswer((_) async => Result.success(detectedCountryCode));
        when(
          mockDataSource.getLifeExpectancy(detectedCountryCode),
        ).thenAnswer((_) async => Result.success(lifeExpectancy));

        // Act
        final result = await service.computeDeathDate(dateOfBirth);

        // Assert
        expect(result.isSuccess, isTrue);
        final userSettings = result.data!;
        expect(userSettings.countryCode, equals(detectedCountryCode));
        expect(userSettings.lifeExpectancyYears, equals(81.2));

        verify(mockLocaleService.detectCountryCode()).called(1);
        verify(mockDataSource.getLifeExpectancy(detectedCountryCode)).called(1);
      });

      test('should fail when date of birth is in the future', () async {
        // Arrange
        final futureDate = DateTime.now().add(const Duration(days: 1));

        // Act
        final result = await service.computeDeathDate(futureDate);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure!.message, contains('Date of birth cannot be in the future'));

        verifyNever(mockLocaleService.detectCountryCode());
        verifyNever(mockDataSource.getLifeExpectancy(any));
      });

      test('should fail when country detection fails', () async {
        // Arrange
        final dateOfBirth = DateTime(1990, 5, 15);
        final failure = CacheFailure('Failed to detect country');

        when(mockLocaleService.detectCountryCode()).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await service.computeDeathDate(dateOfBirth);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, equals(failure));

        verify(mockLocaleService.detectCountryCode()).called(1);
        verifyNever(mockDataSource.getLifeExpectancy(any));
      });

      test('should fail when life expectancy data is not available', () async {
        // Arrange
        final dateOfBirth = DateTime(1990, 5, 15);
        const countryCode = 'XX';
        final failure = NetworkFailure('No data available for country XX');

        when(mockDataSource.getLifeExpectancy(countryCode)).thenAnswer((_) async => Result.failure(failure));

        // Act
        final result = await service.computeDeathDate(dateOfBirth, countryCode: countryCode);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, equals(failure));

        verify(mockDataSource.getLifeExpectancy(countryCode)).called(1);
      });

      test('should handle exceptions gracefully', () async {
        // Arrange
        final dateOfBirth = DateTime(1990, 5, 15);
        const countryCode = 'US';

        when(mockDataSource.getLifeExpectancy(countryCode)).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await service.computeDeathDate(dateOfBirth, countryCode: countryCode);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure!.message, contains('Failed to compute death date'));
      });
    });

    group('updateLifeExpectancy', () {
      test('should update life expectancy when refresh is needed', () async {
        // Arrange
        final oldDate = DateTime.now().subtract(const Duration(days: 40));
        final currentSettings = UserSettings(
          dateOfBirth: DateTime(1990, 5, 15),
          countryCode: 'US',
          lastCalculatedAt: oldDate,
        );

        final lifeExpectancy = LifeExpectancy(
          countryCode: 'US',
          yearsAtBirth: 79.0,
          year: 2024,
          fetchedAt: DateTime.now(),
        );

        when(mockDataSource.getLifeExpectancy('US')).thenAnswer((_) async => Result.success(lifeExpectancy));

        // Act
        final result = await service.updateLifeExpectancy(currentSettings);

        // Assert
        expect(result.isSuccess, isTrue);
        final updatedSettings = result.data!;
        expect(updatedSettings.lifeExpectancyYears, equals(79.0));
        expect(updatedSettings.lastCalculatedAt, isNotNull);

        verify(mockDataSource.getLifeExpectancy('US')).called(1);
      });

      test('should return current settings when calculation is fresh', () async {
        // Arrange
        final recentDate = DateTime.now().subtract(const Duration(days: 1));
        final currentSettings = UserSettings(
          dateOfBirth: DateTime(1990, 5, 15),
          countryCode: 'US',
          lifeExpectancyYears: 78.5,
          lastCalculatedAt: recentDate,
        );

        // Act
        final result = await service.updateLifeExpectancy(currentSettings);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data, equals(currentSettings));

        verifyNever(mockDataSource.getLifeExpectancy(any));
      });

      test('should force refresh when requested', () async {
        // Arrange
        final recentDate = DateTime.now().subtract(const Duration(days: 1));
        final currentSettings = UserSettings(
          dateOfBirth: DateTime(1990, 5, 15),
          countryCode: 'US',
          lastCalculatedAt: recentDate,
        );

        final lifeExpectancy = LifeExpectancy(
          countryCode: 'US',
          yearsAtBirth: 79.5,
          year: 2024,
          fetchedAt: DateTime.now(),
        );

        when(mockDataSource.getLifeExpectancy('US')).thenAnswer((_) async => Result.success(lifeExpectancy));

        // Act
        final result = await service.updateLifeExpectancy(currentSettings, forceRefresh: true);

        // Assert
        expect(result.isSuccess, isTrue);
        final updatedSettings = result.data!;
        expect(updatedSettings.lifeExpectancyYears, equals(79.5));

        verify(mockDataSource.getLifeExpectancy('US')).called(1);
      });

      test('should fail when required data is missing', () async {
        // Arrange
        final currentSettings = UserSettings(
          dateOfBirth: DateTime(1990, 5, 15),
          // Missing countryCode
        );

        // Act
        final result = await service.updateLifeExpectancy(currentSettings);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure!.message, contains('Date of birth and country code are required'));

        verifyNever(mockDataSource.getLifeExpectancy(any));
      });
    });

    group('generateFutureWeeks', () {
      test('should generate future weeks successfully', () async {
        // Arrange
        final dateOfBirth = DateTime(1990, 5, 15);
        final deathDate = DateTime(2070, 5, 15);
        final userSettings = UserSettings(dateOfBirth: dateOfBirth, deathDate: deathDate);

        // Act
        final result = await service.generateFutureWeeks(userSettings);

        // Assert
        expect(result.isSuccess, isTrue);
        final weeks = result.data!;
        expect(weeks, isNotEmpty);
        expect(weeks.first, isA<WeekRange>());
      });

      test('should limit weeks when maxWeeks is specified', () async {
        // Arrange
        final dateOfBirth = DateTime(1990, 5, 15);
        final deathDate = DateTime(2070, 5, 15);
        final userSettings = UserSettings(dateOfBirth: dateOfBirth, deathDate: deathDate);

        // Act
        final result = await service.generateFutureWeeks(userSettings, maxWeeks: 10);

        // Assert
        expect(result.isSuccess, isTrue);
        final weeks = result.data!;
        expect(weeks.length, equals(10));
      });

      test('should fail when required data is missing', () async {
        // Arrange
        final userSettings = UserSettings(
          dateOfBirth: DateTime(1990, 5, 15),
          // Missing deathDate
        );

        // Act
        final result = await service.generateFutureWeeks(userSettings);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure!.message, contains('Date of birth and death date are required'));
      });
    });

    group('getLifeExpectancyStats', () {
      test('should calculate statistics correctly', () async {
        // Arrange
        final dateOfBirth = DateTime(1990, 5, 15);
        final deathDate = DateTime(2070, 5, 15); // 80 years later
        final userSettings = UserSettings(
          dateOfBirth: dateOfBirth,
          deathDate: deathDate,
          countryCode: 'US',
          lifeExpectancyYears: 80.0,
          lastCalculatedAt: DateTime.now(),
        );

        // Act
        final result = await service.getLifeExpectancyStats(userSettings);

        // Assert
        expect(result.isSuccess, isTrue);
        final stats = result.data!;
        expect(stats.totalLifeExpectancyYears, equals(80.0));
        expect(stats.countryCode, equals('US'));
        expect(stats.totalLifeExpectancyDays, greaterThan(0));
        expect(stats.totalLifeExpectancyWeeks, greaterThan(0));
        expect(stats.weeksLived, greaterThan(0));
        expect(stats.daysLived, greaterThan(0));
        expect(stats.percentageLived, greaterThan(0));
        expect(stats.percentageLived, lessThanOrEqualTo(100));
        expect(stats.currentAge, greaterThan(0));
      });

      test('should handle case where death date has passed', () async {
        // Arrange
        final dateOfBirth = DateTime(1950, 1, 1);
        final deathDate = DateTime(2020, 1, 1); // Past death date
        final userSettings = UserSettings(
          dateOfBirth: dateOfBirth,
          deathDate: deathDate,
          countryCode: 'US',
          lifeExpectancyYears: 70.0,
        );

        // Act
        final result = await service.getLifeExpectancyStats(userSettings);

        // Assert
        expect(result.isSuccess, isTrue);
        final stats = result.data!;
        expect(stats.weeksRemaining, equals(0));
        expect(stats.daysRemaining, equals(0));
        expect(stats.percentageLived, equals(100.0));
      });

      test('should fail when required data is missing', () async {
        // Arrange
        final userSettings = UserSettings(
          dateOfBirth: DateTime(1990, 5, 15),
          // Missing deathDate
        );

        // Act
        final result = await service.getLifeExpectancyStats(userSettings);

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure!.message, contains('Date of birth and death date are required'));
      });

      test('should handle exceptions gracefully', () async {
        // Arrange - Create settings that might cause calculation errors
        final userSettings = UserSettings(dateOfBirth: DateTime(1990, 5, 15), deathDate: DateTime(2070, 5, 15));

        // Act
        final result = await service.getLifeExpectancyStats(userSettings);

        // Assert - Should still succeed with reasonable defaults
        expect(result.isSuccess, isTrue);
      });
    });

    group('hasRequiredData', () {
      test('should return true when all required data is present', () {
        // Arrange
        final userSettings = UserSettings(
          dateOfBirth: DateTime(1990, 5, 15),
          countryCode: 'US',
          deathDate: DateTime(2070, 5, 15),
        );

        // Act
        final hasData = service.hasRequiredData(userSettings);

        // Assert
        expect(hasData, isTrue);
      });

      test('should return false when required data is missing', () {
        // Arrange
        final userSettings = UserSettings(
          dateOfBirth: DateTime(1990, 5, 15),
          // Missing countryCode
        );

        // Act
        final hasData = service.hasRequiredData(userSettings);

        // Assert
        expect(hasData, isFalse);
      });
    });
  });
}
