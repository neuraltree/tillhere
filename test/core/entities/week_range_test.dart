import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/core/entities/week_range.dart';

void main() {
  group('WeekRange', () {
    test('should create a valid WeekRange instance', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      // Act
      final weekRange = WeekRange(
        startDate: startDate,
        endDate: endDate,
        weekNumber: 0,
        isPast: false,
        isCurrent: true,
      );

      // Assert
      expect(weekRange.startDate, equals(startDate));
      expect(weekRange.endDate, equals(endDate));
      expect(weekRange.weekNumber, equals(0));
      expect(weekRange.isPast, isFalse);
      expect(weekRange.isCurrent, isTrue);
    });

    test('should create WeekRange from week number correctly', () {
      // Arrange
      final birthDate = DateTime(2024, 1, 1); // Monday

      // Act
      final weekRange = WeekRange.fromWeekNumber(0, birthDate);

      // Assert
      expect(weekRange.weekNumber, equals(0));
      expect(weekRange.startDate.weekday, equals(DateTime.monday));
      expect(weekRange.endDate.weekday, equals(DateTime.sunday));
    });

    test('should calculate week start as Monday', () {
      // Arrange
      final birthDate = DateTime(2024, 1, 3); // Wednesday

      // Act
      final weekRange = WeekRange.fromWeekNumber(0, birthDate);

      // Assert
      expect(weekRange.startDate.weekday, equals(DateTime.monday));
      expect(weekRange.startDate, equals(DateTime(2024, 1, 1))); // Previous Monday
    });

    test('should calculate week end as Sunday', () {
      // Arrange
      final birthDate = DateTime(2024, 1, 1);

      // Act
      final weekRange = WeekRange.fromWeekNumber(0, birthDate);

      // Assert
      expect(weekRange.endDate.weekday, equals(DateTime.sunday));
      expect(weekRange.endDate.hour, equals(23));
      expect(weekRange.endDate.minute, equals(59));
      expect(weekRange.endDate.second, equals(59));
    });

    test('should determine if week is past correctly', () {
      // Arrange
      final birthDate = DateTime.now().subtract(const Duration(days: 365));

      // Act
      final pastWeek = WeekRange.fromWeekNumber(0, birthDate);
      final futureWeek = WeekRange.fromWeekNumber(100, birthDate);

      // Assert
      expect(pastWeek.isPast, isTrue);
      expect(futureWeek.isPast, isFalse);
    });

    test('should determine if week is current correctly', () {
      // Arrange
      final now = DateTime.now();
      final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final birthDate = currentWeekStart.subtract(const Duration(days: 7));

      // Act
      final currentWeek = WeekRange.fromWeekNumber(1, birthDate);
      final pastWeek = WeekRange.fromWeekNumber(0, birthDate);

      // Assert
      expect(currentWeek.isCurrent, isTrue);
      expect(pastWeek.isCurrent, isFalse);
    });

    test('should generate future weeks correctly', () {
      // Arrange
      final now = DateTime.now();
      final birthDate = now.subtract(const Duration(days: 365)); // 1 year ago
      final deathDate = now.add(const Duration(days: 35)); // About 5 weeks from now

      // Act
      final weeks = WeekRange.generateFutureWeeks(birthDate, deathDate);

      // Assert
      expect(weeks, isNotEmpty);
      expect(weeks.length, greaterThan(0));
      expect(weeks.first.weekNumber, greaterThanOrEqualTo(0));
      expect(weeks.last.startDate.isBefore(deathDate), isTrue);
    });

    test('should generate future weeks from specific start date', () {
      // Arrange
      final now = DateTime.now();
      final birthDate = now.subtract(const Duration(days: 365)); // 1 year ago
      final deathDate = now.add(const Duration(days: 70)); // ~10 weeks from now
      final startFrom = now.add(const Duration(days: 7)); // 1 week from now

      // Act
      final weeks = WeekRange.generateFutureWeeks(birthDate, deathDate, startFrom: startFrom);

      // Assert
      expect(weeks, isNotEmpty);
      expect(weeks.first.startDate.isAfter(startFrom.subtract(const Duration(days: 7))), isTrue);
    });

    test('should exclude completely past weeks from generation', () {
      // Arrange
      final birthDate = DateTime.now().subtract(const Duration(days: 365));
      final deathDate = DateTime.now().add(const Duration(days: 365));

      // Act
      final weeks = WeekRange.generateFutureWeeks(birthDate, deathDate);

      // Assert
      expect(weeks, isNotEmpty);
      expect(weeks.every((week) => !week.isPast || week.isCurrent), isTrue);
    });

    test('should calculate duration correctly', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7, 23, 59, 59, 999);

      final weekRange = WeekRange(
        startDate: startDate,
        endDate: endDate,
        weekNumber: 0,
        isPast: false,
        isCurrent: false,
      );

      // Act
      final duration = weekRange.duration;

      // Assert
      expect(duration.inDays, equals(6));
      expect(duration.inHours, greaterThan(6 * 24));
    });

    test('should check if date is contained in week', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7, 23, 59, 59, 999);

      final weekRange = WeekRange(
        startDate: startDate,
        endDate: endDate,
        weekNumber: 0,
        isPast: false,
        isCurrent: false,
      );

      // Act & Assert
      expect(weekRange.contains(DateTime(2024, 1, 3)), isTrue);
      expect(weekRange.contains(DateTime(2024, 1, 1)), isTrue);
      expect(weekRange.contains(DateTime(2024, 1, 7, 23, 59, 59, 999)), isTrue);
      expect(weekRange.contains(DateTime(2023, 12, 31)), isFalse);
      expect(weekRange.contains(DateTime(2024, 1, 8)), isFalse);
    });

    test('should format range correctly', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7, 23, 59, 59, 999);

      final weekRange = WeekRange(
        startDate: startDate,
        endDate: endDate,
        weekNumber: 0,
        isPast: false,
        isCurrent: false,
      );

      // Act
      final formatted = weekRange.formattedRange;

      // Assert
      expect(formatted, equals('1/1/2024 - 7/1/2024'));
    });

    test('should implement equality correctly', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      final weekRange1 = WeekRange(
        startDate: startDate,
        endDate: endDate,
        weekNumber: 0,
        isPast: false,
        isCurrent: true,
      );

      final weekRange2 = WeekRange(
        startDate: startDate,
        endDate: endDate,
        weekNumber: 0,
        isPast: false,
        isCurrent: true,
      );

      final weekRange3 = WeekRange(
        startDate: startDate,
        endDate: endDate,
        weekNumber: 1,
        isPast: false,
        isCurrent: true,
      );

      // Act & Assert
      expect(weekRange1, equals(weekRange2));
      expect(weekRange1, isNot(equals(weekRange3)));
      expect(weekRange1.hashCode, equals(weekRange2.hashCode));
    });

    test('should have proper toString representation', () {
      // Arrange
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 7);

      final weekRange = WeekRange(
        startDate: startDate,
        endDate: endDate,
        weekNumber: 0,
        isPast: false,
        isCurrent: true,
      );

      // Act
      final stringRepresentation = weekRange.toString();

      // Assert
      expect(stringRepresentation, contains('weekNumber: 0'));
      expect(stringRepresentation, contains('2024-01-01'));
      expect(stringRepresentation, contains('2024-01-07'));
      expect(stringRepresentation, contains('isPast: false'));
      expect(stringRepresentation, contains('isCurrent: true'));
    });

    test('should handle edge case of birth date on different weekdays', () {
      // Test birth dates on different days of the week
      for (int weekday = 1; weekday <= 7; weekday++) {
        // Arrange
        final birthDate = DateTime(2024, 1, weekday); // Jan 1-7, 2024 covers all weekdays

        // Act
        final weekRange = WeekRange.fromWeekNumber(0, birthDate);

        // Assert
        expect(weekRange.startDate.weekday, equals(DateTime.monday));
        expect(weekRange.endDate.weekday, equals(DateTime.sunday));
        expect(
          weekRange.startDate.isBefore(weekRange.endDate) || weekRange.startDate.isAtSameMomentAs(weekRange.endDate),
          isTrue,
        );
      }
    });
  });
}
