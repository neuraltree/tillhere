import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/entities/notification_settings.dart';
import '../../core/injection/dependency_injection.dart';
import '../providers/navigation_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer.dart';

/// Settings page - app configuration and preferences
/// Following Clean Architecture principles - presentation layer
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          appBar: const AppBarWidget(),
          drawer: const AppDrawer(),
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
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPageHeader(context),
                    const SizedBox(height: 24),
                    _buildGeneralSection(context),
                    const SizedBox(height: 16),
                    _buildNotificationsSection(context),
                    const SizedBox(height: 16),
                    _buildPrivacySection(context),
                    const SizedBox(height: 16),
                    _buildDataSection(context),
                    const SizedBox(height: 16),
                    _buildAboutSection(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build page header
  Widget _buildPageHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customize your mood tracking experience',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Build general settings section
  Widget _buildGeneralSection(BuildContext context) {
    return _buildSettingsSection(context, 'General', '⚙️', [
      _buildSettingsTile(
        context,
        'Theme',
        'Dark mode',
        Icons.dark_mode,
        trailing: Switch(
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (value) {
            // TODO: Implement theme switching
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Theme switching will be implemented')));
          },
          activeColor: AppColors.neonGreen,
        ),
      ),
      _buildSettingsTile(
        context,
        'Language',
        'English',
        Icons.language,
        onTap: () {
          // TODO: Implement language selection
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Language selection will be implemented')));
        },
      ),
      _buildSettingsTile(
        context,
        'Default Time Filter',
        'Day',
        Icons.filter_list,
        onTap: () {
          // TODO: Implement default filter selection
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Default filter selection will be implemented')));
        },
      ),
    ]);
  }

  /// Build notifications section
  Widget _buildNotificationsSection(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (!notificationProvider.isInitialized) {
          return _buildSettingsSection(context, 'Notifications', '🔔', [
            const ListTile(leading: CircularProgressIndicator(), title: Text('Initializing notifications...')),
          ]);
        }

        if (notificationProvider.error != null) {
          return _buildSettingsSection(context, 'Notifications', '🔔', [
            ListTile(
              leading: const Icon(Icons.error, color: AppColors.error),
              title: const Text('Notification Error'),
              subtitle: Text(notificationProvider.error!),
            ),
          ]);
        }

        final dailyNotifications = notificationProvider.getNotificationsByScheduleType(NotificationScheduleType.daily);
        final weeklyNotifications = notificationProvider.getNotificationsByScheduleType(
          NotificationScheduleType.weekly,
        );

        final hasDailyReminder = dailyNotifications.isNotEmpty;
        final hasWeeklyReminder = weeklyNotifications.isNotEmpty;
        final dailyReminderEnabled = hasDailyReminder && dailyNotifications.first.enabled;
        final weeklyReminderEnabled = hasWeeklyReminder && weeklyNotifications.first.enabled;

        return _buildSettingsSection(context, 'Notifications', '🔔', [
          _buildSettingsTile(
            context,
            'Daily Reminders',
            'Get reminded to log your mood',
            Icons.notifications,
            trailing: Switch(
              value: dailyReminderEnabled,
              onChanged: (value) => _toggleDailyReminder(context, value),
              activeColor: AppColors.neonGreen,
            ),
          ),
          if (hasDailyReminder)
            _buildSettingsTile(
              context,
              'Reminder Time',
              dailyNotifications.first.displayTime,
              Icons.schedule,
              onTap: () => _showTimePicker(context, dailyNotifications.first),
            ),
          _buildSettingsTile(
            context,
            'Weekly Summary',
            'Get weekly mood insights',
            Icons.insights,
            trailing: Switch(
              value: weeklyReminderEnabled,
              onChanged: (value) => _toggleWeeklyReminder(context, value),
              activeColor: AppColors.neonGreen,
            ),
          ),
          if (hasWeeklyReminder)
            _buildSettingsTile(
              context,
              'Weekly Schedule',
              weeklyNotifications.first.daysOfWeekDisplay,
              Icons.calendar_today,
              onTap: () => _showWeeklySchedulePicker(context, weeklyNotifications.first),
            ),
          const Divider(),
          _buildSettingsTile(
            context,
            'Test Notification',
            'Send a test notification now',
            Icons.notification_add,
            onTap: () => _sendTestNotification(context),
          ),
        ]);
      },
    );
  }

  /// Build privacy section
  Widget _buildPrivacySection(BuildContext context) {
    return _buildSettingsSection(context, 'Privacy & Security', '🔒', [
      _buildSettingsTile(
        context,
        'Biometric Lock',
        'Secure app with fingerprint/face',
        Icons.fingerprint,
        trailing: Switch(
          value: false,
          onChanged: (value) {
            // TODO: Implement biometric lock
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Biometric lock will be implemented')));
          },
          activeColor: AppColors.neonGreen,
        ),
      ),
      _buildSettingsTile(
        context,
        'Data Retention',
        'How long to keep your data',
        Icons.storage,
        onTap: () {
          // TODO: Implement data retention settings
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Data retention settings will be implemented')));
        },
      ),
    ]);
  }

  /// Build data section
  Widget _buildDataSection(BuildContext context) {
    return _buildSettingsSection(context, 'Data Management', '💾', [
      _buildSettingsTile(
        context,
        'Export Data',
        'Export your data for backup',
        Icons.download,
        onTap: () => _showExportDialog(context),
      ),
      _buildSettingsTile(
        context,
        'Import Data',
        'Import data from backup',
        Icons.upload,
        onTap: () => _showImportDialog(context),
      ),
      _buildSettingsTile(
        context,
        'Clear All Data',
        'Permanently delete all mood data',
        Icons.delete_forever,
        textColor: AppColors.error,
        onTap: () => _showClearDataDialog(context),
      ),
    ]);
  }

  /// Build about section
  Widget _buildAboutSection(BuildContext context) {
    return _buildSettingsSection(context, 'About', 'ℹ️', [
      _buildSettingsTile(context, 'Version', '1.0.0', Icons.info),
      _buildSettingsTile(
        context,
        'Privacy Policy',
        'Read our privacy policy',
        Icons.privacy_tip,
        onTap: () {
          // TODO: Open privacy policy
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Privacy policy will be implemented')));
        },
      ),
      _buildSettingsTile(
        context,
        'Terms of Service',
        'Read our terms of service',
        Icons.description,
        onTap: () {
          // TODO: Open terms of service
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Terms of service will be implemented')));
        },
      ),
      _buildSettingsTile(
        context,
        'Contact Support',
        'Get help with the app',
        Icons.support,
        onTap: () {
          // TODO: Open support contact
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Support contact will be implemented')));
        },
      ),
    ]);
  }

  /// Build settings section
  Widget _buildSettingsSection(BuildContext context, String title, String icon, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Build settings tile
  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.neonGreen, size: 24),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.neonGreen) : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  /// Show export data dialog
  void _showExportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Export Data'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('Choose export format:'), SizedBox(height: 16)],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CSV export will be implemented'), backgroundColor: AppColors.neonGreen),
                );
              },
              child: const Text('CSV'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('JSON export will be implemented'),
                    backgroundColor: AppColors.neonGreen,
                  ),
                );
              },
              child: const Text('JSON'),
            ),
          ],
        );
      },
    );
  }

  /// Show import data dialog
  void _showImportDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Import Data'),
          content: const Text('Select a backup file to import your mood data.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Import functionality will be implemented'),
                    backgroundColor: AppColors.solarOrange,
                  ),
                );
              },
              child: const Text('Select File'),
            ),
          ],
        );
      },
    );
  }

  /// Show clear data confirmation dialog
  void _showClearDataDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'Are you sure you want to permanently delete all your mood data? This action cannot be undone.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement data clearing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data clearing will be implemented'), backgroundColor: AppColors.error),
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );
  }

  /// Toggle daily reminder notification
  Future<void> _toggleDailyReminder(BuildContext context, bool enabled) async {
    final notificationProvider = context.read<NotificationProvider>();

    if (enabled) {
      // Create default daily reminder
      final dailyReminder = NotificationSettings(
        id: 'daily_reminder',
        enabled: true,
        title: 'Time to log your mood',
        body: 'How are you feeling today?',
        scheduleType: NotificationScheduleType.daily,
        time: '20:00', // 8:00 PM
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await notificationProvider.createNotificationSetting(dailyReminder);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notificationProvider.error ?? 'Failed to enable daily reminders'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      // Disable existing daily reminder
      final dailyNotifications = notificationProvider.getNotificationsByScheduleType(NotificationScheduleType.daily);
      if (dailyNotifications.isNotEmpty) {
        final success = await notificationProvider.toggleNotificationEnabled(dailyNotifications.first.id);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notificationProvider.error ?? 'Failed to disable daily reminders'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Toggle weekly reminder notification
  Future<void> _toggleWeeklyReminder(BuildContext context, bool enabled) async {
    final notificationProvider = context.read<NotificationProvider>();

    if (enabled) {
      // Create default weekly reminder (Sunday evenings)
      final weeklyReminder = NotificationSettings(
        id: 'weekly_reminder',
        enabled: true,
        title: 'Weekly mood summary',
        body: 'Review your mood patterns from this week',
        scheduleType: NotificationScheduleType.weekly,
        time: '19:00', // 7:00 PM
        daysOfWeek: [7], // Sunday
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await notificationProvider.createNotificationSetting(weeklyReminder);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notificationProvider.error ?? 'Failed to enable weekly reminders'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      // Disable existing weekly reminder
      final weeklyNotifications = notificationProvider.getNotificationsByScheduleType(NotificationScheduleType.weekly);
      if (weeklyNotifications.isNotEmpty) {
        final success = await notificationProvider.toggleNotificationEnabled(weeklyNotifications.first.id);
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notificationProvider.error ?? 'Failed to disable weekly reminders'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  /// Show time picker for notification
  Future<void> _showTimePicker(BuildContext context, NotificationSettings notification) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: notification.hour, minute: notification.minute),
    );

    if (picked != null && mounted) {
      final notificationProvider = context.read<NotificationProvider>();
      final updatedNotification = notification.copyWith(
        time: '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
        updatedAt: DateTime.now(),
      );

      final success = await notificationProvider.updateNotificationSetting(updatedNotification);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notificationProvider.error ?? 'Failed to update reminder time'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Show weekly schedule picker
  Future<void> _showWeeklySchedulePicker(BuildContext context, NotificationSettings notification) async {
    final List<int> currentDays = notification.daysOfWeek ?? [];
    final List<int> selectedDays = List.from(currentDays);

    final result = await showDialog<List<int>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Days'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Choose which days to receive weekly summaries:'),
                  const SizedBox(height: 16),
                  ...List.generate(7, (index) {
                    final dayIndex = index + 1;
                    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
                    return CheckboxListTile(
                      title: Text(dayNames[index]),
                      value: selectedDays.contains(dayIndex),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedDays.add(dayIndex);
                          } else {
                            selectedDays.remove(dayIndex);
                          }
                        });
                      },
                      activeColor: AppColors.neonGreen,
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                TextButton(
                  onPressed: selectedDays.isEmpty ? null : () => Navigator.of(context).pop(selectedDays),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      final notificationProvider = context.read<NotificationProvider>();
      final updatedNotification = notification.copyWith(daysOfWeek: result, updatedAt: DateTime.now());

      final success = await notificationProvider.updateNotificationSetting(updatedNotification);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notificationProvider.error ?? 'Failed to update weekly schedule'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Send a test notification
  Future<void> _sendTestNotification(BuildContext context) async {
    final notificationProvider = context.read<NotificationProvider>();

    if (!notificationProvider.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification service not initialized'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Get the notification service directly from dependency injection
    final notificationService = DependencyInjection.notificationService;
    if (notificationService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification service not available'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Schedule an immediate test notification
    final result = await notificationService.scheduleImmediateNotification(
      'Test Notification',
      'This is a test notification. Tap to open mood input!',
      payload: 'mood_input',
    );

    if (mounted) {
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent! Check your notification panel.'),
            backgroundColor: AppColors.neonGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send test notification: ${result.failure}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
