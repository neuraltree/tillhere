import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/core/entities/life_expectancy.dart';

void main() {
  group('LifeExpectancy', () {
    test('should create a valid LifeExpectancy instance', () {
      // Arrange
      final fetchedAt = DateTime.now();
      
      // Act
      final lifeExpectancy = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: fetchedAt,
        source: 'World Bank API',
      );
      
      // Assert
      expect(lifeExpectancy.countryCode, equals('US'));
      expect(lifeExpectancy.yearsAtBirth, equals(78.5));
      expect(lifeExpectancy.year, equals(2023));
      expect(lifeExpectancy.fetchedAt, equals(fetchedAt));
      expect(lifeExpectancy.source, equals('World Bank API'));
    });

    test('should validate correctly for valid data', () {
      // Arrange
      final lifeExpectancy = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: DateTime.now(),
      );
      
      // Act & Assert
      expect(lifeExpectancy.isValid, isTrue);
    });

    test('should invalidate for invalid years at birth', () {
      // Arrange & Act
      final invalidNegative = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: -5.0,
        year: 2023,
        fetchedAt: DateTime.now(),
      );
      
      final invalidTooHigh = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 200.0,
        year: 2023,
        fetchedAt: DateTime.now(),
      );
      
      // Assert
      expect(invalidNegative.isValid, isFalse);
      expect(invalidTooHigh.isValid, isFalse);
    });

    test('should invalidate for invalid year', () {
      // Arrange & Act
      final invalidOldYear = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 1950,
        fetchedAt: DateTime.now(),
      );
      
      final invalidFutureYear = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: DateTime.now().year + 10,
        fetchedAt: DateTime.now(),
      );
      
      // Assert
      expect(invalidOldYear.isValid, isFalse);
      expect(invalidFutureYear.isValid, isFalse);
    });

    test('should invalidate for invalid country code', () {
      // Arrange & Act
      final invalidShortCode = LifeExpectancy(
        countryCode: 'U',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: DateTime.now(),
      );
      
      final invalidLongCode = LifeExpectancy(
        countryCode: 'USA',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: DateTime.now(),
      );
      
      // Assert
      expect(invalidShortCode.isValid, isFalse);
      expect(invalidLongCode.isValid, isFalse);
    });

    test('should check if data is fresh correctly', () {
      // Arrange
      final freshData = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: DateTime.now().subtract(const Duration(days: 10)),
      );
      
      final staleData = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: DateTime.now().subtract(const Duration(days: 40)),
      );
      
      // Act & Assert
      expect(freshData.isFresh, isTrue);
      expect(staleData.isFresh, isFalse);
    });

    test('should calculate total days at birth correctly', () {
      // Arrange
      final lifeExpectancy = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 80.0,
        year: 2023,
        fetchedAt: DateTime.now(),
      );
      
      // Act
      final totalDays = lifeExpectancy.totalDaysAtBirth;
      
      // Assert
      expect(totalDays, equals((80.0 * 365.25).round()));
    });

    test('should calculate total weeks at birth correctly', () {
      // Arrange
      final lifeExpectancy = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 80.0,
        year: 2023,
        fetchedAt: DateTime.now(),
      );
      
      // Act
      final totalWeeks = lifeExpectancy.totalWeeksAtBirth;
      
      // Assert
      expect(totalWeeks, equals((80.0 * 52.18).round()));
    });

    test('should implement equality correctly', () {
      // Arrange
      final fetchedAt = DateTime.now();
      
      final lifeExpectancy1 = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: fetchedAt,
        source: 'World Bank API',
      );
      
      final lifeExpectancy2 = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: fetchedAt,
        source: 'World Bank API',
      );
      
      final lifeExpectancy3 = LifeExpectancy(
        countryCode: 'GB',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: fetchedAt,
        source: 'World Bank API',
      );
      
      // Act & Assert
      expect(lifeExpectancy1, equals(lifeExpectancy2));
      expect(lifeExpectancy1, isNot(equals(lifeExpectancy3)));
      expect(lifeExpectancy1.hashCode, equals(lifeExpectancy2.hashCode));
    });

    test('should have proper toString representation', () {
      // Arrange
      final fetchedAt = DateTime.now();
      final lifeExpectancy = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: fetchedAt,
        source: 'World Bank API',
      );
      
      // Act
      final stringRepresentation = lifeExpectancy.toString();
      
      // Assert
      expect(stringRepresentation, contains('US'));
      expect(stringRepresentation, contains('78.5'));
      expect(stringRepresentation, contains('2023'));
      expect(stringRepresentation, contains('World Bank API'));
    });

    test('should use default source when not provided', () {
      // Arrange & Act
      final lifeExpectancy = LifeExpectancy(
        countryCode: 'US',
        yearsAtBirth: 78.5,
        year: 2023,
        fetchedAt: DateTime.now(),
      );
      
      // Assert
      expect(lifeExpectancy.source, equals('World Bank API'));
    });
  });
}
