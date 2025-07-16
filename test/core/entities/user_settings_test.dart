import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/core/entities/user_settings.dart';

void main() {
  group('UserSettings', () {
    test('should create a valid UserSettings instance', () {
      // Arrange
      final dateOfBirth = DateTime(1990, 5, 15);
      final deathDate = DateTime(2070, 5, 15);
      final lastCalculatedAt = DateTime.now();

      // Act
      final settings = UserSettings(
        dateOfBirth: dateOfBirth,
        deathDate: deathDate,
        countryCode: 'US',
        lifeExpectancyYears: 80.0,
        lastCalculatedAt: lastCalculatedAt,
        locale: 'en_US',
        showLifeExpectancy: true,
        showWeeksRemaining: false,
      );

      // Assert
      expect(settings.dateOfBirth, equals(dateOfBirth));
      expect(settings.deathDate, equals(deathDate));
      expect(settings.countryCode, equals('US'));
      expect(settings.lifeExpectancyYears, equals(80.0));
      expect(settings.lastCalculatedAt, equals(lastCalculatedAt));
      expect(settings.locale, equals('en_US'));
      expect(settings.showLifeExpectancy, isTrue);
      expect(settings.showWeeksRemaining, isFalse);
    });

    test('should have default values for boolean flags', () {
      // Arrange & Act
      const settings = UserSettings();

      // Assert
      expect(settings.showLifeExpectancy, isTrue);
      expect(settings.showWeeksRemaining, isTrue);
    });

    test('should validate correctly for valid settings', () {
      // Arrange
      final settings = UserSettings(
        dateOfBirth: DateTime(1990, 5, 15),
        deathDate: DateTime(2070, 5, 15),
        countryCode: 'US',
        lifeExpectancyYears: 80.0,
      );

      // Act & Assert
      expect(settings.isValid, isTrue);
    });

    test('should invalidate for future date of birth', () {
      // Arrange
      final settings = UserSettings(
        dateOfBirth: DateTime.now().add(const Duration(days: 1)),
        deathDate: DateTime(2070, 5, 15),
      );

      // Act & Assert
      expect(settings.isValid, isFalse);
    });

    test('should invalidate for death date before birth date', () {
      // Arrange
      final settings = UserSettings(dateOfBirth: DateTime(1990, 5, 15), deathDate: DateTime(1980, 5, 15));

      // Act & Assert
      expect(settings.isValid, isFalse);
    });

    test('should invalidate for invalid life expectancy', () {
      // Arrange
      final invalidNegative = UserSettings(dateOfBirth: DateTime(1990, 5, 15), lifeExpectancyYears: -10.0);

      final invalidTooHigh = UserSettings(dateOfBirth: DateTime(1990, 5, 15), lifeExpectancyYears: 200.0);

      // Act & Assert
      expect(invalidNegative.isValid, isFalse);
      expect(invalidTooHigh.isValid, isFalse);
    });

    test('should check basic setup correctly', () {
      // Arrange
      final completeSettings = UserSettings(dateOfBirth: DateTime(1990, 5, 15), countryCode: 'US');

      final incompleteSettings = UserSettings(dateOfBirth: DateTime(1990, 5, 15));

      // Act & Assert
      expect(completeSettings.hasBasicSetup, isTrue);
      expect(incompleteSettings.hasBasicSetup, isFalse);
    });

    test('should check calculation freshness correctly', () {
      // Arrange
      final freshSettings = UserSettings(lastCalculatedAt: DateTime.now().subtract(const Duration(days: 10)));

      final staleSettings = UserSettings(lastCalculatedAt: DateTime.now().subtract(const Duration(days: 40)));

      final noCalculationSettings = UserSettings();

      // Act & Assert
      expect(freshSettings.isCalculationFresh, isTrue);
      expect(staleSettings.isCalculationFresh, isFalse);
      expect(noCalculationSettings.isCalculationFresh, isFalse);
    });

    test('should calculate current age correctly', () {
      // Arrange
      final now = DateTime.now();
      final birthDate = DateTime(now.year - 30, now.month, now.day);
      final settings = UserSettings(dateOfBirth: birthDate);

      // Act
      final age = settings.currentAgeInYears;

      // Assert
      expect(age, equals(30));
    });

    test('should calculate current age correctly for birthday not yet passed', () {
      // Arrange
      final now = DateTime.now();
      final birthDate = DateTime(now.year - 30, now.month + 1, now.day);
      final settings = UserSettings(dateOfBirth: birthDate);

      // Act
      final age = settings.currentAgeInYears;

      // Assert
      expect(age, equals(29));
    });

    test('should return null age when date of birth is not set', () {
      // Arrange
      const settings = UserSettings();

      // Act & Assert
      expect(settings.currentAgeInYears, isNull);
    });

    test('should calculate weeks lived correctly', () {
      // Arrange
      final birthDate = DateTime.now().subtract(const Duration(days: 70)); // 10 weeks
      final settings = UserSettings(dateOfBirth: birthDate);

      // Act
      final weeksLived = settings.weeksLived;

      // Assert
      expect(weeksLived, equals(10));
    });

    test('should return null weeks lived when date of birth is not set', () {
      // Arrange
      const settings = UserSettings();

      // Act & Assert
      expect(settings.weeksLived, isNull);
    });

    test('should calculate weeks remaining correctly', () {
      // Arrange
      final deathDate = DateTime.now().add(const Duration(days: 70)); // ~10 weeks
      final settings = UserSettings(deathDate: deathDate);

      // Act
      final weeksRemaining = settings.weeksRemaining;

      // Assert
      expect(weeksRemaining, greaterThanOrEqualTo(9));
      expect(weeksRemaining, lessThanOrEqualTo(10));
    });

    test('should return 0 weeks remaining when death date has passed', () {
      // Arrange
      final deathDate = DateTime.now().subtract(const Duration(days: 70));
      final settings = UserSettings(deathDate: deathDate);

      // Act
      final weeksRemaining = settings.weeksRemaining;

      // Assert
      expect(weeksRemaining, equals(0));
    });

    test('should return null weeks remaining when death date is not set', () {
      // Arrange
      const settings = UserSettings();

      // Act & Assert
      expect(settings.weeksRemaining, isNull);
    });

    test('should create copy with updated values', () {
      // Arrange
      final originalSettings = UserSettings(
        dateOfBirth: DateTime(1990, 5, 15),
        countryCode: 'US',
        showLifeExpectancy: true,
      );

      // Act
      final updatedSettings = originalSettings.copyWith(countryCode: 'GB', showLifeExpectancy: false);

      // Assert
      expect(updatedSettings.dateOfBirth, equals(originalSettings.dateOfBirth));
      expect(updatedSettings.countryCode, equals('GB'));
      expect(updatedSettings.showLifeExpectancy, isFalse);
    });

    test('should implement equality correctly', () {
      // Arrange
      final dateOfBirth = DateTime(1990, 5, 15);

      final settings1 = UserSettings(dateOfBirth: dateOfBirth, countryCode: 'US', showLifeExpectancy: true);

      final settings2 = UserSettings(dateOfBirth: dateOfBirth, countryCode: 'US', showLifeExpectancy: true);

      final settings3 = UserSettings(dateOfBirth: dateOfBirth, countryCode: 'GB', showLifeExpectancy: true);

      // Act & Assert
      expect(settings1, equals(settings2));
      expect(settings1, isNot(equals(settings3)));
      expect(settings1.hashCode, equals(settings2.hashCode));
    });

    test('should have proper toString representation', () {
      // Arrange
      final settings = UserSettings(dateOfBirth: DateTime(1990, 5, 15), countryCode: 'US', showLifeExpectancy: true);

      // Act
      final stringRepresentation = settings.toString();

      // Assert
      expect(stringRepresentation, contains('1990-05-15'));
      expect(stringRepresentation, contains('US'));
      expect(stringRepresentation, contains('true'));
    });
  });
}
