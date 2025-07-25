import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/entities/mood_vocabulary.dart';
import '../../core/entities/mood_entry.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';

/// Weekly heatmap widget showing 7 blocks for the current week
/// Each block represents a day with consolidated mood data
class WeeklyHeatmapWidget extends StatefulWidget {
  const WeeklyHeatmapWidget({super.key});

  @override
  State<WeeklyHeatmapWidget> createState() => _WeeklyHeatmapWidgetState();
}

class _WeeklyHeatmapWidgetState extends State<WeeklyHeatmapWidget> {
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = false;
  String? _error;
  late final MoodRepositoryImpl _moodRepository;

  @override
  void initState() {
    super.initState();
    _moodRepository = MoodRepositoryImpl(DatabaseHelper());
    _loadMoodEntries();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMoodEntries();
  }

  Future<void> _loadMoodEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _moodRepository.getAllMoods();
      if (result.isSuccess) {
        setState(() {
          _moodEntries = result.data!;
        });
      } else {
        setState(() {
          _error = 'Failed to load mood data: ${result.failure}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'This Week',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Weekly heatmap
        if (_isLoading)
          _buildLoadingState(context)
        else if (_error != null)
          _buildErrorState(context)
        else
          _buildWeeklyGrid(context),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(height: 8),
            Text(
              'Loading week data...',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.orange, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWeeklyGrid(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final startOfWeekNormalized = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    // Group moods by day for this week
    final moodsByDay = <int, List<MoodEntry>>{};
    for (final mood in _moodEntries) {
      final moodDate = mood.timestampUtc.toLocal();
      final moodDateNormalized = DateTime(moodDate.year, moodDate.month, moodDate.day);

      // Check if mood date falls within this week (Monday to Sunday)
      final daysDifference = moodDateNormalized.difference(startOfWeekNormalized).inDays;
      if (daysDifference >= 0 && daysDifference < 7) {
        final dayIndex = daysDifference; // 0 = Monday, 6 = Sunday
        moodsByDay.putIfAbsent(dayIndex, () => []).add(mood);
      }
    }

    return Container(
      height: 60,
      child: Row(
        children: List.generate(7, (dayIndex) {
          final date = startOfWeekNormalized.add(Duration(days: dayIndex));
          final dayMoods = moodsByDay[dayIndex] ?? [];

          return Expanded(child: _buildDayBlock(context, date, dayMoods, dayIndex));
        }),
      ),
    );
  }

  Widget _buildDayBlock(BuildContext context, DateTime date, List<MoodEntry> dayMoods, int dayIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final dateNormalized = DateTime(date.year, date.month, date.day);
    final isToday = dateNormalized == todayNormalized;

    Color blockColor;
    if (dayMoods.isNotEmpty) {
      // Use last mood entry of the day (user preference)
      dayMoods.sort((a, b) => a.timestampUtc.compareTo(b.timestampUtc));
      final lastMood = dayMoods.last;
      blockColor = MoodVocabulary.getColorForScore(lastMood.moodScore.toDouble());
    } else if (dateNormalized.isAfter(todayNormalized)) {
      // Future days - light grey
      blockColor = Colors.grey.shade300;
    } else {
      // Past days with no data - darker grey
      blockColor = Colors.grey.shade400;
    }

    // Determine if this block has mood data (colored)
    final hasMoodData = dayMoods.isNotEmpty;

    return Transform.scale(
      // Make today's block slightly larger for subtle emphasis
      scale: isToday ? 1.05 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: blockColor,
          borderRadius: BorderRadius.circular(8),
          // Remove white border entirely
          // Add enhanced shadow effect for today's block and regular shadow for mood blocks
          boxShadow: isToday
              ? [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3)),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2, offset: const Offset(0, 1)),
                ]
              : hasMoodData
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E').format(date), // Mon, Tue, etc.
              style: TextStyle(
                color: _getTextColorForBackground(blockColor),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: _getTextColorForBackground(blockColor),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (dayMoods.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                '${dayMoods.length}',
                style: TextStyle(
                  color: _getTextColorForBackground(blockColor),
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if text should be light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
