import 'package:flutter/material.dart';

import '../entities/mood_entry.dart';
import '../entities/mood_vocabulary.dart';

/// Utility class for consolidating mood data across different time periods
/// Following Clean Architecture principles - core utilities
class MoodConsolidationUtils {
  /// Consolidate mood entries for a specific day
  /// Returns the last mood score for that day (user preference), or null if no entries
  static double? consolidateDailyMood(List<MoodEntry> entries, DateTime targetDate) {
    // Normalize target date to start of day for consistent comparison
    final targetDateNormalized = DateTime(targetDate.year, targetDate.month, targetDate.day);

    final dayEntries = entries.where((entry) {
      final entryDate = entry.timestampUtc.toLocal();
      final entryDateNormalized = DateTime(entryDate.year, entryDate.month, entryDate.day);
      return entryDateNormalized == targetDateNormalized;
    }).toList();

    if (dayEntries.isEmpty) return null;

    // Sort by timestamp to get the last entry of the day (user preference)
    dayEntries.sort((a, b) => a.timestampUtc.compareTo(b.timestampUtc));
    final lastEntry = dayEntries.last;
    return lastEntry.moodScore.toDouble();
  }

  /// Consolidate mood entries for a specific week
  /// Returns the last mood score for that week (user preference), or null if no entries
  static double? consolidateWeeklyMood(List<MoodEntry> entries, DateTime weekStart) {
    // Normalize week start to start of day
    final weekStartNormalized = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekEndNormalized = weekStartNormalized.add(const Duration(days: 7));

    final weekEntries = entries.where((entry) {
      final entryDate = entry.timestampUtc.toLocal();
      final entryDateNormalized = DateTime(entryDate.year, entryDate.month, entryDate.day);
      return entryDateNormalized.isAtSameMomentAs(weekStartNormalized) ||
          (entryDateNormalized.isAfter(weekStartNormalized) && entryDateNormalized.isBefore(weekEndNormalized));
    }).toList();

    if (weekEntries.isEmpty) return null;

    // Sort by timestamp to get the last entry of the week (user preference)
    weekEntries.sort((a, b) => a.timestampUtc.compareTo(b.timestampUtc));
    final lastEntry = weekEntries.last;
    return lastEntry.moodScore.toDouble();
  }

  /// Consolidate mood entries for a specific month
  /// Returns the last mood score for that month (user preference), or null if no entries
  static double? consolidateMonthlyMood(List<MoodEntry> entries, DateTime targetMonth) {
    final monthEntries = entries.where((entry) {
      final entryDate = entry.timestampUtc.toLocal();
      return entryDate.year == targetMonth.year && entryDate.month == targetMonth.month;
    }).toList();

    if (monthEntries.isEmpty) return null;

    // Sort by timestamp to get the last entry of the month (user preference)
    monthEntries.sort((a, b) => a.timestampUtc.compareTo(b.timestampUtc));
    final lastEntry = monthEntries.last;
    return lastEntry.moodScore.toDouble();
  }

  /// Consolidate mood entries for a specific year
  /// Returns the last mood score for that year (user preference), or null if no entries
  static double? consolidateYearlyMood(List<MoodEntry> entries, int targetYear) {
    final yearEntries = entries.where((entry) {
      final entryDate = entry.timestampUtc.toLocal();
      return entryDate.year == targetYear;
    }).toList();

    if (yearEntries.isEmpty) return null;

    // Sort by timestamp to get the last entry of the year (user preference)
    yearEntries.sort((a, b) => a.timestampUtc.compareTo(b.timestampUtc));
    final lastEntry = yearEntries.last;
    return lastEntry.moodScore.toDouble();
  }

  /// Get color for consolidated mood score
  /// Returns appropriate color based on mood vocabulary, or grey for no data
  static Color getConsolidatedMoodColor(double? moodScore) {
    if (moodScore == null) return Colors.grey.shade400;
    return MoodVocabulary.getColorForScore(moodScore);
  }

  /// Get current week's start date (Monday)
  static DateTime getCurrentWeekStart() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  /// Get current month's start date
  static DateTime getCurrentMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Get days in current month
  static int getDaysInCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  /// Get all days in current week (7 days starting from Monday)
  static List<DateTime> getCurrentWeekDays() {
    final weekStart = getCurrentWeekStart();
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  /// Get all days in current month
  static List<DateTime> getCurrentMonthDays() {
    final monthStart = getCurrentMonthStart();
    final daysInMonth = getDaysInCurrentMonth();
    return List.generate(daysInMonth, (index) => monthStart.add(Duration(days: index)));
  }

  /// Get all years from birth year to death year (entire remaining life)
  static List<int> getLifetimeYears(DateTime birthDate, {DateTime? deathDate}) {
    final birthYear = birthDate.year;
    final endYear = deathDate?.year ?? DateTime.now().year;
    return List.generate(endYear - birthYear + 1, (index) => birthYear + index);
  }

  /// Check if a date is in the future
  static bool isFutureDate(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day));
  }

  /// Check if a year is in the future
  static bool isFutureYear(int year) {
    return year > DateTime.now().year;
  }

  /// Get color for future periods (light grey)
  static Color getFutureColor() {
    return Colors.grey.shade200;
  }

  /// Get color for past periods with no data (darker grey)
  static Color getPastNoDataColor() {
    return Colors.grey.shade400;
  }
}
