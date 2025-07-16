import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../providers/mood_capture_provider.dart';

/// Cupertino-style date picker that integrates with mood capture provider
class MoodDatePicker extends StatelessWidget {
  const MoodDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodCaptureProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => _showDatePicker(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.backgroundSecondaryDark
                  : AppColors.backgroundSecondaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderDark.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 20,
                  color: AppColors.neonGreen,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(provider.selectedDateTime),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.textTertiaryDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (selectedDate == today) {
      return 'Today, ${DateFormat('MMMM d').format(dateTime)}';
    } else if (selectedDate == yesterday) {
      return 'Yesterday, ${DateFormat('MMMM d').format(dateTime)}';
    } else {
      return DateFormat('EEEE, MMMM d').format(dateTime);
    }
  }

  void _showDatePicker(BuildContext context, MoodCaptureProvider provider) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header with done button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.textSecondaryDark),
                        ),
                      ),
                      Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.neonGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Date picker
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: provider.selectedDateTime,
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDateTime) {
                      // Preserve the time component
                      final updatedDateTime = DateTime(
                        newDateTime.year,
                        newDateTime.month,
                        newDateTime.day,
                        provider.selectedDateTime.hour,
                        provider.selectedDateTime.minute,
                      );
                      provider.updateDateTime(updatedDateTime);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Cupertino-style time picker that integrates with mood capture provider
class MoodTimePicker extends StatelessWidget {
  const MoodTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodCaptureProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () => _showTimePicker(context, provider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.backgroundSecondaryDark
                  : AppColors.backgroundSecondaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderDark.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.clock,
                  size: 20,
                  color: AppColors.neonGreen,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(provider.selectedDateTime),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppColors.textTertiaryDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  void _showTimePicker(BuildContext context, MoodCaptureProvider provider) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Header with done button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.textSecondaryDark),
                        ),
                      ),
                      Text(
                        'Select Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.neonGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Time picker
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: provider.selectedDateTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      // Preserve the date component
                      final updatedDateTime = DateTime(
                        provider.selectedDateTime.year,
                        provider.selectedDateTime.month,
                        provider.selectedDateTime.day,
                        newDateTime.hour,
                        newDateTime.minute,
                      );
                      provider.updateDateTime(updatedDateTime);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Combined date and time picker row
class DateTimePickerRow extends StatelessWidget {
  const DateTimePickerRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MoodDatePicker(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MoodTimePicker(),
        ),
      ],
    );
  }
}

/// Compact date/time display for collapsed state
class CompactDateTimeDisplay extends StatelessWidget {
  const CompactDateTimeDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodCaptureProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final isToday = _isSameDay(provider.selectedDateTime, now);
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.neonGreen.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.clock,
                size: 14,
                color: AppColors.neonGreen,
              ),
              const SizedBox(width: 6),
              Text(
                isToday 
                    ? 'Today, ${DateFormat('h:mm a').format(provider.selectedDateTime)}'
                    : DateFormat('MMM d, h:mm a').format(provider.selectedDateTime),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neonGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}
