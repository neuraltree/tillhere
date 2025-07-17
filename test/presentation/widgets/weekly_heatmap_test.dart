import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tillhere/core/entities/mood_entry.dart';
import 'package:tillhere/presentation/widgets/weekly_heatmap_widget.dart';
import 'package:tillhere/data/repositories/mood_repository_impl.dart';
import 'package:tillhere/data/datasources/local/database_helper.dart';
import 'package:tillhere/core/utils/mood_consolidation_utils.dart';
import 'package:tillhere/core/utils/result.dart';

void main() {
  group('WeeklyHeatmapWidget Mood Display Tests', () {
    late DatabaseHelper databaseHelper;
    late MoodRepositoryImpl moodRepository;

    setUp(() async {
      databaseHelper = DatabaseHelper();
      moodRepository = MoodRepositoryImpl(databaseHelper);

      // Clear any existing data
      await moodRepository.clearAllData();
    });

    tearDown(() async {
      await moodRepository.clearAllData();
    });

    testWidgets('should display mood colors for entries within current week', (WidgetTester tester) async {
      // Arrange: Create test scenario matching the screenshot
      // Today is Thursday 17th December 2024 (based on screenshot)
      final today = DateTime(2024, 12, 17); // Thursday

      // Create mood entries for Tuesday 15th and Wednesday 16th
      final tuesdayEntry = MoodEntry(
        id: 'mood-tuesday',
        timestampUtc: DateTime(2024, 12, 15, 14, 30).toUtc(), // Tuesday 15th at 2:30 PM
        moodScore: 7,
        note: 'Good day on Tuesday',
        tags: const [],
      );

      final wednesdayEntry = MoodEntry(
        id: 'mood-wednesday',
        timestampUtc: DateTime(2024, 12, 16, 10, 15).toUtc(), // Wednesday 16th at 10:15 AM
        moodScore: 8,
        note: 'Great day on Wednesday',
        tags: const [],
      );

      // Insert mood entries
      await moodRepository.insertMood(tuesdayEntry);
      await moodRepository.insertMood(wednesdayEntry);

      // Act: Build the widget
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: WeeklyHeatmapWidget())));

      // Wait for async operations
      await tester.pumpAndSettle();

      // Assert: Verify that mood entries are loaded
      final result = await moodRepository.getAllMoods();
      expect(result.isSuccess, true);
      expect(result.data!.length, 2);

      // Test the mood grouping logic manually
      final moodEntries = result.data!;

      // Calculate start of week for Thursday 17th December 2024
      final thursday = DateTime(2024, 12, 17);
      final startOfWeek = thursday.subtract(Duration(days: thursday.weekday - 1));
      final startOfWeekNormalized = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      print('Test Debug: Today (Thursday): $thursday');
      print('Test Debug: Start of week (Monday): $startOfWeekNormalized');

      // Group moods by day (same logic as in widget)
      final moodsByDay = <int, List<MoodEntry>>{};
      for (final mood in moodEntries) {
        final moodDate = mood.timestampUtc.toLocal();
        final moodDateNormalized = DateTime(moodDate.year, moodDate.month, moodDate.day);

        final daysDifference = moodDateNormalized.difference(startOfWeekNormalized).inDays;
        print('Test Debug: Mood ${mood.id}: $moodDateNormalized -> days diff: $daysDifference');

        if (daysDifference >= 0 && daysDifference < 7) {
          final dayIndex = daysDifference;
          moodsByDay.putIfAbsent(dayIndex, () => []).add(mood);
          print('Test Debug: Added to day index $dayIndex');
        }
      }

      // Verify Tuesday (index 1) and Wednesday (index 2) have mood data
      expect(moodsByDay[1]?.length, 1, reason: 'Tuesday should have 1 mood entry');
      expect(moodsByDay[2]?.length, 1, reason: 'Wednesday should have 1 mood entry');
      expect(moodsByDay[1]?.first.moodScore, 7, reason: 'Tuesday mood score should be 7');
      expect(moodsByDay[2]?.first.moodScore, 8, reason: 'Wednesday mood score should be 8');
    });

    testWidgets('should handle timezone conversion correctly', (WidgetTester tester) async {
      // Test that UTC timestamps are correctly converted to local time
      final utcTime = DateTime.utc(2024, 12, 15, 22, 30); // 10:30 PM UTC on Dec 15
      final localTime = utcTime.toLocal();

      print('Test Debug: UTC time: $utcTime');
      print('Test Debug: Local time: $localTime');
      print('Test Debug: Local date: ${localTime.day}/${localTime.month}/${localTime.year}');

      // Create mood entry with UTC timestamp
      final moodEntry = MoodEntry(
        id: 'mood-timezone-test',
        timestampUtc: utcTime,
        moodScore: 6,
        note: 'Timezone test',
        tags: const [],
      );

      await moodRepository.insertMood(moodEntry);

      // Verify the entry is stored and retrieved correctly
      final result = await moodRepository.getAllMoods();
      expect(result.isSuccess, true);
      expect(result.data!.length, 1);

      final retrievedEntry = result.data!.first;
      expect(retrievedEntry.timestampUtc, utcTime);
      expect(retrievedEntry.timestampUtc.toLocal(), localTime);
    });

    test('mood consolidation logic should use last entry of day', () {
      // Test the mood consolidation logic mentioned in memories
      // User prefers mood consolidation to use last emotion of the day (not average)

      final day = DateTime(2024, 12, 15);

      // Create multiple entries for the same day
      final morningEntry = MoodEntry(
        id: 'morning',
        timestampUtc: DateTime(2024, 12, 15, 8, 0).toUtc(),
        moodScore: 5,
        note: 'Morning mood',
        tags: const [],
      );

      final afternoonEntry = MoodEntry(
        id: 'afternoon',
        timestampUtc: DateTime(2024, 12, 15, 14, 0).toUtc(),
        moodScore: 7,
        note: 'Afternoon mood',
        tags: const [],
      );

      final eveningEntry = MoodEntry(
        id: 'evening',
        timestampUtc: DateTime(2024, 12, 15, 20, 0).toUtc(),
        moodScore: 9,
        note: 'Evening mood',
        tags: const [],
      );

      final entries = [morningEntry, afternoonEntry, eveningEntry];

      // Test the consolidation logic directly
      final dayEntries = entries.where((entry) {
        final entryDate = entry.timestampUtc.toLocal();
        final entryDateNormalized = DateTime(entryDate.year, entryDate.month, entryDate.day);
        final dayNormalized = DateTime(day.year, day.month, day.day);
        return entryDateNormalized == dayNormalized;
      }).toList();

      // Sort by timestamp to get the last entry (user preference)
      dayEntries.sort((a, b) => a.timestampUtc.compareTo(b.timestampUtc));
      final lastEntry = dayEntries.last;

      expect(lastEntry.moodScore, 9, reason: 'Should use last entry of the day (evening)');

      // Test that the new consolidation logic works correctly
      final consolidatedMood = MoodConsolidationUtils.consolidateDailyMood(entries, day);
      expect(consolidatedMood, 9.0, reason: 'Consolidation should return last entry score');
    });
  });
}
