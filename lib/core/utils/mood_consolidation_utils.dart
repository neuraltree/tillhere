import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../entities/mood_entry.dart';
import '../entities/mood_vocabulary.dart';

/// Utility class for consolidating mood data across different time periods
/// Following Clean Architecture principles - core utilities
class MoodConsolidationUtils {
  /// Consolidate mood entries for a specific day
  /// Returns the average mood score for that day rounded to nearest integer, or null if no entries
  static double? consolidateDailyMood(List<MoodEntry> entries, DateTime targetDate) {
    final dayEntries = entries.where((entry) {
      final entryDate = entry.timestampUtc.toLocal();
      return DateFormat('yyyy-MM-dd').format(entryDate) == DateFormat('yyyy-MM-dd').format(targetDate);
    }).toList();

    if (dayEntries.isEmpty) return null;

    // Calculate average mood score for the day and round to nearest integer
    final totalScore = dayEntries.map((entry) => entry.moodScore.toDouble()).reduce((a, b) => a + b);
    final averageScore = totalScore / dayEntries.length;
    return averageScore.roundToDouble();
  }

  /// Consolidate mood entries for a specific week
  /// Returns the average mood score for that week rounded to nearest integer, or null if no entries
  static double? consolidateWeeklyMood(List<MoodEntry> entries, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));

    final weekEntries = entries.where((entry) {
      final entryDate = entry.timestampUtc.toLocal();
      return entryDate.isAfter(weekStart.subtract(const Duration(days: 1))) && entryDate.isBefore(weekEnd);
    }).toList();

    if (weekEntries.isEmpty) return null;

    // Calculate average mood score for the week and round to nearest integer
    final totalScore = weekEntries.map((entry) => entry.moodScore.toDouble()).reduce((a, b) => a + b);
    final averageScore = totalScore / weekEntries.length;
    return averageScore.roundToDouble();
  }

  /// Consolidate mood entries for a specific month
  /// Returns the average mood score for that month rounded to nearest integer, or null if no entries
  static double? consolidateMonthlyMood(List<MoodEntry> entries, DateTime targetMonth) {
    final monthEntries = entries.where((entry) {
      final entryDate = entry.timestampUtc.toLocal();
      return entryDate.year == targetMonth.year && entryDate.month == targetMonth.month;
    }).toList();

    if (monthEntries.isEmpty) return null;

    // Calculate average mood score for the month and round to nearest integer
    final totalScore = monthEntries.map((entry) => entry.moodScore.toDouble()).reduce((a, b) => a + b);
    final averageScore = totalScore / monthEntries.length;
    return averageScore.roundToDouble();
  }

  /// Consolidate mood entries for a specific year
  /// Returns the average mood score for that year rounded to nearest integer, or null if no entries
  static double? consolidateYearlyMood(List<MoodEntry> entries, int targetYear) {
    final yearEntries = entries.where((entry) {
      final entryDate = entry.timestampUtc.toLocal();
      return entryDate.year == targetYear;
    }).toList();

    if (yearEntries.isEmpty) return null;

    // Calculate average mood score for the year and round to nearest integer
    final totalScore = yearEntries.map((entry) => entry.moodScore.toDouble()).reduce((a, b) => a + b);
    final averageScore = totalScore / yearEntries.length;
    return averageScore.roundToDouble();
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
