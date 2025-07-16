import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entities/time_filter.dart';
import '../../core/theme/app_colors.dart';
import '../providers/navigation_provider.dart';

/// Time filter chip component for the app bar
/// Displays current selection and allows switching between Day, Week, Month
class TimeFilterChip extends StatelessWidget {
  const TimeFilterChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return GestureDetector(
          onTap: () => _showFilterOptions(context, navigationProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neonGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  navigationProvider.selectedTimeFilter.displayName,
                  style: TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.neonGreen,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show filter options in a bottom sheet
  void _showFilterOptions(BuildContext context, NavigationProvider navigationProvider) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.backgroundSecondaryDark
                : AppColors.backgroundSecondaryLight,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Time Filter',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Filter options
              ...TimeFilter.all.map((filter) => _buildFilterOption(
                context,
                filter,
                navigationProvider.selectedTimeFilter == filter,
                () {
                  navigationProvider.updateTimeFilter(filter);
                  Navigator.of(context).pop();
                },
              )),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// Build individual filter option
  Widget _buildFilterOption(
    BuildContext context,
    TimeFilter filter,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.neonGreen : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 2,
            ),
            color: isSelected ? AppColors.neonGreen : Colors.transparent,
          ),
          child: isSelected
              ? const Icon(
                  Icons.check,
                  color: AppColors.textPrimaryDark,
                  size: 16,
                )
              : null,
        ),
        title: Text(
          filter.displayName,
          style: TextStyle(
            color: isSelected
                ? AppColors.neonGreen
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _getFilterDescription(filter),
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isSelected
            ? AppColors.neonGreen.withOpacity(0.05)
            : Colors.transparent,
      ),
    );
  }

  /// Get description for filter
  String _getFilterDescription(TimeFilter filter) {
    switch (filter.type) {
      case TimeFilterType.day:
        return 'View mood data for today';
      case TimeFilterType.week:
        return 'View mood data for this week';
      case TimeFilterType.month:
        return 'View mood data for this month';
    }
  }
}
