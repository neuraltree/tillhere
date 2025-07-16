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

    // Group moods by day for this week
    final moodsByDay = <int, List<MoodEntry>>{};
    for (final mood in _moodEntries) {
      final moodDate = mood.timestampUtc.toLocal();
      if (moodDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          moodDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
        final dayIndex = moodDate.weekday - 1; // 0 = Monday, 6 = Sunday
        moodsByDay.putIfAbsent(dayIndex, () => []).add(mood);
      }
    }

    return Container(
      height: 60,
      child: Row(
        children: List.generate(7, (dayIndex) {
          final date = startOfWeek.add(Duration(days: dayIndex));
          final dayMoods = moodsByDay[dayIndex] ?? [];

          return Expanded(child: _buildDayBlock(context, date, dayMoods, dayIndex));
        }),
      ),
    );
  }

  Widget _buildDayBlock(BuildContext context, DateTime date, List<MoodEntry> dayMoods, int dayIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());

    Color blockColor;
    if (dayMoods.isNotEmpty) {
      // Calculate average mood for the day
      final averageMood = dayMoods.map((e) => e.moodScore).reduce((a, b) => a + b) / dayMoods.length;
      blockColor = MoodVocabulary.getColorForScore(averageMood);
    } else if (date.isAfter(DateTime.now())) {
      // Future days - light grey
      blockColor = Colors.grey.shade300;
    } else {
      // Past days with no data - darker grey
      blockColor = Colors.grey.shade400;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: blockColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: isDark ? Colors.white : Colors.black, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('E').format(date), // Mon, Tue, etc.
            style: TextStyle(color: _getTextColorForBackground(blockColor), fontSize: 10, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            date.day.toString(),
            style: TextStyle(color: _getTextColorForBackground(blockColor), fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (dayMoods.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              '${dayMoods.length}',
              style: TextStyle(color: _getTextColorForBackground(blockColor), fontSize: 8, fontWeight: FontWeight.w400),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if text should be light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
