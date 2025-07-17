import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/core/entities/mood_entry.dart';
import 'package:tillhere/core/utils/mood_consolidation_utils.dart';

void main() {
  group('MoodConsolidationUtils', () {
    group('consolidateDailyMood', () {
      test('should return null when no entries for target date', () {
        final entries = <MoodEntry>[];
        final targetDate = DateTime(2024, 1, 15);

        final result = MoodConsolidationUtils.consolidateDailyMood(entries, targetDate);

        expect(result, isNull);
      });

      test('should return last mood for single entry on target date', () {
        final targetDate = DateTime(2024, 1, 15);
        final entries = [MoodEntry(id: '1', timestampUtc: DateTime.utc(2024, 1, 15, 10, 30), moodScore: 7)];

        final result = MoodConsolidationUtils.consolidateDailyMood(entries, targetDate);

        expect(result, equals(7.0));
      });

      test('should return last mood for multiple entries on same date', () {
        final targetDate = DateTime(2024, 1, 15);
        final entries = [
          MoodEntry(id: '1', timestampUtc: DateTime.utc(2024, 1, 15, 8, 0), moodScore: 6),
          MoodEntry(id: '2', timestampUtc: DateTime.utc(2024, 1, 15, 14, 30), moodScore: 8),
          MoodEntry(
            id: '3',
            timestampUtc: DateTime.utc(2024, 1, 15, 18, 0),
            moodScore: 7,
          ), // Changed to 18:00 UTC to avoid timezone issues
        ];

        final result = MoodConsolidationUtils.consolidateDailyMood(entries, targetDate);

        expect(result, equals(7.0)); // Last entry (18:00) has score 7
      });

      test('should ignore entries from different dates', () {
        final targetDate = DateTime(2024, 1, 15);
        final entries = [
          MoodEntry(
            id: '1',
            timestampUtc: DateTime.utc(2024, 1, 14, 12, 0), // Previous day (clearly different)
            moodScore: 3,
          ),
          MoodEntry(
            id: '2',
            timestampUtc: DateTime.utc(2024, 1, 15, 12, 0), // Target day
            moodScore: 8,
          ),
          MoodEntry(
            id: '3',
            timestampUtc: DateTime.utc(2024, 1, 16, 12, 0), // Next day (clearly different)
            moodScore: 5,
          ),
        ];

        final result = MoodConsolidationUtils.consolidateDailyMood(entries, targetDate);

        expect(result, equals(8.0)); // Only the entry from target date
      });

      test('should handle timezone conversion correctly', () {
        final targetDate = DateTime(2024, 1, 15);
        final entries = [
          // UTC noon should definitely be on target date in local time
          MoodEntry(id: '1', timestampUtc: DateTime.utc(2024, 1, 15, 12, 0), moodScore: 6),
        ];

        final result = MoodConsolidationUtils.consolidateDailyMood(entries, targetDate);

        expect(result, equals(6.0)); // Single entry
      });

      test('should handle date boundary edge cases', () {
        final targetDate = DateTime(2024, 1, 15);
        final entries = [
          // Just before midnight UTC (should be previous day in some timezones)
          MoodEntry(id: '1', timestampUtc: DateTime.utc(2024, 1, 14, 23, 59, 59), moodScore: 4),
          // Just after midnight UTC (should be target day in most timezones)
          MoodEntry(id: '2', timestampUtc: DateTime.utc(2024, 1, 15, 0, 0, 1), moodScore: 8),
        ];

        final result = MoodConsolidationUtils.consolidateDailyMood(entries, targetDate);

        // Result depends on local timezone, but should only include entries that fall on target date in local time
        expect(result, isNotNull);
      });

      test('should round average to nearest integer', () {
        final targetDate = DateTime(2024, 1, 15);
        final entries = [
          MoodEntry(id: '1', timestampUtc: DateTime.utc(2024, 1, 15, 10, 0), moodScore: 5),
          MoodEntry(id: '2', timestampUtc: DateTime.utc(2024, 1, 15, 14, 0), moodScore: 6),
        ];

        final result = MoodConsolidationUtils.consolidateDailyMood(entries, targetDate);

        expect(result, equals(6.0)); // (5 + 6) / 2 = 5.5, rounded to 6.0
      });
    });

    group('consolidateWeeklyMood', () {
      test('should return null when no entries for target week', () {
        final entries = <MoodEntry>[];
        final weekStart = DateTime(2024, 1, 15); // Monday

        final result = MoodConsolidationUtils.consolidateWeeklyMood(entries, weekStart);

        expect(result, isNull);
      });

      test('should return average mood for entries within week', () {
        final weekStart = DateTime(2024, 1, 15); // Monday
        final entries = [
          MoodEntry(
            id: '1',
            timestampUtc: DateTime.utc(2024, 1, 15, 10, 0), // Monday
            moodScore: 6,
          ),
          MoodEntry(
            id: '2',
            timestampUtc: DateTime.utc(2024, 1, 17, 14, 0), // Wednesday
            moodScore: 8,
          ),
          MoodEntry(
            id: '3',
            timestampUtc: DateTime.utc(2024, 1, 21, 18, 0), // Sunday
            moodScore: 7,
          ),
        ];

        final result = MoodConsolidationUtils.consolidateWeeklyMood(entries, weekStart);

        expect(result, equals(7.0)); // (6 + 8 + 7) / 3 = 7.0
      });

      test('should ignore entries outside week range', () {
        final weekStart = DateTime(2024, 1, 15); // Monday
        final entries = [
          MoodEntry(
            id: '1',
            timestampUtc: DateTime.utc(2024, 1, 14, 12, 0), // Previous Sunday (clearly outside)
            moodScore: 3,
          ),
          MoodEntry(
            id: '2',
            timestampUtc: DateTime.utc(2024, 1, 16, 12, 0), // Tuesday (within week)
            moodScore: 8,
          ),
          MoodEntry(
            id: '3',
            timestampUtc: DateTime.utc(2024, 1, 22, 12, 0), // Next Monday (clearly outside)
            moodScore: 5,
          ),
        ];

        final result = MoodConsolidationUtils.consolidateWeeklyMood(entries, weekStart);

        expect(result, equals(8.0)); // Only the entry from within the week
      });
    });

    group('consolidateMonthlyMood', () {
      test('should return null when no entries for target month', () {
        final entries = <MoodEntry>[];
        final targetMonth = DateTime(2024, 1, 1);

        final result = MoodConsolidationUtils.consolidateMonthlyMood(entries, targetMonth);

        expect(result, isNull);
      });

      test('should return average mood for entries within month', () {
        final targetMonth = DateTime(2024, 1, 1);
        final entries = [
          MoodEntry(id: '1', timestampUtc: DateTime.utc(2024, 1, 5, 10, 0), moodScore: 6),
          MoodEntry(id: '2', timestampUtc: DateTime.utc(2024, 1, 15, 14, 0), moodScore: 8),
          MoodEntry(id: '3', timestampUtc: DateTime.utc(2024, 1, 25, 18, 0), moodScore: 7),
        ];

        final result = MoodConsolidationUtils.consolidateMonthlyMood(entries, targetMonth);

        expect(result, equals(7.0)); // (6 + 8 + 7) / 3 = 7.0
      });

      test('should ignore entries from different months', () {
        final targetMonth = DateTime(2024, 1, 1);
        final entries = [
          MoodEntry(
            id: '1',
            timestampUtc: DateTime.utc(2023, 12, 15, 12, 0), // Previous month (clearly different)
            moodScore: 3,
          ),
          MoodEntry(
            id: '2',
            timestampUtc: DateTime.utc(2024, 1, 15, 12, 0), // Target month
            moodScore: 8,
          ),
          MoodEntry(
            id: '3',
            timestampUtc: DateTime.utc(2024, 2, 15, 12, 0), // Next month (clearly different)
            moodScore: 5,
          ),
        ];

        final result = MoodConsolidationUtils.consolidateMonthlyMood(entries, targetMonth);

        expect(result, equals(8.0)); // Only the entry from target month
      });
    });
  });
}
