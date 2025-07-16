import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entities/mood_entry.dart';
import '../../core/entities/mood_vocabulary.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/mood_repository_impl.dart';
import '../../data/datasources/local/database_helper.dart';
import '../providers/navigation_provider.dart';

/// Custom app bar widget following Apple design standards
/// Left: Hamburger menu, Center: Dynamic title, Right: Latest mood
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.navBackgroundDark
              : AppColors.navBackgroundLight,
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.navTitleDark
              : AppColors.navTitleLight,
          elevation: 0,
          centerTitle: true,

          // Left section: Hamburger menu
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              size: 24,
            ),
            onPressed: () {
              navigationProvider.toggleDrawer();
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Open menu',
          ),

          // Center section: Dynamic title
          title: Text(
            navigationProvider.currentPageTitle,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.navTitleDark : AppColors.navTitleLight,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),

          // Right section: Latest mood
          actions: [_LatestMoodWidget(), const SizedBox(width: 16)],

          // Bottom border for visual separation
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 0.5,
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
        );
      },
    );
  }
}

/// Widget to display the latest mood in the app bar
class _LatestMoodWidget extends StatefulWidget {
  @override
  State<_LatestMoodWidget> createState() => _LatestMoodWidgetState();
}

class _LatestMoodWidgetState extends State<_LatestMoodWidget> {
  MoodEntry? _latestMood;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLatestMood();
  }

  Future<void> _loadLatestMood() async {
    setState(() => _isLoading = true);

    try {
      final databaseHelper = DatabaseHelper();
      final moodRepository = MoodRepositoryImpl(databaseHelper);
      final result = await moodRepository.getAllMoods();

      if (result.isSuccess) {
        final moods = result.data ?? [];
        if (moods.isNotEmpty) {
          // Sort by timestamp descending and take the first (most recent)
          moods.sort((a, b) => b.timestampUtc.compareTo(a.timestampUtc));
          setState(() => _latestMood = moods.first);
        }
      }
    } catch (e) {
      // Handle error silently for app bar
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _latestMood == null) {
      return const SizedBox.shrink();
    }

    final moodColor = MoodVocabulary.getColorForScore(_latestMood!.moodScore.toDouble());
    final moodEmoji = _latestMood!.moodScore.moodEmoji;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: moodColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: moodColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(moodEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: moodColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
