import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/entities/mood_vocabulary.dart';
import '../../core/entities/user_settings.dart';
import '../../core/entities/mood_entry.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';
import '../providers/settings_provider.dart';
import 'heatmap_setup_dialog.dart';

/// Widget that displays the life heatmap visualization
/// Shows "Past is Past" section in grey and future weeks as colored dots based on mood data
class LifeHeatmapWidget extends StatefulWidget {
  const LifeHeatmapWidget({super.key});

  @override
  State<LifeHeatmapWidget> createState() => _LifeHeatmapWidgetState();
}

class _LifeHeatmapWidgetState extends State<LifeHeatmapWidget> {
  List<MoodEntry> _moodEntries = [];
  bool _isLoadingMoods = false;
  String? _moodError;
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
    // Refresh mood data when dependencies change (e.g., when new mood is added)
    _loadMoodEntries();
  }

  Future<void> _loadMoodEntries() async {
    setState(() {
      _isLoadingMoods = true;
      _moodError = null;
    });

    try {
      final result = await _moodRepository.getAllMoods();
      if (result.isSuccess) {
        setState(() {
          _moodEntries = result.data!;
        });
      } else {
        setState(() {
          _moodError = 'Failed to load mood data: ${result.failure}';
        });
      }
    } catch (e) {
      setState(() {
        _moodError = 'Unexpected error loading moods: $e';
      });
    } finally {
      setState(() {
        _isLoadingMoods = false;
      });
    }
  }

  /// Public method to refresh mood data (can be called from parent widgets)
  void refreshMoodData() {
    _loadMoodEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isLoading) {
          return _buildLoadingState(context);
        }

        if (!settingsProvider.hasBasicSetup) {
          return _buildSetupState(context);
        }

        return _buildHeatmapState(context, settingsProvider.userSettings!);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading your life heatmap...',
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Past is Past section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 1),
            ),
            child: Column(
              children: [
                Text(
                  'Past is Past',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your life journey visualization will appear here',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Setup button
          ElevatedButton.icon(
            onPressed: () => _showSetupDialog(context),
            icon: const Icon(Icons.settings, color: Colors.black),
            label: const Text(
              'Setup Heatmap',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Set your date of birth and country to visualize your life as a heatmap of weeks.',
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapState(BuildContext context, UserSettings settings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (settings.dateOfBirth == null || settings.deathDate == null) {
      return _buildSetupState(context);
    }

    final now = DateTime.now();
    final birthDate = settings.dateOfBirth!;
    final deathDate = settings.deathDate!;

    // Calculate weeks
    final totalWeeks = deathDate.difference(birthDate).inDays ~/ 7;
    final livedWeeks = now.difference(birthDate).inDays ~/ 7;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error display
          if (_moodError != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_moodError!, style: const TextStyle(color: Colors.orange, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Heatmap grid
          _isLoadingMoods
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          'Loading mood data...',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildHeatmapGrid(
                  context,
                  totalWeeks: totalWeeks,
                  livedWeeks: livedWeeks,
                  birthDate: birthDate,
                  moodEntries: _moodEntries,
                ),

          const SizedBox(height: 12),

          // Legend
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid(
    BuildContext context, {
    required int totalWeeks,
    required int livedWeeks,
    required DateTime birthDate,
    required List<MoodEntry> moodEntries,
  }) {
    // Fixed 45 dots per row to prevent overflow
    const weeksPerRow = 45;

    // Create mood mapping by week
    final moodsByWeek = <int, List<MoodEntry>>{};
    for (final mood in moodEntries) {
      final weekIndex = mood.timestampUtc.difference(birthDate).inDays ~/ 7;
      moodsByWeek.putIfAbsent(weekIndex, () => []).add(mood);
    }

    // Find the earliest week with mood data
    int startWeekIndex = 0;
    if (moodsByWeek.isNotEmpty) {
      // Find the earliest week that has mood data
      final earliestMoodWeek = moodsByWeek.keys.reduce((a, b) => a < b ? a : b);
      startWeekIndex = earliestMoodWeek;
    } else {
      // If no mood data, start from current week
      startWeekIndex = livedWeeks;
    }

    // Calculate weeks to display (from earliest mood data to death date)
    final weeksToDisplay = totalWeeks - startWeekIndex;
    final rows = (weeksToDisplay / weeksPerRow).ceil();

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(rows, (rowIndex) {
          final startWeek = startWeekIndex + (rowIndex * weeksPerRow);
          final endWeek = ((startWeek + weeksPerRow) > totalWeeks) ? totalWeeks : startWeek + weeksPerRow;

          return Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(endWeek - startWeek, (colIndex) {
                final weekIndex = startWeek + colIndex;
                return _buildWeekDot(context, weekIndex, livedWeeks, birthDate, moodsByWeek);
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWeekDot(
    BuildContext context,
    int weekIndex,
    int livedWeeks,
    DateTime birthDate,
    Map<int, List<MoodEntry>> moodsByWeek,
  ) {
    const dotSize = 6.0;
    const dotSpacing = 1.0;

    Color dotColor;
    bool hasMoodData = false;

    if (weekIndex < livedWeeks) {
      // Past weeks - check for mood data
      final weekMoods = moodsByWeek[weekIndex] ?? [];

      if (weekMoods.isNotEmpty) {
        // Calculate average mood for the week and round to nearest integer
        final averageMood = weekMoods.map((e) => e.moodScore).reduce((a, b) => a + b) / weekMoods.length;
        final roundedMood = averageMood.roundToDouble();
        dotColor = MoodVocabulary.getColorForScore(roundedMood);
        hasMoodData = true;
      } else {
        // No mood data - grey
        dotColor = Colors.grey.shade400;
      }
    } else {
      // Future weeks - light grey
      dotColor = Colors.grey.shade200;
    }

    // Check if this week represents the current week
    final now = DateTime.now();
    final currentWeekIndex = now.difference(birthDate).inDays ~/ 7;
    final isCurrentWeek = weekIndex == currentWeekIndex;

    return Transform.scale(
      // Make current week dot slightly larger for subtle emphasis
      scale: isCurrentWeek ? 1.3 : 1.0,
      child: Container(
        width: dotSize,
        height: dotSize,
        margin: const EdgeInsets.all(dotSpacing / 2),
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
          // Add enhanced shadow effect for current week and regular shadow for mood dots
          boxShadow: isCurrentWeek
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 2, offset: const Offset(0, 1))]
              : hasMoodData
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 1, offset: const Offset(0, 0.5))]
              : null,
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Past', Colors.grey.shade400),
        const SizedBox(width: 16),
        _buildLegendItem('Future', Colors.grey.shade200),
        const SizedBox(width: 16),
        _buildLegendItem('Mood', MoodVocabulary.getColorForScore(7)), // Happy color
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
      ],
    );
  }

  void _showSetupDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const HeatmapSetupDialog());
  }
}
