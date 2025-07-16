import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/entities/mood_entry.dart';
import '../../core/entities/mood_vocabulary.dart';
import '../../core/entities/user_settings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/mood_consolidation_utils.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';
import '../providers/navigation_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fixed_text_input.dart';
import '../widgets/heatmap_setup_dialog.dart';

/// Home page - main mood tracking interface
/// Following Clean Architecture principles - presentation layer
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize settings provider after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsProvider>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationProvider, SettingsProvider>(
      builder: (context, navigationProvider, settingsProvider, child) {
        // Show loading screen while settings are loading
        if (settingsProvider.isLoading) {
          return Scaffold(
            appBar: const AppBarWidget(),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.backgroundPrimaryDark
                        : AppColors.backgroundPrimaryLight,
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.backgroundSecondaryDark
                        : AppColors.backgroundSecondaryLight,
                  ],
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Scaffold(
          appBar: const AppBarWidget(),
          drawer: const AppDrawer(),
          body: Column(
            children: [
              // Main scrollable content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.backgroundPrimaryDark
                            : AppColors.backgroundPrimaryLight,
                        Theme.of(context).brightness == Brightness.dark
                            ? AppColors.backgroundSecondaryDark
                            : AppColors.backgroundSecondaryLight,
                      ],
                    ),
                  ),
                  child: _buildMainContent(context, navigationProvider),
                ),
              ),

              // Fixed text input at bottom
              FixedTextInput(placeholder: 'How are you feeling?', onSubmit: () => _handleMoodSubmit(context)),
            ],
          ),
        );
      },
    );
  }

  /// Build main content area
  Widget _buildMainContent(BuildContext context, NavigationProvider navigationProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Compact monthly view with today column
          _buildCompactMonthlyView(context),

          const SizedBox(height: 16),

          // This Life heatmap
          _buildLifetimeHeatmap(context),

          const SizedBox(height: 16),

          // Recent entries
          _buildRecentEntriesSection(context),
        ],
      ),
    );
  }

  /// Build recent entries section
  Widget _buildRecentEntriesSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<MoodEntry>>(
      future: _getRecentMoodEntries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 1,
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            elevation: 1,
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Error loading entries: ${snapshot.error}',
                style: TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final moodEntries = snapshot.data ?? [];

        if (moodEntries.isEmpty) {
          return Card(
            elevation: 1,
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No mood entries yet. Start by adding your first mood!',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(children: moodEntries.take(5).map((entry) => _buildMoodEntryCard(context, entry)).toList());
      },
    );
  }

  /// Handle mood submission from the fixed text input
  void _handleMoodSubmit(BuildContext context) {
    // The FixedTextInput widget now handles mood submission directly
    // This callback refreshes the UI to show the new entry
    setState(() {
      // This will trigger a rebuild and refresh the FutureBuilder
    });
    debugPrint('Mood submit tapped - UI refreshed');
  }

  /// Get recent mood entries from database
  Future<List<MoodEntry>> _getRecentMoodEntries() async {
    try {
      final databaseHelper = DatabaseHelper();
      final moodRepository = MoodRepositoryImpl(databaseHelper);

      final result = await moodRepository.getAllMoods();
      if (result.isSuccess) {
        final allMoods = result.data ?? [];
        // Sort by timestamp descending (most recent first) and take last 5
        allMoods.sort((a, b) => b.timestampUtc.compareTo(a.timestampUtc));
        return allMoods.take(5).toList();
      } else {
        throw Exception(result.failure?.message ?? 'Failed to load mood entries');
      }
    } catch (e) {
      throw Exception('Error loading mood entries: $e');
    }
  }

  /// Build individual mood entry card
  Widget _buildMoodEntryCard(BuildContext context, MoodEntry entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('MMM d, h:mm a');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 4),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timestamp with mood dot and info
            Row(
              children: [
                // Small mood dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: entry.moodScore.moodColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  timeFormat.format(entry.timestampUtc.toLocal()),
                  style: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: entry.moodScore.moodColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: entry.moodScore.moodColor.withValues(alpha: 0.3), width: 1),
                  ),
                  child: Text(
                    '${entry.moodScore.moodEmoji} ${entry.moodScore.moodLabel} (${entry.moodScore})',
                    style: TextStyle(color: entry.moodScore.moodColor, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),

            // Note (if available)
            if (entry.note != null && entry.note!.isNotEmpty)
              Text(
                entry.note!,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            // Tags (if available)
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: entry.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3), width: 1),
                        ),
                        child: Text(
                          tag.name,
                          style: TextStyle(color: AppColors.neonGreen, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build compact weekly view with TODAY column, weekday labels, and week blocks
  Widget _buildCompactMonthlyView(BuildContext context) {
    return FutureBuilder<List<MoodEntry>>(
      future: _getRecentMoodEntries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildHeatmapLoadingState(context, 'This Week');
        }

        if (snapshot.hasError) {
          return _buildHeatmapErrorState(context, 'This Week', snapshot.error.toString());
        }

        final moodEntries = snapshot.data ?? [];
        return _buildCompactWeeklySection(context, moodEntries);
      },
    );
  }

  /// Build the complete weekly section with title and grid
  Widget _buildCompactWeeklySection(BuildContext context, List<MoodEntry> moodEntries) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'So far...',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildCompactMonthlyGrid(context, moodEntries),
      ],
    );
  }

  /// Build the compact grid with 10 columns (TODAY + weekdays + month)
  Widget _buildCompactMonthlyGrid(BuildContext context, List<MoodEntry> moodEntries) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekDays = MoodConsolidationUtils.getCurrentWeekDays();
    final monthDays = MoodConsolidationUtils.getCurrentMonthDays();
    final today = DateTime.now();

    // Get today's mood
    final todayMood = MoodConsolidationUtils.consolidateDailyMood(moodEntries, today);

    return SizedBox(
      height: 120, // Fixed height for 5 rows
      child: Row(
        children: [
          // Column 1: TODAY with vertical text and mood
          _buildTodayColumn(context, todayMood, isDark),

          const SizedBox(width: 8),

          // Columns 2-3: Weekday data blocks
          _buildWeekdayDataColumn(context, weekDays, moodEntries, isDark),

          const SizedBox(width: 8),

          // Columns 4-10: This Month heatmap (7 columns)
          Expanded(flex: 7, child: _buildCompactMonthHeatmap(context, monthDays, moodEntries)),
        ],
      ),
    );
  }

  /// Build TODAY column with vertical text and mood indicator
  Widget _buildTodayColumn(BuildContext context, double? todayMood, bool isDark) {
    Color todayColor;
    if (todayMood != null) {
      todayColor = MoodConsolidationUtils.getConsolidatedMoodColor(todayMood);
    } else {
      todayColor = Colors.grey.shade400;
    }

    final textColor = todayMood != null ? _getContrastColor(todayColor) : (isDark ? Colors.white : Colors.black);
    final moodEmoji = todayMood != null ? todayMood.round().moodEmoji : '😐';
    final letters = [moodEmoji, 'T', 'O', 'D', 'A', 'Y'];

    return Container(
      width: 40,
      height: 120,
      decoration: BoxDecoration(
        color: todayColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: letters.map((letter) {
          final isEmoji = letter == moodEmoji;
          return Text(
            letter,
            style: TextStyle(
              color: isEmoji ? null : textColor, // Emoji uses default color
              fontSize: isEmoji ? 16 : 12,
              fontWeight: FontWeight.w600,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build weekday data column showing actual mood data for each day of the week
  Widget _buildWeekdayDataColumn(
    BuildContext context,
    List<DateTime> weekDays,
    List<MoodEntry> moodEntries,
    bool isDark,
  ) {
    final weekdayLabels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return SizedBox(
      width: 60, // Width for columns 2-3
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final day = weekDays[index];
          final dayLabel = weekdayLabels[index];
          final consolidatedMood = MoodConsolidationUtils.consolidateDailyMood(moodEntries, day);

          Color? fillColor;
          Color borderColor;

          if (consolidatedMood != null) {
            // Has mood data - show mood color as fill
            fillColor = MoodConsolidationUtils.getConsolidatedMoodColor(consolidatedMood);
            borderColor = fillColor;
          } else if (MoodConsolidationUtils.isFutureDate(day)) {
            // Future dates - white outline, no fill
            fillColor = null;
            borderColor = Colors.white;
          } else {
            // Past dates with no data - grey outline, no fill
            fillColor = null;
            borderColor = Colors.grey.shade400;
          }

          final isToday = DateFormat('yyyy-MM-dd').format(day) == DateFormat('yyyy-MM-dd').format(DateTime.now());

          return Container(
            height: 14,
            margin: const EdgeInsets.symmetric(vertical: 1),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isToday ? (isDark ? Colors.white : Colors.black) : borderColor,
                width: isToday ? 1.5 : 0.5,
              ),
            ),
            child: Stack(
              children: [
                // Diagonal lines for past dates with no data
                if (consolidatedMood == null && !MoodConsolidationUtils.isFutureDate(day))
                  CustomPaint(
                    size: Size.infinite,
                    painter: DiagonalLinesPainter(
                      color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                // Day label
                Center(
                  child: Text(
                    dayLabel,
                    style: TextStyle(
                      color: fillColor != null ? _getContrastColor(fillColor) : (isDark ? Colors.white : Colors.black),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Build compact month heatmap for columns 4-10 (7 columns)
  Widget _buildCompactMonthHeatmap(BuildContext context, List<DateTime> monthDays, List<MoodEntry> moodEntries) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Arrange days in a 7-column grid (max 5 rows for a month)
    const columnsPerRow = 7;
    final rows = (monthDays.length / columnsPerRow).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * columnsPerRow;
        final endIndex = (startIndex + columnsPerRow > monthDays.length)
            ? monthDays.length
            : startIndex + columnsPerRow;

        final rowDays = monthDays.sublist(startIndex, endIndex);

        return Expanded(
          child: Row(
            children: [
              ...rowDays.map((day) => Expanded(child: _buildCompactMonthDayBlock(context, day, moodEntries, isDark))),
              // Fill remaining space if last row is incomplete
              if (rowDays.length < columnsPerRow)
                ...List.generate(columnsPerRow - rowDays.length, (index) => Expanded(child: SizedBox())),
            ],
          ),
        );
      }),
    );
  }

  /// Build individual compact day block for the month heatmap
  Widget _buildCompactMonthDayBlock(BuildContext context, DateTime day, List<MoodEntry> moodEntries, bool isDark) {
    final consolidatedMood = MoodConsolidationUtils.consolidateDailyMood(moodEntries, day);

    Color? fillColor;
    Color borderColor;

    if (consolidatedMood != null) {
      // Has mood data - show mood color as fill
      fillColor = MoodConsolidationUtils.getConsolidatedMoodColor(consolidatedMood);
      borderColor = fillColor;
    } else if (MoodConsolidationUtils.isFutureDate(day)) {
      // Future dates - white outline, no fill
      fillColor = null;
      borderColor = Colors.white;
    } else {
      // Past dates with no data - grey outline, no fill
      fillColor = null;
      borderColor = Colors.grey.shade400;
    }

    final isToday = DateFormat('yyyy-MM-dd').format(day) == DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Container(
      margin: const EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: isToday ? (isDark ? Colors.white : Colors.black) : borderColor,
          width: isToday ? 1.5 : 0.5,
        ),
      ),
      child: Stack(
        children: [
          // Diagonal lines for past dates with no data
          if (consolidatedMood == null && !MoodConsolidationUtils.isFutureDate(day))
            CustomPaint(
              size: Size.infinite,
              painter: DiagonalLinesPainter(
                color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
              ),
            ),
          // Day number
          Center(
            child: Text(
              day.day.toString(),
              style: TextStyle(
                color: fillColor != null ? _getContrastColor(fillColor) : (isDark ? Colors.white : Colors.black),
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build lifetime heatmap section (yearly blocks for entire life)
  Widget _buildLifetimeHeatmap(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        if (settingsProvider.isLoading) {
          return _buildHeatmapLoadingState(context, 'This Life');
        }

        if (!settingsProvider.hasBasicSetup) {
          return _buildLifetimeSetupState(context);
        }

        return FutureBuilder<List<MoodEntry>>(
          future: _getRecentMoodEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildHeatmapLoadingState(context, 'This Life');
            }

            if (snapshot.hasError) {
              return _buildHeatmapErrorState(context, 'This Life', snapshot.error.toString());
            }

            final moodEntries = snapshot.data ?? [];
            return _buildLifetimeHeatmapGrid(context, settingsProvider.userSettings!, moodEntries);
          },
        );
      },
    );
  }

  /// Build loading state for heatmap sections
  Widget _buildHeatmapLoadingState(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
      ],
    );
  }

  /// Build error state for heatmap sections
  Widget _buildHeatmapErrorState(BuildContext context, String title, String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              'Error: $error',
              style: TextStyle(color: Colors.red, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  /// Build setup state for lifetime heatmap
  Widget _buildLifetimeSetupState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'One life!',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                'Setup required - Set your date of birth and country',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showSetupDialog(context),
                icon: const Icon(Icons.settings, color: Colors.black, size: 16),
                label: const Text(
                  'Setup Heatmap',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Show setup dialog for heatmap configuration
  void _showSetupDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const HeatmapSetupDialog());
  }

  /// Get contrasting text color for background
  Color _getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine if we need light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Build lifetime heatmap grid (yearly blocks for entire life)
  Widget _buildLifetimeHeatmapGrid(BuildContext context, UserSettings settings, List<MoodEntry> moodEntries) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (settings.dateOfBirth == null) {
      return _buildLifetimeSetupState(context);
    }

    final lifetimeYears = MoodConsolidationUtils.getLifetimeYears(settings.dateOfBirth!, deathDate: settings.deathDate);
    const blocksPerRow = 10; // 10 years per row

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'One Life',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildLifetimeGrid(context, lifetimeYears, moodEntries, blocksPerRow, settings.dateOfBirth!),
      ],
    );
  }

  /// Build the lifetime grid with proper wrapping
  Widget _buildLifetimeGrid(
    BuildContext context,
    List<int> lifetimeYears,
    List<MoodEntry> moodEntries,
    int blocksPerRow,
    DateTime birthDate,
  ) {
    final rows = (lifetimeYears.length / blocksPerRow).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        final startIndex = rowIndex * blocksPerRow;
        final endIndex = (startIndex + blocksPerRow > lifetimeYears.length)
            ? lifetimeYears.length
            : startIndex + blocksPerRow;

        final rowYears = lifetimeYears.sublist(startIndex, endIndex);

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              ...rowYears.map((year) => _buildLifetimeYearBlock(context, year, moodEntries, birthDate)),
              // Fill remaining space if last row is incomplete
              if (rowYears.length < blocksPerRow)
                ...List.generate(blocksPerRow - rowYears.length, (index) => Expanded(child: SizedBox())),
            ],
          ),
        );
      }),
    );
  }

  /// Build individual year block for lifetime view
  Widget _buildLifetimeYearBlock(BuildContext context, int year, List<MoodEntry> moodEntries, DateTime birthDate) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final consolidatedMood = MoodConsolidationUtils.consolidateYearlyMood(moodEntries, year);

    Color? fillColor;
    Color borderColor;

    if (consolidatedMood != null) {
      // Has mood data - show mood color as fill
      fillColor = MoodConsolidationUtils.getConsolidatedMoodColor(consolidatedMood);
      borderColor = fillColor;
    } else if (MoodConsolidationUtils.isFutureYear(year)) {
      // Future years - white outline, no fill
      fillColor = null;
      borderColor = Colors.white;
    } else {
      // Past years with no data - grey outline, no fill
      fillColor = null;
      borderColor = Colors.grey.shade400;
    }

    final isCurrentYear = year == DateTime.now().year;

    return Expanded(
      child: Container(
        height: 30,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isCurrentYear ? (isDark ? Colors.white : Colors.black) : borderColor,
            width: isCurrentYear ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Diagonal lines for past years with no data
            if (consolidatedMood == null && !MoodConsolidationUtils.isFutureYear(year))
              CustomPaint(
                size: Size.infinite,
                painter: DiagonalLinesPainter(
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3),
                ),
              ),
            // Age number
            Center(
              child: Text(
                (year - birthDate.year).toString(), // Show age for that year
                style: TextStyle(
                  color: fillColor != null ? _getContrastColor(fillColor) : (isDark ? Colors.white : Colors.black),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for drawing diagonal lines to indicate past dates with no data
class DiagonalLinesPainter extends CustomPainter {
  final Color color;

  DiagonalLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw diagonal line from top-left to bottom-right
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);

    // Draw diagonal line from top-right to bottom-left
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is DiagonalLinesPainter && oldDelegate.color != color;
  }
}
