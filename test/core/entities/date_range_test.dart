import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/core/entities/date_range.dart';

void main() {
  group('DateRange', () {
    test('should create a valid DateRange instance', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      // Act
      final dateRange = DateRange(startDate: startDate, endDate: endDate);

      // Assert
      expect(dateRange.startDate, equals(startDate));
      expect(dateRange.endDate, equals(endDate));
    });

    test('should validate correctly for valid date range', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final dateRange = DateRange(startDate: startDate, endDate: endDate);

      // Act & Assert
      expect(dateRange.isValid, isTrue);
    });

    test('should validate correctly for same start and end date', () {
      // Arrange
      final date = DateTime(2024, 1, 1);
      final dateRange = DateRange(startDate: date, endDate: date);

      // Act & Assert
      expect(dateRange.isValid, isTrue);
    });

    test('should invalidate for end date before start date', () {
      // Arrange
      final startDate = DateTime(2024, 1, 7);
      final endDate = DateTime(2024, 1, 1);
      final dateRange = DateRange(startDate: startDate, endDate: endDate);

      // Act & Assert
      expect(dateRange.isValid, isFalse);
    });

    test('should calculate duration correctly', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 8);
      final dateRange = DateRange(startDate: startDate, endDate: endDate);

      // Act
      final duration = dateRange.duration;

      // Assert
      expect(duration.inDays, equals(7));
    });

    test('should check if date is contained in range', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final dateRange = DateRange(startDate: startDate, endDate: endDate);

      final dateInRange = DateTime(2024, 1, 3);
      final dateBeforeRange = DateTime(2023, 12, 31);
      final dateAfterRange = DateTime(2024, 1, 8);

      // Act & Assert
      expect(dateRange.contains(dateInRange), isTrue);
      expect(dateRange.contains(startDate), isTrue); // Inclusive start
      expect(dateRange.contains(endDate), isTrue); // Inclusive end
      expect(dateRange.contains(dateBeforeRange), isFalse);
      expect(dateRange.contains(dateAfterRange), isFalse);
    });

    test('should create today date range correctly', () {
      // Act
      final todayRange = DateRange.today();

      // Assert
      final now = DateTime.now();
      final expectedStart = DateTime(now.year, now.month, now.day);
      final expectedEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      expect(todayRange.startDate, equals(expectedStart));
      expect(todayRange.endDate, equals(expectedEnd));
      expect(todayRange.isValid, isTrue);
    });

    test('should create this week date range correctly', () {
      // Act
      final weekRange = DateRange.thisWeek();

      // Assert
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final expectedStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      expect(weekRange.startDate, equals(expectedStart));
      expect(weekRange.isValid, isTrue);
      expect(weekRange.duration.inDays, equals(6)); // 6 days + some hours/minutes
    });

    test('should create this month date range correctly', () {
      // Act
      final monthRange = DateRange.thisMonth();

      // Assert
      final now = DateTime.now();
      final expectedStart = DateTime(now.year, now.month, 1);
      final expectedEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);

      expect(monthRange.startDate, equals(expectedStart));
      expect(monthRange.endDate, equals(expectedEnd));
      expect(monthRange.isValid, isTrue);
    });

    test('should create last N days range correctly', () {
      // Arrange
      const days = 7;

      // Act
      final lastDaysRange = DateRange.lastDays(days);

      // Assert
      final now = DateTime.now();
      final expectedEnd = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      final expectedStartDate = expectedEnd.subtract(Duration(days: days - 1));
      final expectedStart = DateTime(expectedStartDate.year, expectedStartDate.month, expectedStartDate.day);

      expect(lastDaysRange.startDate, equals(expectedStart));
      expect(lastDaysRange.endDate, equals(expectedEnd));
      expect(lastDaysRange.isValid, isTrue);
    });

    test('should implement equality correctly', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      final dateRange1 = DateRange(startDate: startDate, endDate: endDate);
      final dateRange2 = DateRange(startDate: startDate, endDate: endDate);
      final dateRange3 = DateRange(startDate: startDate, endDate: DateTime(2024, 1, 8));

      // Act & Assert
      expect(dateRange1, equals(dateRange2));
      expect(dateRange1, isNot(equals(dateRange3)));
      expect(dateRange1.hashCode, equals(dateRange2.hashCode));
    });

    test('should have proper toString representation', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);
      final dateRange = DateRange(startDate: startDate, endDate: endDate);

      // Act
      final stringRepresentation = dateRange.toString();

      // Assert
      expect(stringRepresentation, contains('DateRange'));
      expect(stringRepresentation, contains('2024-01-01'));
      expect(stringRepresentation, contains('2024-01-07'));
    });

    test('should handle edge case of single day range', () {
      // Arrange
      final date = DateTime(2024, 1, 1, 12, 0, 0);
      final dateRange = DateRange(startDate: date, endDate: date);

      // Act & Assert
      expect(dateRange.isValid, isTrue);
      expect(dateRange.duration, equals(Duration.zero));
      expect(dateRange.contains(date), isTrue);
    });

    test('should handle microsecond precision', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1, 0, 0, 0, 0, 1);
      final endDate = DateTime(2024, 1, 1, 0, 0, 0, 0, 2);
      final dateRange = DateRange(startDate: startDate, endDate: endDate);

      // Act & Assert
      expect(dateRange.isValid, isTrue);
      expect(dateRange.duration.inMicroseconds, equals(1));
    });
  });
}
